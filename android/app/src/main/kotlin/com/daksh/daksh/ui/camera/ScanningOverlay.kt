package com.daksh.daksh.ui.camera

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.geometry.RoundRect
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import com.daksh.daksh.model.ScanStep


@Composable
fun ScanningOverlay(
    step: ScanStep,
    detectedFingertipOffset: Offset? = null,
    modifier: Modifier = Modifier
) {
    val infiniteTransition = rememberInfiniteTransition(label = "scan_line")
    val scanProgress by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1800, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "scan_progress"
    )

    val ringRadius by infiniteTransition.animateFloat(
        initialValue = 42f,
        targetValue = 54f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1000, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "ring_radius"
    )

    Box(modifier = modifier.fillMaxSize()) {
        Canvas(
            modifier = Modifier
                .fillMaxSize()
                .graphicsLayer { alpha = 0.99f }
        ) {
            val canvasWidth = size.width
            val canvasHeight = size.height

            // Semi-transparent background dimming
            drawRect(color = Color.Black.copy(alpha = 0.65f))

            val guideColor = if (detectedFingertipOffset != null) Color(0xFF00E676) else Color(0xFFFFD600) // Bright green when focused
            val accentColor = Color(0xFF00B0FF) // Light blue

            if (step.fingerCount == 1) {
                // Single Fingertip Precision Target Frame
                val frameWidth = canvasWidth * 0.50f
                val frameHeight = canvasHeight * 0.38f
                val left = (canvasWidth - frameWidth) / 2f
                val top = canvasHeight * 0.18f

                val rectPath = Path().apply {
                    addRoundRect(
                        RoundRect(
                            rect = Rect(left, top, left + frameWidth, top + frameHeight),
                            cornerRadius = CornerRadius(56f, 56f)
                        )
                    )
                }

                // Clear transparent lens hole for single Fingertip
                drawPath(
                    path = rectPath,
                    color = Color.Transparent,
                    blendMode = BlendMode.Clear
                )

                // Outer border
                drawPath(
                    path = rectPath,
                    color = guideColor,
                    style = Stroke(width = 6f, pathEffect = PathEffect.dashPathEffect(floatArrayOf(24f, 16f)))
                )

                // Laser Scanning Beam
                val scanY = top + (frameHeight * scanProgress)
                drawLine(
                    color = accentColor,
                    start = Offset(left + 20f, scanY),
                    end = Offset(left + frameWidth - 20f, scanY),
                    strokeWidth = 6f,
                    cap = StrokeCap.Round
                )
            } else {
                // 4-Fingers Cluster Target Frame
                val totalWidth = canvasWidth * 0.85f
                val frameHeight = canvasHeight * 0.42f
                val startX = (canvasWidth - totalWidth) / 2f
                val top = canvasHeight * 0.18f

                val slotWidth = totalWidth / 4f - 14f

                for (i in 0 until 4) {
                    val left = startX + i * (slotWidth + 14f) + 7f

                    val slotPath = Path().apply {
                        addRoundRect(
                            RoundRect(
                                rect = Rect(left, top, left + slotWidth, top + frameHeight),
                                cornerRadius = CornerRadius(36f, 36f)
                            )
                        )
                    }

                    drawPath(
                        path = slotPath,
                        color = Color.Transparent,
                        blendMode = BlendMode.Clear
                    )

                    drawPath(
                        path = slotPath,
                        color = guideColor,
                        style = Stroke(width = 5f, pathEffect = PathEffect.dashPathEffect(floatArrayOf(20f, 12f)))
                    )
                }

                // Laser Scanning Beam
                val scanY = top + (frameHeight * scanProgress)
                drawLine(
                    color = accentColor,
                    start = Offset(startX + 12f, scanY),
                    end = Offset(startX + totalWidth - 12f, scanY),
                    strokeWidth = 6f,
                    cap = StrokeCap.Round
                )
            }

            // Dynamic Active Fingertip Focus Ring
            if (detectedFingertipOffset != null) {
                drawCircle(
                    color = Color(0xFF00E676),
                    radius = ringRadius,
                    center = detectedFingertipOffset,
                    style = Stroke(width = 5f)
                )
                drawCircle(
                    color = Color(0xFF00E676).copy(alpha = 0.3f),
                    radius = ringRadius + 12f,
                    center = detectedFingertipOffset,
                    style = Stroke(width = 2f)
                )
            }
        }
    }
}
