package com.daksh.daksh.processing

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Rect
import android.util.Log
import com.daksh.daksh.model.EnhancedImageResult
import com.daksh.daksh.model.ScanStep

/**
 * Group (4-finger) fingerprint processing.
 *
 * Ek hi photo -> 4 fingertip slices -> har slice pe single-finger pipeline
 * (FingerprintProcessor.processAndEnhanceImage) -> 4 alag EnhancedImageResult.
 *
 * Har result ka `step` uski apni finger step hota hai (e.g. LEFT_LITTLE_IND),
 * isliye bind karte waqt har finger apni sahi jagah jayegi.
 */
object GroupFingerprintProcessor {

    private const val TAG = "GROUP_FP_PROC"

    /**
     * Entry point: group step ho to 4 results, single step ho to 1 result.
     */
    fun process(
        context: Context,
        inputBitmap: Bitmap,
        step: ScanStep,
        mirrored: Boolean = false
    ): List<EnhancedImageResult> =
        if (step.fingerCount > 1) {
            processGroupImage(context, inputBitmap, step, mirrored)
        } else {
            listOf(FingerprintProcessor.processAndEnhanceImage(context, inputBitmap, step))
        }

    /**
     * @param mirrored true karo agar finger order ulta aa raha ho
     *                 (galat finger ke naam pe result bind ho raha ho).
     * @return 4 results, left -> right order mein.
     */
    fun processGroupImage(
        context: Context,
        inputBitmap: Bitmap,
        groupStep: ScanStep,
        mirrored: Boolean = false
    ): List<EnhancedImageResult> {
        val fingerSteps = fingerStepsFor(groupStep).let { if (mirrored) it.reversed() else it }

        Log.i(TAG, "GROUP START: ${groupStep.name} mirrored=$mirrored ${inputBitmap.width}x${inputBitmap.height}")

        // Central band jahan 4 fingertips hote hain (overlay jaisi hi proportions)
        val w = inputBitmap.width
        val h = inputBitmap.height
        val bandW = (w * 0.78f).toInt()
        val bandH = (h * 0.45f).toInt()
        val startX = ((w - bandW) / 2).coerceIn(0, w - bandW)
        val startY = ((h - bandH) * 0.28f).toInt().coerceIn(0, h - bandH)
        val band = Bitmap.createBitmap(inputBitmap, startX, startY, bandW, bandH)
        val sliceW = bandW / 4

        return fingerSteps.mapIndexed { i, fingerStep ->
            val slice = Bitmap.createBitmap(band, i * sliceW, 0, sliceW, bandH)
            Log.d(TAG, "slice $i -> ${fingerStep.name} ${slice.width}x${slice.height}")
            FingerprintProcessor.processAndEnhanceImage(context, slice, fingerStep)
        }.also { Log.i(TAG, "GROUP DONE: ${it.size} fingers processed") }
    }

    /** 4 enhanced bitmaps ko side-by-side jod kar ek preview bitmap banata hai. */
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
}
