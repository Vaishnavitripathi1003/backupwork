package com.daksh.daksh.ui.camera

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Matrix
import android.graphics.Paint
import android.hardware.camera2.CaptureRequest
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.MotionEvent
import androidx.camera.camera2.interop.Camera2Interop
import androidx.camera.camera2.interop.ExperimentalCamera2Interop
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.FocusMeteringAction
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.core.resolutionselector.ResolutionStrategy
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.concurrent.Executor
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

@OptIn(ExperimentalCamera2Interop::class)
@Composable
fun CameraPreview(
    modifier: Modifier = Modifier,
    isTorchEnabled: Boolean = false,
    onFocusStatusChanged: (isCorrect: Boolean, offset: Offset?) -> Unit,
    onImageCaptured: (Bitmap) -> Unit,
    onError: (Exception) -> Unit,
    captureTrigger: Boolean
) {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current
    var camera by remember { mutableStateOf<Camera?>(null) }
    var previewViewRef by remember { mutableStateOf<PreviewView?>(null) }
    var lastFocusTime by remember { mutableStateOf(0L) }

    // Resolution selector asking for highest available sensor resolution
    val resolutionSelector = remember {
        ResolutionSelector.Builder()
            .setResolutionStrategy(ResolutionStrategy.HIGHEST_AVAILABLE_STRATEGY)
            .build()
    }

    // ImageCapture builder with max quality & Camera2 interop tuning
    val imageCaptureBuilder = remember {
        ImageCapture.Builder()
            .setCaptureMode(ImageCapture.CAPTURE_MODE_MAXIMIZE_QUALITY)
            .setJpegQuality(100)
            .setResolutionSelector(resolutionSelector)
    }

    // Apply Camera2 Interop settings for Fingertip Macro AF, max sharpness and noise reduction
    remember {
        val camera2Interop = Camera2Interop.Extender(imageCaptureBuilder)
        camera2Interop.setCaptureRequestOption(
            CaptureRequest.CONTROL_AF_MODE,
            CaptureRequest.CONTROL_AF_MODE_MACRO
        )
        camera2Interop.setCaptureRequestOption(
            CaptureRequest.CONTROL_AE_MODE,
            CaptureRequest.CONTROL_AE_MODE_ON
        )
        camera2Interop.setCaptureRequestOption(
            CaptureRequest.CONTROL_AE_LOCK,
            false
        )
        camera2Interop.setCaptureRequestOption(
            CaptureRequest.CONTROL_AWB_MODE,
            CaptureRequest.CONTROL_AWB_MODE_AUTO
        )
        camera2Interop.setCaptureRequestOption(
            CaptureRequest.CONTROL_AWB_LOCK,
            false
        )
        camera2Interop.setCaptureRequestOption(
            CaptureRequest.NOISE_REDUCTION_MODE,
            CaptureRequest.NOISE_REDUCTION_MODE_HIGH_QUALITY
        )
        camera2Interop.setCaptureRequestOption(
            CaptureRequest.EDGE_MODE,
            CaptureRequest.EDGE_MODE_HIGH_QUALITY
        )
        camera2Interop.setCaptureRequestOption(
            CaptureRequest.HOT_PIXEL_MODE,
            CaptureRequest.HOT_PIXEL_MODE_HIGH_QUALITY
        )
    }

    val imageCapture = remember { imageCaptureBuilder.build() }

    // Image Analysis for Real-time Fingertip Contour Detection
    val imageAnalyzer = remember {
        ImageAnalysis.Builder()
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .setResolutionSelector(resolutionSelector)
            .build()
    }

    val mainExecutor = remember { ContextCompat.getMainExecutor(context) }
    val cameraExecutor = remember { Executors.newSingleThreadExecutor() }
    val focusExecutor: ScheduledExecutorService = remember { Executors.newSingleThreadScheduledExecutor() }

    DisposableEffect(Unit) {
        onDispose {
            cameraExecutor.shutdown()
            focusExecutor.shutdown()
        }
    }

    // Automatic Torch Flashlight Activation
    LaunchedEffect(isTorchEnabled, camera) {
        camera?.cameraControl?.enableTorch(isTorchEnabled)
    }

    // Pre-Capture Precision Focus Lock before taking picture
    LaunchedEffect(captureTrigger) {
        if (captureTrigger) {
            val view = previewViewRef
            val cam = camera
            if (view != null && cam != null) {
                try {
                    val factory = view.meteringPointFactory
                    val fingertipPoint = factory.createPoint(
                        view.width / 2f,
                        view.height * 0.38f,
                        0.20f
                    )
                    val preCaptureFocus = FocusMeteringAction.Builder(
                        fingertipPoint,
                        FocusMeteringAction.FLAG_AF or FocusMeteringAction.FLAG_AE or FocusMeteringAction.FLAG_AWB
                    )
                        .setAutoCancelDuration(3, TimeUnit.SECONDS)
                        .build()

                    val focusFuture = cam.cameraControl.startFocusAndMetering(preCaptureFocus)
                    focusFuture.addListener({
                        takePictureDirect(imageCapture, mainExecutor, onImageCaptured, onError)
                    }, mainExecutor)
                } catch (e: Exception) {
                    takePictureDirect(imageCapture, mainExecutor, onImageCaptured, onError)
                }
            } else {
                takePictureDirect(imageCapture, mainExecutor, onImageCaptured, onError)
            }
        }
    }

    AndroidView(
        modifier = modifier.fillMaxSize(),
        factory = { ctx ->
            val previewView = PreviewView(ctx).apply {
                scaleType = PreviewView.ScaleType.FILL_CENTER
            }
            previewViewRef = previewView

            val cameraProviderFuture = ProcessCameraProvider.getInstance(ctx)
            cameraProviderFuture.addListener({
                val cameraProvider = cameraProviderFuture.get()

                val previewBuilder = Preview.Builder()
                    .setResolutionSelector(resolutionSelector)

                val preview = previewBuilder.build().also {
                    it.surfaceProvider = previewView.surfaceProvider
                }

                // Connect Real-time Fingertip Analysis & Focus Lock Verification
                imageAnalyzer.setAnalyzer(cameraExecutor) { imageProxy ->
                    val detectedFingertip = detectFingertipInFrame(imageProxy, previewView.width, previewView.height)
                    imageProxy.close()

                    if (detectedFingertip != null) {
                        val currentTime = System.currentTimeMillis()
                        if (currentTime - lastFocusTime > 1000) {
                            lastFocusTime = currentTime
                            ContextCompat.getMainExecutor(ctx).execute {
                                try {
                                    val factory = previewView.meteringPointFactory
                                    val point = factory.createPoint(
                                        detectedFingertip.x,
                                        detectedFingertip.y,
                                        0.18f
                                    )
                                    val action = FocusMeteringAction.Builder(
                                        point,
                                        FocusMeteringAction.FLAG_AF or FocusMeteringAction.FLAG_AE or FocusMeteringAction.FLAG_AWB
                                    )
                                        .setAutoCancelDuration(2, TimeUnit.SECONDS)
                                        .build()

                                    val future = camera?.cameraControl?.startFocusAndMetering(action)
                                    future?.addListener({
                                        try {
                                            val result = future.get()
                                            val isSuccessful = result.isFocusSuccessful
                                            onFocusStatusChanged(isSuccessful, detectedFingertip)
                                        } catch (e: Exception) {
                                            onFocusStatusChanged(true, detectedFingertip)
                                        }
                                    }, ContextCompat.getMainExecutor(ctx))

                                } catch (e: Exception) {
                                    onFocusStatusChanged(false, null)
                                }
                            }
                        }
                    } else {
                        ContextCompat.getMainExecutor(ctx).execute {
                            onFocusStatusChanged(false, null)
                        }
                    }
                }

                val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA

                try {
                    cameraProvider.unbindAll()
                    val boundCamera = cameraProvider.bindToLifecycle(
                        lifecycleOwner,
                        cameraSelector,
                        preview,
                        imageCapture,
                        imageAnalyzer
                    )
                    camera = boundCamera

                    // Auto-enable Torch Flashlight
                    boundCamera.cameraControl.enableTorch(isTorchEnabled)

                } catch (e: Exception) {
                    Log.e("CameraPreview", "Binding failed", e)
                }
            }, ContextCompat.getMainExecutor(ctx))

            // Manual Touch-to-Focus Gesture on Fingertip
            previewView.setOnTouchListener { v, event ->
                if (event.action == MotionEvent.ACTION_DOWN) {
                    val factory = previewView.meteringPointFactory
                    val point = factory.createPoint(event.x, event.y, 0.18f)
                    val action = FocusMeteringAction.Builder(
                        point,
                        FocusMeteringAction.FLAG_AF or FocusMeteringAction.FLAG_AE or FocusMeteringAction.FLAG_AWB
                    )
                        .setAutoCancelDuration(3, TimeUnit.SECONDS)
                        .build()

                    val future = camera?.cameraControl?.startFocusAndMetering(action)
                    val touchOffset = Offset(event.x, event.y)
                    future?.addListener({
                        try {
                            val result = future.get()
                            onFocusStatusChanged(result.isFocusSuccessful, touchOffset)
                        } catch (e: Exception) {
                            onFocusStatusChanged(true, touchOffset)
                        }
                    }, ContextCompat.getMainExecutor(ctx))

                    v.performClick()
                    true
                } else {
                    false
                }
            }

            previewView
        }
    )
}

