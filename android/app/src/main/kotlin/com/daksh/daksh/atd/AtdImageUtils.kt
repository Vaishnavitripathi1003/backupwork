package com.daksh.daksh.atd

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import java.util.Locale

object AtdImageUtils {

    /**
     * Draws the ATD landmarks (Point T, Point A, Point D), connecting triangle lines,
     * and measured angle label directly onto a copy of the captured palm frame bitmap.
     */
    fun drawAtdOverlay(
        sourceBitmap: Bitmap,
        wrist: Point2D,
        indexA: Point2D,
        pinkyD: Point2D,
        angle: Float,
        handLabel: String = "Palm"
    ): Bitmap {
        val workingBitmap = sourceBitmap.copy(Bitmap.Config.ARGB_8888, true)
        val canvas = Canvas(workingBitmap)

        val w = workingBitmap.width.toFloat()
        val h = workingBitmap.height.toFloat()

        // Pixel coordinates from normalized 0..1 values
        val tx = (wrist.x * w).coerceIn(0f, w)
        val ty = (wrist.y * h).coerceIn(0f, h)

        val ax = (indexA.x * w).coerceIn(0f, w)
        val ay = (indexA.y * h).coerceIn(0f, h)

        val dx = (pinkyD.x * w).coerceIn(0f, w)
        val dy = (pinkyD.y * h).coerceIn(0f, h)

        // Paints for lines & points
        val strokeWidthPx = (w * 0.012f).coerceAtLeast(6f)

        val linePaintTA = Paint().apply {
            color = Color.parseColor("#FF5252") // Coral Red for T-A line
            strokeWidth = strokeWidthPx
            style = Paint.Style.STROKE
            isAntiAlias = true
        }

        val linePaintTD = Paint().apply {
            color = Color.parseColor("#00E676") // Green for T-D line
            strokeWidth = strokeWidthPx
            style = Paint.Style.STROKE
            isAntiAlias = true
        }

        val linePaintAD = Paint().apply {
            color = Color.parseColor("#FFD600") // Yellow for A-D line
            strokeWidth = strokeWidthPx
            style = Paint.Style.STROKE
            isAntiAlias = true
        }

        // Draw connecting ATD Triangle Lines
        canvas.drawLine(tx, ty, ax, ay, linePaintTA)
        canvas.drawLine(tx, ty, dx, dy, linePaintTD)
        canvas.drawLine(ax, ay, dx, dy, linePaintAD)

        // Point Markers Paints
        val pointRadiusPx = (w * 0.025f).coerceAtLeast(14f)

        val pointPaintT = Paint().apply {
            color = Color.parseColor("#FF1744")
            style = Paint.Style.FILL
            isAntiAlias = true
        }

        val pointPaintA = Paint().apply {
            color = Color.parseColor("#00B0FF")
            style = Paint.Style.FILL
            isAntiAlias = true
        }

        val pointPaintD = Paint().apply {
            color = Color.parseColor("#AA00FF")
            style = Paint.Style.FILL
            isAntiAlias = true
        }

        val pointBorderPaint = Paint().apply {
            color = Color.WHITE
            style = Paint.Style.STROKE
            strokeWidth = strokeWidthPx * 0.6f
            isAntiAlias = true
        }

        // Text Paint for Labels
        val textSizePx = (w * 0.045f).coerceAtLeast(24f)
        val textPaint = Paint().apply {
            color = Color.WHITE
            textSize = textSizePx
            isFakeBoldText = true
            isAntiAlias = true
        }

        val bgTextPaint = Paint().apply {
            color = Color.parseColor("#99000000")
            style = Paint.Style.FILL
            isAntiAlias = true
        }

        // Draw Landmark Circles: T, A, D
        // Point T (Wrist / Axial Triradius)
        canvas.drawCircle(tx, ty, pointRadiusPx, pointPaintT)
        canvas.drawCircle(tx, ty, pointRadiusPx, pointBorderPaint)
        drawPointLabel(canvas, "Point T (Wrist)", tx, ty + pointRadiusPx + textSizePx, textPaint, bgTextPaint)

        // Point A (Index MCP)
        canvas.drawCircle(ax, ay, pointRadiusPx, pointPaintA)
        canvas.drawCircle(ax, ay, pointRadiusPx, pointBorderPaint)
        drawPointLabel(canvas, "Point A (Index)", ax, ay - pointRadiusPx - 8f, textPaint, bgTextPaint)

        // Point D (Pinky MCP)
        canvas.drawCircle(dx, dy, pointRadiusPx, pointPaintD)
        canvas.drawCircle(dx, dy, pointRadiusPx, pointBorderPaint)
        drawPointLabel(canvas, "Point D (Pinky)", dx, dy - pointRadiusPx - 8f, textPaint, bgTextPaint)

        // Draw Angle Badge over Point T
        val angleText = "ATD Angle: ${String.format(Locale.getDefault(), "%.1f", angle)}°"
        val angleTextWidth = textPaint.measureText(angleText)
        val rectPadding = 16f
        val angleRect = RectF(
            tx - angleTextWidth / 2f - rectPadding,
            ty - pointRadiusPx - textSizePx * 1.8f - rectPadding,
            tx + angleTextWidth / 2f + rectPadding,
            ty - pointRadiusPx - rectPadding
        )
        val rectPaint = Paint().apply {
            color = Color.parseColor("#D32F2F")
            style = Paint.Style.FILL
            isAntiAlias = true
        }
        canvas.drawRoundRect(angleRect, 16f, 16f, rectPaint)
        canvas.drawText(
            angleText,
            tx - angleTextWidth / 2f,
            ty - pointRadiusPx - textSizePx * 0.8f,
            textPaint
        )

        return workingBitmap
    }

    private fun drawPointLabel(
        canvas: Canvas,
        text: String,
        cx: Float,
        cy: Float,
        textPaint: Paint,
        bgPaint: Paint
    ) {
        val textWidth = textPaint.measureText(text)
        val textHeight = textPaint.textSize
        val rect = RectF(
            cx - textWidth / 2f - 10f,
            cy - textHeight + 4f,
            cx + textWidth / 2f + 10f,
            cy + 8f
        )
        canvas.drawRoundRect(rect, 10f, 10f, bgPaint)
        canvas.drawText(text, cx - textWidth / 2f, cy, textPaint)
    }
}
