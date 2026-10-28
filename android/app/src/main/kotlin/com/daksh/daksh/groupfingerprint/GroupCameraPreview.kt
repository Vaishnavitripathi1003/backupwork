package com.daksh.daksh.ui.camera

import android.graphics.Bitmap
import android.graphics.Matrix
import android.util.Log
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.FocusMeteringAction
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.concurrent.TimeUnit

private const val GCAM_TAG = "GroupCamera"

/**
 * Separate CameraX preview for the group scanner. Same parameters as the single-finger
 * CameraPreview, so it can be dropped into GroupScannerDialog directly.
 *
 * Needs CameraX 1.3+ (ImageProxy.toBitmap): camera-core, camera-camera2,
 * camera-lifecycle, camera-view.
 *
 * Note: onFocusStatusChanged(true, ...) means the camera focus LOCKED on the centre,
 * not that four fingertips were detected.
 */
@Composable
fun GroupCameraPreview(
    modifier: Modifier = Modifier,
    isTorchEnabled: Boolean,
    captureTrigger: Boolean,
    onFocusStatusChanged: (Boolean, Offset?) -> Unit,
    onImageCaptured: (Bitmap) -> Unit,
    onError: (Throwable) -> Unit = {}
) {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current
    val mainExecutor = remember { ContextCompat.getMainExecutor(context) }

    val previewView = remember {
        PreviewView(context).apply {
            scaleType = PreviewView.ScaleType.FILL_CENTER
            implementationMode = PreviewView.ImplementationMode.COMPATIBLE
        }
    }
    val imageCapture = remember {
        ImageCapture.Builder()
            .setCaptureMode(ImageCapture.CAPTURE_MODE_MAXIMIZE_QUALITY)
            .build()
    }

    var camera by remember { mutableStateOf<Camera?>(null) }
    var cameraProvider by remember { mutableStateOf<ProcessCameraProvider?>(null) }

    val latestOnImage by rememberUpdatedState(onImageCaptured)
    val latestOnError by rememberUpdatedState(onError)
    val latestOnFocus by rememberUpdatedState(onFocusStatusChanged)

    // ── Bind camera ──
    DisposableEffect(lifecycleOwner) {
        val future = ProcessCameraProvider.getInstance(context)
        future.addListener({
            try {
                val provider = future.get()
                cameraProvider = provider
                val preview = Preview.Builder().build().also {
                    it.setSurfaceProvider(previewView.surfaceProvider)
                }
                provider.unbindAll()
                camera = provider.bindToLifecycle(
                    lifecycleOwner,
                    CameraSelector.DEFAULT_BACK_CAMERA,
                    preview,
                    imageCapture
                )
                Log.i(GCAM_TAG, "Camera bound")
            } catch (t: Throwable) {
                Log.e(GCAM_TAG, "Camera bind FAILED -> ${t.javaClass.simpleName}: ${t.message}", t)
                latestOnError(t)
            }
        }, mainExecutor)

        onDispose {
            Log.d(GCAM_TAG, "Camera unbind")
            cameraProvider?.unbindAll()
        }
    }

    // ── Torch ──
    LaunchedEffect(isTorchEnabled, camera) {
        camera?.cameraControl?.enableTorch(isTorchEnabled)
        Log.d(GCAM_TAG, "Torch -> $isTorchEnabled")
    }

    // ── Periodic centre autofocus, reports lock status ──
    LaunchedEffect(camera) {
        val cam = camera ?: return@LaunchedEffect
        while (true) {
            val w = previewView.width.toFloat()
            val h = previewView.height.toFloat()
            if (w > 0f && h > 0f) {
                val point = previewView.meteringPointFactory.createPoint(w / 2f, h / 2f)
                val action = FocusMeteringAction.Builder(
                    point,
                    FocusMeteringAction.FLAG_AF or FocusMeteringAction.FLAG_AE
                ).setAutoCancelDuration(3, TimeUnit.SECONDS).build()
                val f = cam.cameraControl.startFocusAndMetering(action)
                f.addListener({
                    val ok = try { f.get().isFocusSuccessful } catch (t: Throwable) { false }
                    latestOnFocus(ok, if (ok) Offset(w / 2f, h / 2f) else null)
                }, mainExecutor)
            }
            delay(2000)
        }
    }

    // ── Capture ──
    LaunchedEffect(captureTrigger) {
        if (!captureTrigger) return@LaunchedEffect
        Log.i(GCAM_TAG, "takePicture()")
        imageCapture.takePicture(mainExecutor, object : ImageCapture.OnImageCapturedCallback() {
            override fun onCaptureSuccess(image: ImageProxy) {
                CoroutineScope(Dispatchers.Default).launch {
                    try {
                        val rotation = image.imageInfo.rotationDegrees
                        val raw = image.toBitmap()
                        val bmp = if (rotation != 0) {
                            Bitmap.createBitmap(
                                raw, 0, 0, raw.width, raw.height,
                                Matrix().apply { postRotate(rotation.toFloat()) }, true
                            )
                        } else raw
                        Log.i(GCAM_TAG, "Captured ${bmp.width}x${bmp.height} rotation=$rotation")
                        withContext(Dispatchers.Main) {
                            latestOnImage(bmp)
                        }
                    } catch (t: Throwable) {
                        Log.e(GCAM_TAG, "Capture decode FAILED -> ${t.message}", t)
                        withContext(Dispatchers.Main) {
                            latestOnError(t)
                        }
                    } finally {
                        image.close()
                    }
                }
            }

            override fun onError(exception: ImageCaptureException) {
                Log.e(GCAM_TAG, "takePicture FAILED -> ${exception.message}", exception)
                latestOnError(exception)
            }
        })
    }

    AndroidView(factory = { previewView }, modifier = modifier)
}