/**
 * Detects fingertip pad position from Y-plane luminance in image frame.
 */
private fun detectFingertipInFrame(
    image: ImageProxy,
    viewWidth: Int,
    viewHeight: Int
): Offset? {
    if (viewWidth <= 0 || viewHeight <= 0) return null

    val buffer = image.planes[0].buffer
    val width = image.width
    val height = image.height

    if (width <= 0 || height <= 0) return null

    val startY = (height * 0.15).toInt()
    val endY = (height * 0.60).toInt()
    val startX = (width * 0.25).toInt()
    val endX = (width * 0.75).toInt()

    var sumX = 0L
    var sumY = 0L
    var count = 0

    val bytes = ByteArray(buffer.remaining())
    buffer.get(bytes)

    for (y in startY until endY step 6) {
        for (x in startX until endX step 6) {
            val index = y * width + x
            if (index < bytes.size) {
                val luma = bytes[index].toInt() and 0xFF
                // Fingertip skin contrast threshold under torch illumination
                if (luma > 75) {
                    sumX += x
                    sumY += y
                    count++
                }
            }
        }
    }

    if (count > 80) {
        val avgX = (sumX / count).toFloat() / width
        val avgY = (sumY / count).toFloat() / height
        return Offset(avgX * viewWidth, avgY * viewHeight)
    }

    return null
}

