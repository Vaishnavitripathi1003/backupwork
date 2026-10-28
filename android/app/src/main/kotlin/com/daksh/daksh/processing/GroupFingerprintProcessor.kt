/*
package com.daksh.daksh.processing

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.RectF
import android.util.Log
import com.daksh.daksh.model.EnhancedImageResult
import com.daksh.daksh.model.ScanStep
import org.opencv.android.Utils
import org.opencv.core.Core
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.MatOfPoint
import org.opencv.core.Scalar
import org.opencv.core.Size
import org.opencv.imgproc.Imgproc
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min

*/
/** Group capture ka poora output: 4 finger results + tips pe border wali photo. *//*

data class GroupScanOutput(
    val results: List<EnhancedImageResult>,
    */
/** Photo ka wo hissa jahan fingertips hain, har tip ke around border ke saath. *//*

    val annotatedPhoto: Bitmap?,
    */
/** true = tips actually detect hue, false = guide slices ka fallback use hua. *//*

    val usedDetection: Boolean
)

*/
/**
 * Group (4-finger) processing.
 *
 * 1. Photo mein hand ko skin-colour se alag karta hai.
 * 2. Hand ke upar ke edge se 4 fingertips (peaks) dhundta hai.
 * 3. Har tip ke around crop karke single-finger pipeline chalata hai.
 * 4. Tips detect na ho to guide ke 4 equal slices pe fallback.
 *
 * Logcat filter: tag:GROUP_FP_PROC
 *//*

object GroupFingerprintProcessor {

    private const val TAG = "GROUP_FP_PROC"

    // Overlay aur fallback dono yahi values use karte hain (single source of truth)
    const val GUIDE_WIDTH_FRAC = 0.78f   // 4-finger guide ki chaudai (frame ka %)
    const val GUIDE_HEIGHT_FRAC = 0.28f  // sirf tip area, poori ungli nahi
    const val GUIDE_TOP_FRAC = 0.28f     // free space ka kitna hissa upar chhodna hai
    const val THUMB_WIDTH_FRAC = 0.42f

    private class Tip(val cx: Float, val top: Float, val width: Float)

    fun process(
        context: Context,
        inputBitmap: Bitmap,
        step: ScanStep,
        mirrored: Boolean = false
    ): GroupScanOutput =
        if (step.fingerCount > 1) {
            processGroup(context, inputBitmap, step, mirrored)
        } else {
            GroupScanOutput(
                results = listOf(FingerprintProcessor.processAndEnhanceImage(context, inputBitmap, step)),
                annotatedPhoto = null,
                usedDetection = false
            )
        }

    fun processGroup(
        context: Context,
        input: Bitmap,
        groupStep: ScanStep,
        mirrored: Boolean = false
    ): GroupScanOutput {
        val fingerSteps = fingerStepsFor(groupStep).let { if (mirrored) it.reversed() else it }
        val w = input.width
        val h = input.height
        Log.i(TAG, "GROUP START ${groupStep.name} mirrored=$mirrored input=${w}x$h")

        val tips = try {
            detectFingertips(input, 4)
        } catch (t: Throwable) {
            Log.e(TAG, "Tip detection EXCEPTION -> ${t.javaClass.simpleName}: ${t.message}", t)
            null
        }

        val crops = ArrayList<Bitmap>()
        val boxes = ArrayList<Rect>()

        if (tips != null) {
            Log.i(TAG, "Tips detected -> ${tips.map { "(x=${it.cx.toInt()}, y=${it.top.toInt()})" }}")
            for (tip in tips) {
                val fw = tip.width
                val cropW = min((fw * 1.5f).toInt(), w).coerceAtLeast(8)
                val cropH = min((cropW * 1.4f).toInt(), h).coerceAtLeast(8)
                val x = (tip.cx - cropW / 2f).toInt().coerceIn(0, w - cropW)
                val y = (tip.top - 0.22f * cropH).toInt().coerceIn(0, h - cropH)
                crops += Bitmap.createBitmap(input, x, y, cropW, cropH)

                val bx = (tip.cx - fw / 2f).toInt().coerceIn(0, w - 2)
                val by = tip.top.toInt().coerceIn(0, h - 2)
                boxes += Rect(
                    bx, by,
                    (bx + fw).toInt().coerceIn(bx + 1, w),
                    (by + fw * 1.1f).toInt().coerceIn(by + 1, h)
                )
            }
        } else {
            Log.w(TAG, "Tips NOT detected -> guide slices fallback")
            val bandW = (w * GUIDE_WIDTH_FRAC).toInt()
            val bandH = (h * GUIDE_HEIGHT_FRAC).toInt()
            val startX = ((w - bandW) / 2).coerceIn(0, w - bandW)
            val startY = ((h - bandH) * GUIDE_TOP_FRAC).toInt().coerceIn(0, h - bandH)
            val sliceW = bandW / 4
            for (i in 0 until 4) {
                crops += Bitmap.createBitmap(input, startX + i * sliceW, startY, sliceW, bandH)
                boxes += Rect(startX + i * sliceW, startY, startX + (i + 1) * sliceW, startY + bandH)
            }
        }

        val results = fingerSteps.mapIndexed { i, fingerStep ->
            Log.d(TAG, "finger $i -> ${fingerStep.name} crop=${crops[i].width}x${crops[i].height}")
            FingerprintProcessor.processAndEnhanceImage(context, crops[i], fingerStep)
        }

        val annotated = try {
            annotate(input, boxes)
        } catch (t: Throwable) {
            Log.e(TAG, "annotate FAILED -> ${t.message}", t)
            null
        }
        Log.i(TAG, "GROUP DONE ${results.size} fingers, detection=${tips != null}")
        return GroupScanOutput(results, annotated, tips != null)
    }

    // ------------------------------------------------------------------
    // Fingertip detection: skin mask -> hand ka top edge -> 4 peaks
    // ------------------------------------------------------------------
    private fun detectFingertips(src: Bitmap, count: Int): List<Tip>? {
        val scale = if (src.width > 480) 480f / src.width else 1f
        val sw = (src.width * scale).toInt()
        val sh = (src.height * scale).toInt()
        val small = Bitmap.createScaledBitmap(src, sw, sh, true)

        val rgba = Mat()
        Utils.bitmapToMat(small, rgba)
        val rgb = Mat()
        Imgproc.cvtColor(rgba, rgb, Imgproc.COLOR_RGBA2RGB)
        val ycrcb = Mat()
        Imgproc.cvtColor(rgb, ycrcb, Imgproc.COLOR_RGB2YCrCb)
        val mask = Mat()
        Core.inRange(ycrcb, Scalar(0.0, 133.0, 77.0), Scalar(255.0, 173.0, 127.0), mask)

        val kernel = Imgproc.getStructuringElement(Imgproc.MORPH_ELLIPSE, Size(7.0, 7.0))
        Imgproc.morphologyEx(mask, mask, Imgproc.MORPH_CLOSE, kernel)
        Imgproc.morphologyEx(mask, mask, Imgproc.MORPH_OPEN, kernel)

        // Sirf sabse bada skin blob (hand) rakho
        val contours = ArrayList<MatOfPoint>()
        Imgproc.findContours(mask, contours, Mat(), Imgproc.RETR_EXTERNAL, Imgproc.CHAIN_APPROX_SIMPLE)
        if (contours.isEmpty()) {
            Log.w(TAG, "detect: no skin contour")
            return null
        }
        val biggest = contours.maxByOrNull { Imgproc.contourArea(it) }!!
        val clean = Mat.zeros(mask.size(), CvType.CV_8UC1)
        Imgproc.drawContours(clean, listOf(biggest), -1, Scalar(255.0), -1)

        val bytes = ByteArray(sw * sh)
        clean.get(0, 0, bytes)

        // Har column ka sabse upar wala skin pixel
        val raw = IntArray(sw) { sh }
        for (x in 0 until sw) {
            for (y in 0 until sh) {
                if (bytes[y * sw + x].toInt() != 0) { raw[x] = y; break }
            }
        }
        val xs = (0 until sw).filter { raw[it] < sh }
        if (xs.isEmpty()) return null
        val extent = xs.last() - xs.first() + 1
        if (extent < sw * 0.25f) {
            Log.w(TAG, "detect: hand too narrow extent=$extent sw=$sw")
            return null
        }

        // Smooth karke peaks (sabse upar wale points) chuno
        val win = max(3, sw / 60)
        val sm = FloatArray(sw) { i ->
            var s = 0f
            var n = 0
            for (k in (i - win)..(i + win)) {
                s += raw[k.coerceIn(0, sw - 1)]
                n++
            }
            s / n
        }
        val fw = extent / count.toFloat()
        val picked = ArrayList<Int>()
        for (x in xs.sortedBy { sm[it] }) {
            if (picked.all { abs(it - x) >= fw * 0.7f }) picked += x
            if (picked.size == count) break
        }
        if (picked.size < count) {
            Log.w(TAG, "detect: only ${picked.size} peaks")
            return null
        }
        picked.sort()
        for (i in 1 until picked.size) {
            val d = picked[i] - picked[i - 1]
            if (d < fw * 0.5f || d > fw * 1.7f) {
                Log.w(TAG, "detect: uneven spacing d=$d fw=$fw")
                return null
            }
        }

        return picked.map { Tip(it / scale, sm[it] / scale, fw / scale) }
    }

    // ------------------------------------------------------------------
    // Photo ka tip wala hissa crop karke har tip ke around border
    // ------------------------------------------------------------------
    private fun annotate(src: Bitmap, boxes: List<Rect>): Bitmap {
        val avgW = boxes.map { it.width() }.average().toFloat()
        val pad = (avgW * 0.35f).toInt()
        val ux = (boxes.minOf { it.left } - pad).coerceAtLeast(0)
        val uy = (boxes.minOf { it.top } - pad).coerceAtLeast(0)
        val ur = (boxes.maxOf { it.right } + pad).coerceAtMost(src.width)
        val ub = (boxes.maxOf { it.bottom } + pad).coerceAtMost(src.height)

        val cropped = Bitmap.createBitmap(src, ux, uy, ur - ux, ub - uy)
        val k = if (cropped.width > 1000) 1000f / cropped.width else 1f
        val out = Bitmap.createScaledBitmap(
            cropped, (cropped.width * k).toInt(), (cropped.height * k).toInt(), true
        ).copy(Bitmap.Config.ARGB_8888, true)

        val canvas = Canvas(out)
        val stroke = max(3f, out.width / 160f)
        val boxPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = stroke
            color = Color.rgb(34, 197, 94)
        }
        val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textSize = max(18f, out.width / 28f)
            isFakeBoldText = true
            setShadowLayer(4f, 0f, 0f, Color.BLACK)
        }
        boxes.forEachIndexed { i, b ->
            val r = RectF((b.left - ux) * k, (b.top - uy) * k, (b.right - ux) * k, (b.bottom - uy) * k)
            canvas.drawRoundRect(r, r.width() / 2f, r.width() / 2f, boxPaint)
            canvas.drawText("${i + 1}", r.left + stroke * 2, r.top - stroke * 2 + textPaint.textSize, textPaint)
        }
        return out
    }

    */
