package com.daksh.daksh.atd
import androidx.compose.foundation.BorderStroke
import android.graphics.Bitmap
import android.graphics.Matrix
import android.util.Log
import com.daksh.daksh.R
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.animation.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.PanTool
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import kotlinx.coroutines.delay
import java.util.concurrent.Executors

enum class CaptureStep {
    SHOW_LEFT,
    CAPTURE_LEFT,
    SHOW_RIGHT,
    CAPTURE_RIGHT,
    BOTH_CAPTURED
}

@Composable
fun PalmWorkflowScreen(
    hasCameraPermission: Boolean,
    onRequestPermission: () -> Unit,
    onFrameAvailable: (Bitmap) -> Unit,
    currentAngle: Float,
    detectedHandLabel: String?,
    positionStatus: PalmPositionStatus,
    isHandPresent: Boolean,
    leftAngle: Float?,
    rightAngle: Float?,
    currentWrist: Point2D? = null,
    currentIndexA: Point2D? = null,
    currentPinkyD: Point2D? = null,
    onCaptureLeft: () -> Unit,
    onCaptureRight: () -> Unit,
    onCalculateFinal: () -> Unit,
    onReset: () -> Unit
) {
    val cameraLensFacing = CameraSelector.LENS_FACING_BACK
    var autoCaptureProgress by remember { mutableFloatStateOf(0f) }

    val step = remember(leftAngle, rightAngle) {
        when {
            leftAngle == null -> CaptureStep.SHOW_LEFT
            rightAngle == null -> CaptureStep.SHOW_RIGHT
            else -> CaptureStep.BOTH_CAPTURED
        }
    }

    // Handedness validation: Check if detected hand matches current step
    val isCorrectHandDetected = remember(isHandPresent, currentAngle, detectedHandLabel, step) {
        if (!isHandPresent || currentAngle <= 0f) false
        else when (step) {
            CaptureStep.SHOW_LEFT -> detectedHandLabel == null || detectedHandLabel.contains("Left", ignoreCase = true) || detectedHandLabel.contains("Palm", ignoreCase = true)
            CaptureStep.SHOW_RIGHT -> detectedHandLabel == null || detectedHandLabel.contains("Right", ignoreCase = true) || detectedHandLabel.contains("Palm", ignoreCase = true)
            else -> true
        }
    }

    // Auto-capture requires BOTH correct hand AND perfect distance positioning
    val isPerfectPosition = isCorrectHandDetected && positionStatus == PalmPositionStatus.PERFECT

    // Auto-detect & auto-capture timer logic (keyed ONLY on isPerfectPosition and step)
    LaunchedEffect(isPerfectPosition, step) {
        if (isPerfectPosition) {
            autoCaptureProgress = 0f
            val steps = 6 // 600ms hold steady for fast, reliable auto-capture
            for (i in 1..steps) {
                delay(100)
                autoCaptureProgress = i.toFloat() / steps.toFloat()
            }
            Log.i("PalmScan", "AUTO_CAPTURE_TRIGGERED -> Step: $step, Angle: $currentAngle°, Hand: $detectedHandLabel")
            when (step) {
                CaptureStep.SHOW_LEFT -> onCaptureLeft()
                CaptureStep.SHOW_RIGHT -> onCaptureRight()
                CaptureStep.BOTH_CAPTURED -> onCalculateFinal()
                else -> {}
            }
        } else {
            autoCaptureProgress = 0f
        }
    }

    // Auto-calculate final when both hands captured
    LaunchedEffect(step) {
        if (step == CaptureStep.BOTH_CAPTURED) {
            delay(500)
            onCalculateFinal()
        }
    }

    Scaffold(
        containerColor = Color(0xFFF8FAFC)
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 20.dp, vertical = 10.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Header Bar matched with DAKSH App Theme

            Spacer(modifier = Modifier.height(10.dp))

            // Instruction Banner Card matched with DAKSH AppTheme (Light Indigo)
            Surface(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                color = Color(0xFFEEF2FF),
                border = BorderStroke(1.dp, Color(0xFFC7D2FE))
            ) {
                Row(
                    modifier = Modifier.padding(10.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Default.Info,
                        contentDescription = null,
                        tint = Color(0xFF4F46E5),
                        modifier = Modifier.size(20.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "Positioning Tips: Hold palm flat 20-30 cm away • Spread fingers naturally • Keep steady",
                        fontSize = 11.sp,
                        color = Color(0xFF334155),
                        fontWeight = FontWeight.Medium,
                        lineHeight = 14.sp
                    )
                }
            }

            Spacer(modifier = Modifier.weight(0.1f))

            // Camera Viewfinder Box / Target Circle
            Box(
                modifier = Modifier
                    .size(330.dp)
                    .clip(CircleShape)
                    .border(
                        width = 4.dp,
                        color = if (isPerfectPosition) Color(0xFF10B981) else if (isHandPresent) Color(0xFF06B6D4) else Color(0xFF4F46E5),
                        shape = CircleShape
                    )
                    .background(Color(0xFF0F172A)),
                contentAlignment = Alignment.Center
            ) {
                if (hasCameraPermission) {
                    CameraPreview(
                        cameraLensFacing = cameraLensFacing,
                        onFrameAvailable = onFrameAvailable,
                        modifier = Modifier.fillMaxSize()
                    )

                    // Live Real-Time ATD Points & Triangle Overlay on Hand
                    if (isHandPresent && currentWrist != null && currentIndexA != null && currentPinkyD != null) {
                        Canvas(modifier = Modifier.fillMaxSize()) {
                            val w = size.width
                            val h = size.height

                            val tx = currentWrist.x * w
                            val ty = currentWrist.y * h

                            val ax = currentIndexA.x * w
                            val ay = currentIndexA.y * h

                            val dx = currentPinkyD.x * w
                            val dy = currentPinkyD.y * h

                            // Connecting Triangle Lines
                            drawLine(color = Color(0xFFFF5252), start = Offset(tx, ty), end = androidx.compose.ui.geometry.Offset(ax, ay), strokeWidth = 6f)
                            drawLine(color = Color(0xFF10B981), start = androidx.compose.ui.geometry.Offset(tx, ty), end = androidx.compose.ui.geometry.Offset(dx, dy), strokeWidth = 6f)
                            drawLine(color = Color(0xFFFFD600), start = androidx.compose.ui.geometry.Offset(ax, ay), end = androidx.compose.ui.geometry.Offset(dx, dy), strokeWidth = 6f)

                            // Point T (Wrist / Axial Triradius)
                            drawCircle(color = Color(0xFFFF1744), radius = 16f, center = androidx.compose.ui.geometry.Offset(tx, ty))
                            drawCircle(color = Color.White, radius = 16f, center = androidx.compose.ui.geometry.Offset(tx, ty), style = Stroke(width = 3f))

                            // Point A (Index MCP)
                            drawCircle(color = Color(0xFF00B0FF), radius = 16f, center = androidx.compose.ui.geometry.Offset(ax, ay))
                            drawCircle(color = Color.White, radius = 16f, center = androidx.compose.ui.geometry.Offset(ax, ay), style = Stroke(width = 3f))

                            // Point D (Pinky MCP)
                            drawCircle(color = Color(0xFFAA00FF), radius = 16f, center = androidx.compose.ui.geometry.Offset(dx, dy))
                            drawCircle(color = Color.White, radius = 16f, center = androidx.compose.ui.geometry.Offset(dx, dy), style = Stroke(width = 3f))
                        }
                    }

                    // Overlay HUD on live camera with Positioning Feedback
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(14.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.SpaceBetween
                    ) {
                        // Top HUD Pill (Distance & Positioning Guidance)
                        Surface(
                            shape = RoundedCornerShape(16.dp),
                            color = when {
                                !isHandPresent -> Color(0xCC4F46E5)
                                !isCorrectHandDetected -> Color(0xCCEF4444)
                                positionStatus == PalmPositionStatus.TOO_FAR -> Color(0xCCF59E0B)
                                positionStatus == PalmPositionStatus.TOO_CLOSE -> Color(0xCCF59E0B)
                                else -> Color(0xCC10B981)
                            }
                        ) {
                            Text(
                                text = when {
                                    !isHandPresent -> if (step == CaptureStep.SHOW_LEFT) "Point Camera at LEFT Palm" else "Point Camera at RIGHT Palm"
                                    !isCorrectHandDetected -> "⚠️ Wrong Hand — Show ${if (step == CaptureStep.SHOW_LEFT) "LEFT" else "RIGHT"} Palm"
                                    positionStatus == PalmPositionStatus.TOO_FAR -> "↔ Move Palm Closer"
                                    positionStatus == PalmPositionStatus.TOO_CLOSE -> "↔ Move Palm Further Back"
                                    else -> "✓ Perfect Position (${(autoCaptureProgress * 100).toInt()}%)"
                                },
                                color = Color.White,
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp)
                            )
                        }

                        // Center Target Guide Badge
                        if (!isHandPresent) {
                            Surface(
                                shape = RoundedCornerShape(16.dp),
                                color = if (step == CaptureStep.SHOW_LEFT) Color(0xFF4F46E5) else Color(0xFF7C3AED),
                                shadowElevation = 4.dp
                            ) {
                                Text(
                                    text = if (step == CaptureStep.SHOW_LEFT) "SHOW LEFT PALM" else "SHOW RIGHT PALM",
                                    color = Color.White,
                                    fontSize = 13.sp,
                                    fontWeight = FontWeight.Black,
                                    letterSpacing = 1.sp,
                                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                                )
                            }
                        } else {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Text(
                                    text = "${String.format("%.1f", currentAngle)}°",
                                    fontSize = 38.sp,
                                    fontWeight = FontWeight.ExtraBold,
                                    color = Color.White
                                )
                                Spacer(modifier = Modifier.height(4.dp))
                                if (isPerfectPosition) {
                                    CircularProgressIndicator(
                                        progress = { autoCaptureProgress },
                                        modifier = Modifier.size(32.dp),
                                        color = Color(0xFF10B981),
                                        trackColor = Color(0x55FFFFFF),
                                        strokeWidth = 3.dp
                                    )
                                }
                            }
                        }

                        // Bottom HUD status text
                        Text(
                            text = when {
                                !isHandPresent -> "Align palm flat in center"
                                positionStatus == PalmPositionStatus.TOO_FAR -> "Bring palm closer to camera"
                                positionStatus == PalmPositionStatus.TOO_CLOSE -> "Move palm back slightly"
                                isPerfectPosition -> "Hold steady... Auto-capturing"
                                else -> "Adjust position"
                            },
                            color = Color.White,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Medium
                        )
                    }
                } else {
                    // Permission requested placeholder
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier.padding(24.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Info,
                            contentDescription = null,
                            tint = Color(0xFF4F46E5),
                            modifier = Modifier.size(64.dp)
                        )
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(
                            text = "Camera Permission Required",
                            color = Color.White,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Button(
                            onClick = onRequestPermission,
                            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF4F46E5))
                        ) {
                            Text("Grant Camera Access", fontSize = 12.sp)
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.weight(0.1f))

            // Bottom Floating Card matched with DAKSH AppTheme
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(24.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                border = BorderStroke(1.dp, Color(0xFFE2E8F0)),
                elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
            ) {
                Column(modifier = Modifier.padding(18.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column {
                            Text("Current ATD", fontSize = 11.sp, color = Color(0xFF64748B))
                            Text(
                                text = "${String.format("%.1f", currentAngle)}°",
                                fontSize = 28.sp,
                                fontWeight = FontWeight.ExtraBold,
                                color = if (isPerfectPosition) Color(0xFF10B981) else Color(0xFF4F46E5)
                            )
                        }

                        Column {
                            Text(
                                text = if (leftAngle != null) "● Left Hand" else "Left Hand",
                                fontSize = 11.sp,
                                color = if (leftAngle != null) Color(0xFF10B981) else Color(0xFF64748B),
                                fontWeight = FontWeight.Medium
                            )
                            Text(
                                text = leftAngle?.let { "${String.format("%.1f", it)}°" } ?: "—",
                                fontSize = 22.sp,
                                fontWeight = FontWeight.Bold,
                                color = if (leftAngle != null) Color(0xFF10B981) else Color(0xFF0F172A)
                            )
                        }

                        Column {
                            Text(
                                text = if (rightAngle != null) "● Right Hand" else "Right Hand",
                                fontSize = 11.sp,
                                color = if (rightAngle != null) Color(0xFF10B981) else Color(0xFF64748B),
                                fontWeight = FontWeight.Medium
                            )
                            Text(
                                text = rightAngle?.let { "${String.format("%.1f", it)}°" } ?: "—",
                                fontSize = 22.sp,
                                fontWeight = FontWeight.Bold,
                                color = if (rightAngle != null) Color(0xFF10B981) else Color(0xFF0F172A)
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    // Stepper row
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        StepIndicator(number = "1", label = "Show Left", active = step == CaptureStep.SHOW_LEFT, completed = leftAngle != null)
                        StepIndicator(number = "2", label = "Capture L", active = step == CaptureStep.SHOW_LEFT && currentAngle > 0, completed = leftAngle != null)
                        StepIndicator(number = "3", label = "Show Right", active = step == CaptureStep.SHOW_RIGHT, completed = rightAngle != null)
                        StepIndicator(number = "4", label = "Capture R", active = step == CaptureStep.SHOW_RIGHT && currentAngle > 0, completed = rightAngle != null)
                    }

                    Spacer(modifier = Modifier.height(18.dp))

                    // Auto-Detect Status Bar / CTA
                    when (step) {
                        CaptureStep.SHOW_LEFT -> {
                            Button(
                                onClick = onCaptureLeft,
                                enabled = isHandPresent && currentAngle > 0f,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(52.dp),
                                shape = RoundedCornerShape(16.dp),
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = Color(0xFF4F46E5),
                                    disabledContainerColor = Color(0xFFE2E8F0),
                                    disabledContentColor = Color(0xFF94A3B8)
                                )
                            ) {
                                Text(
                                    text = if (isPerfectPosition)
                                        "Auto-Capturing Left Palm (${String.format("%.1f", currentAngle)}°)"
                                    else if (isHandPresent)
                                        "Capture Left Palm (${String.format("%.1f", currentAngle)}°)"
                                    else
                                        "Point Rear Camera at Left Palm",
                                    fontSize = 15.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                        CaptureStep.SHOW_RIGHT -> {
                            Button(
                                onClick = onCaptureRight,
                                enabled = isHandPresent && currentAngle > 0f,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(52.dp),
                                shape = RoundedCornerShape(16.dp),
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = Color(0xFF7C3AED),
                                    disabledContainerColor = Color(0xFFE2E8F0),
                                    disabledContentColor = Color(0xFF94A3B8)
                                )
                            ) {
                                Text(
                                    text = if (isPerfectPosition)
                                        "Auto-Capturing Right Palm (${String.format("%.1f", currentAngle)}°)"
                                    else if (isHandPresent)
                                        "Capture Right Palm (${String.format("%.1f", currentAngle)}°)"
                                    else
                                        "Point Rear Camera at Right Palm",
                                    fontSize = 15.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                        CaptureStep.BOTH_CAPTURED -> {
                            Button(
                                onClick = onCalculateFinal,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(52.dp),
                                shape = RoundedCornerShape(16.dp),
                                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF10B981))
                            ) {
                                Text(
                                    text = "📊 Opening Results...",
                                    fontSize = 16.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                        else -> {}
                    }
                }
            }
        }
    }
}

@Composable
fun CameraPreview(
    cameraLensFacing: Int,
    onFrameAvailable: (Bitmap) -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current
    val mainExecutor = remember { ContextCompat.getMainExecutor(context) }
    var previewViewRef by remember { mutableStateOf<PreviewView?>(null) }

    DisposableEffect(cameraLensFacing, lifecycleOwner, previewViewRef) {
        val view = previewViewRef ?: return@DisposableEffect onDispose {}
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener({
            try {
                val cameraProvider = cameraProviderFuture.get()

                val preview = Preview.Builder().build().also {
                    it.setSurfaceProvider(view.surfaceProvider)
                }

                val imageAnalysis = ImageAnalysis.Builder()
                    .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                    .build()

                imageAnalysis.setAnalyzer(mainExecutor) { imageProxy ->
                    try {
                        val bitmap = imageProxy.toBitmap()
                        if (bitmap != null) {
                            val rotation = imageProxy.imageInfo.rotationDegrees
                            val finalBitmap = if (rotation != 0) {
                                val matrix = Matrix().apply { postRotate(rotation.toFloat()) }
                                Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
                            } else {
                                bitmap
                            }
                            onFrameAvailable(finalBitmap)
                        }
                    } catch (e: Exception) {
                        Log.e("PalmScan", "Error converting imageProxy to bitmap", e)
                    } finally {
                        imageProxy.close()
                    }
                }

                val cameraSelector = CameraSelector.Builder()
                    .requireLensFacing(cameraLensFacing)
                    .build()

                cameraProvider.unbindAll()
                cameraProvider.bindToLifecycle(
                    lifecycleOwner,
                    CameraSelector.DEFAULT_BACK_CAMERA,
                    preview,
                    imageAnalysis
                )
                Log.i("PalmScan", "Camera successfully bound to lifecycle with ImageAnalysis")
            } catch (e: Exception) {
                Log.e("PalmScan", "Camera binding failed", e)
            }
        }, mainExecutor)

        onDispose {
            try {
                val cameraProvider = cameraProviderFuture.get()
                cameraProvider.unbindAll()
                Log.d("PalmScan", "Camera unbound onDispose")
            } catch (e: Exception) {
                // Ignore if future was not ready
            }
        }
    }

    AndroidView(
        factory = { ctx ->
            PreviewView(ctx).apply {
                scaleType = PreviewView.ScaleType.FILL_CENTER
            }.also { previewViewRef = it }
        },
        modifier = modifier
    )
}

@Composable
fun StepIndicator(number: String, label: String, active: Boolean, completed: Boolean) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            modifier = Modifier
                .size(24.dp)
                .clip(CircleShape)
                .background(
                    when {
                        completed -> Color(0xFF0F9D58)
                        active -> Color(0xFFE57373)
                        else -> Color(0xFFE0E0E0)
                    }
                ),
            contentAlignment = Alignment.Center
        ) {
            if (completed) {
                Icon(Icons.Default.Check, contentDescription = null, tint = Color.White, modifier = Modifier.size(14.dp))
            } else {
                Text(number, color = if (active) Color.White else Color.Gray, fontSize = 11.sp, fontWeight = FontWeight.Bold)
            }
        }
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = label,
            fontSize = 9.sp,
            color = if (active || completed) Color(0xFF333333) else Color(0xFF9E9E9E),
            fontWeight = if (active) FontWeight.Bold else FontWeight.Normal
        )
    }
}