// CameraX image callbacks run on cameraExecutor. UI callbacks must return to main.
private val cameraResultHandler = Handler(Looper.getMainLooper())

private fun takePictureDirect(
    imageCapture: ImageCapture,
    mainExecutor: Executor,
    onImageCaptured: (Bitmap) -> Unit,
    onError: (Exception) -> Unit
) {
    imageCapture.takePicture(
        mainExecutor,
        object : ImageCapture.OnImageCapturedCallback() {
            override fun onCaptureSuccess(image: ImageProxy) {
                CoroutineScope(Dispatchers.Default).launch {
                    try {
                        val rawBitmap = imageProxyToBitmap(image)
                        image.close()
                        val enhancedBitmap = enhanceImageClarity(rawBitmap)
                        withContext(Dispatchers.Main) {
                            onImageCaptured(enhancedBitmap)
                        }
                    } catch (e: Exception) {
                        image.close()
                        withContext(Dispatchers.Main) {
                            onError(e)
                        }
                    }
                }
            }

            override fun onError(exception: ImageCaptureException) {
                onError(exception)
            }
        }
    )
}

private fun imageProxyToBitmap(image: ImageProxy, maxDim: Int = 1200): Bitmap {
    val buffer = image.planes[0].buffer
    val bytes = ByteArray(buffer.remaining())
    buffer.get(bytes)

    val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
    BitmapFactory.decodeByteArray(bytes, 0, bytes.size, options)

    var sampleSize = 1
    val w = options.outWidth
    val h = options.outHeight
    while (w / (sampleSize * 2) >= maxDim && h / (sampleSize * 2) >= maxDim) {
        sampleSize *= 2
    }

    val decodeOptions = BitmapFactory.Options().apply {
        inSampleSize = sampleSize
        inPreferredConfig = Bitmap.Config.ARGB_8888
    }

    val decoded = BitmapFactory.decodeByteArray(bytes, 0, bytes.size, decodeOptions)
        ?: return Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888)

    val matrix = Matrix().apply {
        postRotate(image.imageInfo.rotationDegrees.toFloat())
    }

    val rotated = Bitmap.createBitmap(
        decoded,
        0,
        0,
        decoded.width,
        decoded.height,
        matrix,
        true
    )
    if (rotated != decoded) {
        decoded.recycle()
    }

    if (rotated.width > maxDim || rotated.height > maxDim) {
        val scale = maxDim.toFloat() / maxOf(rotated.width, rotated.height)
        val scaled = Bitmap.createScaledBitmap(
            rotated,
            (rotated.width * scale).toInt().coerceAtLeast(1),
            (rotated.height * scale).toInt().coerceAtLeast(1),
            true
        )
        if (scaled != rotated) {
            rotated.recycle()
        }
        return scaled
    }

    return rotated
}

/**
 * Enhances image clarity, contrast, and edge sharpness for crisp details.
 */
fun enhanceImageClarity(input: Bitmap): Bitmap {
    val output = Bitmap.createBitmap(input.width, input.height, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(output)

    val cm = ColorMatrix(
        floatArrayOf(
            1.25f, 0f, 0f, 0f, -12f,
            0f, 1.25f, 0f, 0f, -12f,
            0f, 0f, 1.25f, 0f, -12f,
            0f, 0f, 0f, 1f, 0f
        )
    )

    val paint = Paint().apply {
        colorFilter = ColorMatrixColorFilter(cm)
        isFilterBitmap = true
        isAntiAlias = true
    }

    canvas.drawBitmap(input, 0f, 0f, paint)
    return output
}
