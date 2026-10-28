package com.daksh.ml

import android.content.Context
import android.graphics.Bitmap
import org.tensorflow.lite.DataType
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.support.common.ops.CastOp
import org.tensorflow.lite.support.common.ops.NormalizeOp
import org.tensorflow.lite.support.image.ImageProcessor
import org.tensorflow.lite.support.image.TensorImage
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer
import kotlin.math.sqrt

class FourFingerDetector(
    private val context: Context,
    private val fourFingertipDetectorListener: FourFingertipDetectorListener
) {
    private var interpreter: Interpreter? = null
    private var status = false

    private val imageProcessor = ImageProcessor.Builder()
        .add(NormalizeOp(INPUT_MEAN, INPUT_STANDARD_DEVIATION))
        .add(CastOp(INPUT_IMAGE_TYPE))
        .build()

    fun setup() {
        if (interpreter != null) return
        val model = KeyManager.decryptModel3(context, "se571a8g5d7v5vleftIndexfesrg57n6")
        val options = Interpreter.Options()
        options.numThreads = 4
        interpreter = Interpreter(model, options)
    }

    fun clear() {
        interpreter?.close()
        interpreter = null
    }

    fun setIsDetecting(state: Boolean) {
        status = state
    }

    fun detect(frame: Bitmap) {
        if (!status) return
        interpreter ?: return
        val resizedBitmap = Bitmap.createScaledBitmap(frame, TENSOR_WIDTH, TENSOR_HEIGHT, false)
        val tensorImage = TensorImage(DataType.FLOAT32)
        tensorImage.load(resizedBitmap)
        val processedImage = imageProcessor.process(tensorImage)
        val imageBuffer = processedImage.buffer
        val output = TensorBuffer.createFixedSize(intArrayOf(1 , NUMBER_CHANNEL, NUM_ELEMENTS), OUTPUT_IMAGE_TYPE)
        interpreter?.run(imageBuffer, output.buffer)
        val boxes = bestBoxes(output.floatArray)
        if (boxes != null && boxes.size == 4) {
            val fourBoxes = boxes.sortedBy { it.cy }
            fourFingertipDetectorListener.onFourFingertipDetect(
                FourFingerBoundingBox(
                    index = fourBoxes[0],
                    middle = fourBoxes[1],
                    ring = fourBoxes[2],
                    little = fourBoxes[3],
                ), QualityUtils.getImageQuality(roi(frame, fourBoxes[1]))
            )
            return
        }
        fourFingertipDetectorListener.onFourFingertipEmpty()
    }


    fun extract(bitmap: Bitmap) : Pair<FourFingerBitmap, FourFingerBoundingBox>? {
        interpreter ?: return null
        val resizedBitmap = Bitmap.createScaledBitmap(bitmap, TENSOR_WIDTH, TENSOR_HEIGHT, false)
        val tensorImage = TensorImage(DataType.FLOAT32)
        tensorImage.load(resizedBitmap)
        val processedImage = imageProcessor.process(tensorImage)
        val imageBuffer = processedImage.buffer
        val output = TensorBuffer.createFixedSize(intArrayOf(1 , NUMBER_CHANNEL, NUM_ELEMENTS), OUTPUT_IMAGE_TYPE)
        interpreter?.run(imageBuffer, output.buffer)
        val boxes = bestBoxes(output.floatArray) ?: return null
        if (boxes.size == 4) {
            val fourBoxes = boxes.sortedBy { it.cy }
            val fourFingerBoundingBox= FourFingerBoundingBox(
                index = fourBoxes[0],
                middle = fourBoxes[1],
                ring = fourBoxes[2],
                little = fourBoxes[3],
            )
            return Pair(
                FourFingerBitmap(
                index = roi(bitmap, fourBoxes[0]),
                middle = roi(bitmap, fourBoxes[1]),
                ring = roi(bitmap, fourBoxes[2]),
                little = roi(bitmap, fourBoxes[3]),
            ), fourFingerBoundingBox)
        }
        return null
    }

    private fun roi(bitmap: Bitmap,  boundingBox: BoundingBox) : Bitmap {
        val x = (boundingBox.x1 * bitmap.width).toInt()
        val y = (boundingBox.y1 * bitmap.height).toInt()
        val w = (boundingBox.w * bitmap.width).toInt()
        val h = (boundingBox.h * bitmap.height).toInt()
        return Bitmap.createBitmap(bitmap, x, y, w, h)
    }

    private fun bestBoxes(array: FloatArray) : List<BoundingBox>? {
        val boundingBoxes = mutableListOf<BoundingBox>()
        for (c in 0 until NUM_ELEMENTS) {
            val cnf = array[c + NUM_ELEMENTS * 4]
            if (cnf > CONFIDENCE_THRESHOLD) {
                val cx = array[c]
                val cy = array[c + NUM_ELEMENTS]
                val w = array[c + NUM_ELEMENTS * 2]
                val h = array[c + NUM_ELEMENTS * 3]
                val x1 = cx - (w / 2F)
                val y1 = cy - (h / 2F)
                val x2 = cx + (w / 2F)
                val y2 = cy + (h / 2F)
                if (x1 <= 0F || x1 >= 1F) continue
                if (y1 <= 0F || y1 >= 1F) continue
                if (x2 <= 0F || x2 >= 1F) continue
                if (y2 <= 0F || y2 >= 1F) continue
                boundingBoxes.add(
                    BoundingBox(
                        x1 = x1, y1 = y1, x2 = x2, y2 = y2,
                        cx = cx, cy = cy, w = w, h = h, cnf = cnf
                    )
                )
            }
        }

        if (boundingBoxes.isEmpty()) return null
        return applyNMS(boundingBoxes)
    }

    private fun applyNMS(boxes: List<BoundingBox>) : List<BoundingBox> {
        val sortedBoxes = boxes.sortedByDescending { it.w * it.h }.toMutableList()
        val selectedBoxes = mutableListOf<BoundingBox>()
        while(sortedBoxes.isNotEmpty()) {
            val first = sortedBoxes.first()
            selectedBoxes.add(first)
            sortedBoxes.remove(first)
            val iterator = sortedBoxes.iterator()
            while (iterator.hasNext()) {
                val nextBox = iterator.next()
                val iou = calculateIoU(first, nextBox)
                if (iou >= IOU_THRESHOLD) {
                    iterator.remove()
                }
            }
        }
        return selectedBoxes
    }

    private fun calculateIoU(box1: BoundingBox, box2: BoundingBox): Float {
        val x1 = maxOf(box1.x1, box2.x1)
        val y1 = maxOf(box1.y1, box2.y1)
        val x2 = minOf(box1.x2, box2.x2)
        val y2 = minOf(box1.y2, box2.y2)
        val intersectionArea = maxOf(0F, x2 - x1) * maxOf(0F, y2 - y1)
        val box1Area = box1.w * box1.h
        val box2Area = box2.w * box2.h
        return intersectionArea / (box1Area + box2Area - intersectionArea)
    }

    interface FourFingertipDetectorListener {
        fun onFourFingertipEmpty()
        fun onFourFingertipDetect(fourFingerBoundingBox: FourFingerBoundingBox, quality: Double)
    }

    data class FourFingerBoundingBox(
        val index: BoundingBox,
        val middle: BoundingBox,
        val ring: BoundingBox,
        val little: BoundingBox
    )

    data class FourFingerBitmap(
        val index: Bitmap,
        val middle: Bitmap,
        val ring: Bitmap,
        val little: Bitmap
    )

    data class FourFingerFile(
        val index: String,
        val middle: String,
        val ring: String,
        val little: String
    )

    fun isFingersInsideCircle(fourFingerBoundingBox: FourFingerBoundingBox, fingerType4F: FingerType4F?) : Boolean {
        if (fingerType4F == FingerType4F.LEFT_HAND) {
            val index = isFingerInsideCircle(LEFT_INDEX_CENTER_X, LEFT_INDEX_CENTER_Y, fourFingerBoundingBox.index)
            val middle = isFingerInsideCircle(LEFT_MIDDLE_CENTER_X, LEFT_MIDDLE_CENTER_Y, fourFingerBoundingBox.middle)
            val ring = isFingerInsideCircle(LEFT_RING_CENTER_X, LEFT_RING_CENTER_Y, fourFingerBoundingBox.ring)
            val little = isFingerInsideCircle(LEFT_LITTLE_CENTER_X, LEFT_LITTLE_CENTER_Y, fourFingerBoundingBox.little)
            return index && middle && ring && little
        } else if (fingerType4F == FingerType4F.RIGHT_HAND) {
            val index = isFingerInsideCircle(RIGHT_INDEX_CENTER_X, RIGHT_INDEX_CENTER_Y, fourFingerBoundingBox.index)
            val middle = isFingerInsideCircle(RIGHT_MIDDLE_CENTER_X, RIGHT_MIDDLE_CENTER_Y, fourFingerBoundingBox.middle)
            val ring = isFingerInsideCircle(RIGHT_RING_CENTER_X, RIGHT_RING_CENTER_Y, fourFingerBoundingBox.ring)
            val little = isFingerInsideCircle(RIGHT_LITTLE_CENTER_X, RIGHT_LITTLE_CENTER_Y, fourFingerBoundingBox.little)
            return index && middle && ring && little
        }
        return false
    }

    private fun isFingerInsideCircle(x: Float, y: Float, b: BoundingBox) : Boolean {
        val dx = x - b.cx
        val dy = y - b.cy
        val d = sqrt(dx*dx + dy*dy)
        return d <= TIP_CENTER_D_THRESH
    }



    companion object {
        private const val TENSOR_WIDTH = 256
        private const val TENSOR_HEIGHT = 256

        private const val INPUT_MEAN = 0f
        private const val INPUT_STANDARD_DEVIATION = 255f

        private val INPUT_IMAGE_TYPE = DataType.FLOAT32
        private val OUTPUT_IMAGE_TYPE = DataType.FLOAT32

        private const val NUMBER_CHANNEL = 5
        private const val NUM_ELEMENTS = 1344
        private const val CONFIDENCE_THRESHOLD = 0.05F
        private const val IOU_THRESHOLD = 0.5F

        // 4F
        private const val LEFT_INDEX_CENTER_X = 0.52F
        private const val LEFT_INDEX_CENTER_Y = 0.09F
        private const val LEFT_MIDDLE_CENTER_X = 0.67F
        private const val LEFT_MIDDLE_CENTER_Y = 0.32F
        private const val LEFT_RING_CENTER_X = 0.62F
        private const val LEFT_RING_CENTER_Y = 0.53F
        private const val LEFT_LITTLE_CENTER_X = 0.5F
        private const val LEFT_LITTLE_CENTER_Y = 0.75F

        private const val RIGHT_INDEX_CENTER_X = 0.48F
        private const val RIGHT_INDEX_CENTER_Y = 0.09F
        private const val RIGHT_MIDDLE_CENTER_X = 0.33F
        private const val RIGHT_MIDDLE_CENTER_Y = 0.32F
        private const val RIGHT_RING_CENTER_X = 0.38F
        private const val RIGHT_RING_CENTER_Y = 0.53F
        private const val RIGHT_LITTLE_CENTER_X = 0.5F
        private const val RIGHT_LITTLE_CENTER_Y = 0.75F

        private const val TIP_CENTER_D_THRESH = 0.2F
    }

}