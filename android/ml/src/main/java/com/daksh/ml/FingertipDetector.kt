package com.daksh.ml

import android.content.ContentValues.TAG
import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import com.daksh.ml.KeyManager.decryptModel
import com.daksh.ml.QualityUtils.getImageQuality
import org.tensorflow.lite.DataType
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.support.common.ops.CastOp
import org.tensorflow.lite.support.common.ops.NormalizeOp
import org.tensorflow.lite.support.image.ImageProcessor
import org.tensorflow.lite.support.image.TensorImage
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer
import kotlin.math.min
import kotlin.math.sqrt

class FingertipDetector(
    private val context: Context,
    private val fingertipDetectorListener: FingertipDetectorListener,
    private var cnfThreshold: Float = 0.05F
) {
    val X = "leftIndexfesrg57n6se57nebrsd7v5v"
    private var interpreter: Interpreter? = null
    private var status = false

    private val imageProcessor = ImageProcessor.Builder()
        .add(NormalizeOp(INPUT_MEAN, INPUT_STANDARD_DEVIATION))
        .add(CastOp(INPUT_IMAGE_TYPE))
        .build()

    fun setup() {
        if (interpreter != null) return

//        val compatList = CompatibilityList()

        val options = Interpreter.Options().apply{
//            if(compatList.isDelegateSupportedOnThisDevice){
//                val delegateOptions = compatList.bestOptionsForThisDevice
//                this.addDelegate(GpuDelegate(delegateOptions))
//            } else {
            this.setNumThreads(4)
//            }
        }

        val model = decryptModel(context, X)

        interpreter = Interpreter(model, options)
    }

    fun clear() {
        interpreter?.close()
        interpreter = null
    }

    fun setIsDetecting(state: Boolean) {
        status = state
    }

    private var squareSize = 0
    private var left = 0
    private var top = 0

    fun detect(frame: Bitmap) {
        if (!status) return
        interpreter ?: return
        if (squareSize == 0) {
            squareSize = min(frame.width, frame.height)
            left = (frame.width - squareSize) / 2
            top = (frame.height - squareSize) / 2
        }
        val croppedBitmap = Bitmap.createBitmap(frame, left, top, squareSize, squareSize)
        val resizedBitmap = Bitmap.createScaledBitmap(croppedBitmap, TENSOR_WIDTH, TENSOR_HEIGHT, false)
        val tensorImage = TensorImage(DataType.FLOAT32)
        tensorImage.load(resizedBitmap)
        val processedImage = imageProcessor.process(tensorImage)
        val imageBuffer = processedImage.buffer
        val output = TensorBuffer.createFixedSize(intArrayOf(1 , 5, NUM_ELEMENTS), OUTPUT_IMAGE_TYPE)
        interpreter?.run(imageBuffer, output.buffer)
        val bestBox = bestBox(output.floatArray)
        if (bestBox == null) {
            fingertipDetectorListener.onFingertipEmpty()
            return
        }

        val roi = roi(croppedBitmap, bestBox)
        val pixelQuality = getImageQuality(roi)
//        fingertipDetectorListener.onPixelQuality(pixelQuality)

        fingertipDetectorListener.onFingertipDetect(
            BoundingBoxRatio(
                bestBox.cx / TENSOR_WIDTH_FLOAT,
                bestBox.cy / TENSOR_HEIGHT_FLOAT,
                bestBox.w / TENSOR_WIDTH_FLOAT,
                bestBox.h / TENSOR_HEIGHT_FLOAT
            )
            , pixelQuality
        )
    }

    private val tensorImageExtraction = TensorImage(DataType.FLOAT32)
    fun extractFingertip(image: Bitmap) : Pair<Bitmap, BoundingBoxRatio>? {
        Log.w(TAG, "button clicked}${image.byteCount}")
        interpreter ?: return null
        val iSquareSize = min(image.width, image.height)
        val iLeft = (image.width - iSquareSize) / 2
        val iTop = (image.height - iSquareSize) / 2
        val croppedBitmap = Bitmap.createBitmap(image, iLeft, iTop, iSquareSize, iSquareSize)
        val resizedBitmap = Bitmap.createScaledBitmap(croppedBitmap, TENSOR_WIDTH, TENSOR_HEIGHT, false)
        tensorImageExtraction.load(resizedBitmap)
        val processedImage = imageProcessor.process(tensorImageExtraction)
        val imageBuffer = processedImage.buffer
        val output = TensorBuffer.createFixedSize(intArrayOf(1 , 5, NUM_ELEMENTS) , OUTPUT_IMAGE_TYPE)
        interpreter?.run(imageBuffer, output.buffer)
        val bestBox = bestBox(output.floatArray) ?: return null
        val boundingBoxRatio = BoundingBoxRatio(
            bestBox.cx / TENSOR_WIDTH_FLOAT,
            bestBox.cy / TENSOR_HEIGHT_FLOAT,
            bestBox.w / TENSOR_WIDTH_FLOAT,
            bestBox.h / TENSOR_HEIGHT_FLOAT
        )
        println("bound"+boundingBoxRatio)
        return try {
            Pair(roi(croppedBitmap, bestBox), boundingBoxRatio)
        } catch (e: Exception) {
            Log.w(TAG, "button clicked}${e.toString()}")
            null
        }
    }

    private fun roi(bitmap: Bitmap,  boundingBox: BoundingBox) : Bitmap {
        val x = ((boundingBox.x1 / TENSOR_WIDTH_FLOAT) * bitmap.width).toInt()
        val y = ((boundingBox.y1 / TENSOR_HEIGHT_FLOAT) * bitmap.height).toInt()
        val w = ((boundingBox.w / TENSOR_WIDTH_FLOAT) * bitmap.width).toInt()
        val h = ((boundingBox.h / TENSOR_HEIGHT_FLOAT) * bitmap.height).toInt()
        return Bitmap.createBitmap(bitmap, x, y, w, h)
    }

    private fun bestBox(array: FloatArray) : BoundingBox? {
        val boundingBoxes = mutableListOf<BoundingBox>()
        for (c in 0 until NUM_ELEMENTS) {
            val cnf = array[c + NUM_ELEMENTS * 4]
            if (cnf > cnfThreshold) {
                val cx = array[c]
                val cy = array[c + NUM_ELEMENTS]
                val w = array[c + NUM_ELEMENTS * 2]
                val h = array[c + NUM_ELEMENTS * 3]
                val x1 = cx - (w/2F)
                val y1 = cy - (h/2F)
                val x2 = cx + (w/2F)
                val y2 = cy + (h/2F)
                if (x1 <= 0F || x1 >= TENSOR_WIDTH_FLOAT) continue
                if (y1 <= 0F || y1 >= TENSOR_HEIGHT_FLOAT) continue
                if (x2 <= 0F || x2 >= TENSOR_WIDTH_FLOAT) continue
                if (y2 <= 0F || y2 >= TENSOR_HEIGHT_FLOAT) continue
                boundingBoxes.add(
                    BoundingBox(
                    x1 = x1, y1 = y1, x2 = x2, y2 = y2,
                    cx = cx, cy = cy, w = w, h = h, cnf = cnf
                )
                )
            }
        }

        if (boundingBoxes.isEmpty()) return null

        val bestBoxes = applyNMS(boundingBoxes)
        bestBoxes.sortBy {
            val dx = it.cx - TENSOR_CENTER_X
            val dy = it.cy - TENSOR_CENTER_Y
            sqrt(dx*dx + dy*dy)
        }

        return bestBoxes[0]
    }

    private fun applyNMS(boxes: List<BoundingBox>) : MutableList<BoundingBox> {
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

    fun thumbDistanceGood(boundingBoxRatio: BoundingBoxRatio, min: Float, max: Float) : Boolean {
        val area = boundingBoxRatio.w * boundingBoxRatio.h
        return area in min..max
    }

    interface FingertipDetectorListener {
        fun onFingertipEmpty()
        fun onFingertipDetect(boundingBoxRatio: BoundingBoxRatio, quality: Double)
    }

    companion object {
        private const val TENSOR_WIDTH = 256
        private const val TENSOR_HEIGHT = 256
        private const val TENSOR_WIDTH_FLOAT = TENSOR_WIDTH.toFloat()
        private const val TENSOR_HEIGHT_FLOAT = TENSOR_HEIGHT.toFloat()
        private const val TENSOR_CENTER_X = TENSOR_WIDTH_FLOAT / 2F
        private const val TENSOR_CENTER_Y = TENSOR_HEIGHT_FLOAT / 2F

        private const val INPUT_MEAN = 0f
        private const val INPUT_STANDARD_DEVIATION = 255f

        private val INPUT_IMAGE_TYPE = DataType.FLOAT32
        private val OUTPUT_IMAGE_TYPE = DataType.FLOAT32

        private const val NUM_ELEMENTS = 1344
//        private const val CONFIDENCE_THRESHOLD = 0.75F
        private const val IOU_THRESHOLD = 0.5F
    }
}