/** 4 enhanced bitmaps ko side-by-side jodta hai (capturedMap preview ke liye). *//*

    fun stitchPreview(bitmaps: List<Bitmap>): Bitmap {
        if (bitmaps.isEmpty()) return Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888)
        val cellH = bitmaps.maxOf { it.height }
        val cellWs = bitmaps.map { (it.width * (cellH.toFloat() / it.height)).toInt() }
        val out = Bitmap.createBitmap(cellWs.sum(), cellH, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(out)
        var x = 0
        bitmaps.forEachIndexed { i, b ->
            canvas.drawBitmap(b, null, Rect(x, 0, x + cellWs[i], cellH), null)
            x += cellWs[i]
        }
        return out
    }

    private fun fingerStepsFor(groupStep: ScanStep): List<ScanStep> = when (groupStep) {
        ScanStep.LEFT_FOUR_FINGERS_GROUP -> listOf(
            ScanStep.LEFT_LITTLE_IND, ScanStep.LEFT_RING_IND,
            ScanStep.LEFT_MIDDLE_IND, ScanStep.LEFT_INDEX_IND
        )
        ScanStep.RIGHT_FOUR_FINGERS_GROUP -> listOf(
            ScanStep.RIGHT_INDEX_IND, ScanStep.RIGHT_MIDDLE_IND,
            ScanStep.RIGHT_RING_IND, ScanStep.RIGHT_LITTLE_IND
        )
        else -> throw IllegalArgumentException("Not a four-finger group step: ${groupStep.name}")
    }
}*/
