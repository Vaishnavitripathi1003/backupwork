package com.daksh.daksh.ui.camera

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.dp
import com.daksh.daksh.model.ScanStep

/**
 * Guide for the group scanner.
 *  - 4-finger steps: four dashed finger guides side by side
 *  - thumb steps:    one narrower guide
 * Proportions match FingerprintProcessor.processGroupImage / the ROI fallback crop
 * (78% width, 45% height, 28% from the top of the free space).
 *
 * Note: the guide matches the captured photo exactly only if the preview and the
 * photo have the same aspect ratio (otherwise FILL_CENTER crops a little).
 */
@Composable
fun GroupScanningOverlay(
    step: ScanStep,
    detectedFingertipOffset: Offset?,
    modifier: Modifier = Modifier
) {
    val isGroup = step.fingerCount > 1
    val guideColor = if (detectedFingertipOffset != null) Color(0xFF22C55E) else Color(0xFF00E5FF)

    Canvas(modifier = modifier.fillMaxSize()) {
        val w = size.width
        val h = size.height
        val dash = PathEffect.dashPathEffect(floatArrayOf(18f, 12f))
        val stroke = Stroke(width = 3.dp.toPx(), pathEffect = dash)

        if (isGroup) {
            val bandW = w * 0.78f
            val bandH = h * 0.45f
            val startX = (w - bandW) / 2f
            val startY = (h - bandH) * 0.28f
            val slice = bandW / 4f
            val pad = slice * 0.08f
            for (i in 0 until 4) {
                val gw = slice - 2 * pad
                drawRoundRect(
                    color = guideColor,
                    topLeft = Offset(startX + i * slice + pad, startY),
                    size = Size(gw, bandH),
                    cornerRadius = CornerRadius(gw / 2f),
                    style = stroke
                )
            }
        } else {
            val gw = w * 0.42f
            val gh = h * 0.45f
            drawRoundRect(
                color = guideColor,
                topLeft = Offset((w - gw) / 2f, (h - gh) * 0.28f),
                size = Size(gw, gh),
                cornerRadius = CornerRadius(gw / 2f),
                style = stroke
            )
        }

        detectedFingertipOffset?.let {
            drawCircle(color = guideColor.copy(alpha = 0.6f), radius = 10.dp.toPx(), center = it)
        }
    }
}
