package com.daksh.ml

import android.content.Context
import android.graphics.Bitmap
import com.daksh.ml.MatUtils.multiplyDouble
import com.daksh.ml.MatUtils.toMat
import org.opencv.core.Core
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.MatOfPoint
import org.opencv.core.MatOfPoint2f
import org.opencv.core.Point
import org.opencv.core.Scalar
import org.opencv.core.Size
import org.opencv.imgproc.Imgproc
import org.tensorflow.lite.DataType
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.support.common.ops.CastOp
import org.tensorflow.lite.support.common.ops.NormalizeOp
import org.tensorflow.lite.support.image.ImageProcessor
import org.tensorflow.lite.support.image.TensorImage
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer

class InstanceSegmentation(private val context: Context)  {
    private var interpreter: Interpreter? = null

    private val imageProcessor = ImageProcessor.Builder()
        .add(NormalizeOp(INPUT_MEAN, INPUT_STANDARD_DEVIATION))
        .add(CastOp(INPUT_IMAGE_TYPE))
        .build()

    fun setup() {
        if (interpreter != null) return
        val model = KeyManager.decryptModel2(context, "sbycekxhtfesrg57bgse571a8g5d7v5v")
        val options = Interpreter.Options()
        interpreter = Interpreter(model, options)
    }

    fun clear() {
        interpreter?.close()
        interpreter = null
    }
    fun invoke(image: Bitmap) : Mat? {
        val interpreter = interpreter ?: return null
        val bitmap = ImageProcessUtils.createSquareBitmap(image)
        val resizedBitmap = Bitmap.createScaledBitmap(bitmap, TENSOR_WIDTH, TENSOR_HEIGHT, false)

        val tensor = TensorImage(DataType.FLOAT32)
        tensor.load(resizedBitmap)
        val processedImage = imageProcessor.process(tensor)
        val imageBuffer = arrayOf(processedImage.buffer)

        val coordinatesBuffer = TensorBuffer.createFixedSize(
            intArrayOf(BATCH_SIZE , NUM_CHANNELS, NUM_ELEMENTS),
            OUTPUT_IMAGE_TYPE
        )

        val maskProtoBuffer = TensorBuffer.createFixedSize(
            intArrayOf(BATCH_SIZE, X_POINTS, Y_POINTS, MASKS_NUMBERS),
            OUTPUT_IMAGE_TYPE
        )

        val outputBuffer = mapOf<Int, Any>(
            0 to coordinatesBuffer.buffer.rewind(),
            1 to maskProtoBuffer.buffer.rewind()
        )

        interpreter.runForMultipleInputsOutputs(imageBuffer, outputBuffer)

        val coordinates = coordinatesBuffer.floatArray
        val masks = maskProtoBuffer.floatArray

        val filterOutput0 = mutableListOf<Output0>()
        for (c in 0 until NUM_ELEMENTS) {
            val cnf = coordinates[c + NUM_ELEMENTS * 4]
            if (cnf > CONFIDENCE_THRESHOLD) {
                val cx = coordinates[c]
                val cy = coordinates[c + NUM_ELEMENTS]
                val w = coordinates[c + NUM_ELEMENTS * 2]
                val h = coordinates[c + NUM_ELEMENTS * 3]

                val x1 = cx - (w/2F)
                val y1 = cy - (h/2F)
                val x2 = cx + (w/2F)
                val y2 = cy + (h/2F)
                if (x1 < 0F || x1 > 1F) continue
                if (y1 < 0F || y1 > 1F) continue
                if (x2 < 0F || x2 > 1F) continue
                if (y2 < 0F || y2 > 1F) continue

                val maskWeight = mutableListOf<Float>()
                for (index in 0 until MASKS_NUMBERS) {
                    maskWeight.add(coordinates[c + NUM_ELEMENTS * (index + 5)])
                }
                filterOutput0.add(Output0(cx = cx, cy = cy, w = w, h = h, cnf = cnf, maskWeight = maskWeight))
            }
        }

        if (filterOutput0.isEmpty()) return null

        val best = applyNMS(filterOutput0).sortedByDescending { it.cnf }[0]

        val output1 = reshapeOutput1(masks)

        val multiply = mutableListOf<Mat>()
        for (index in 0 until MASKS_NUMBERS) {
            multiply.add(output1[index].multiplyDouble(best.maskWeight[index].toDouble()))
        }

        val final = multiply[0].clone()
        for (i in 1 until multiply.size) {
            Core.add(final, multiply[i], final)
        }

        val mask = Mat()
        Core.compare(final, Scalar(0.0), mask, Core.CMP_GT)

        val tl = Point((best.cx - best.w/2f).toDouble() * mask.rows(), (best.cy - best.h/2f).toDouble() * mask.cols())
        val br = Point((best.cx + best.w/2f).toDouble() * mask.rows(), (best.cy + best.h/2f).toDouble() * mask.cols())

        val rectangleMask = Mat.zeros(mask.size(), CvType.CV_8UC1)
        Imgproc.rectangle(rectangleMask, tl, br, Scalar(255.0), -1)

        val finalMask = Mat()
        Core.bitwise_and(mask, rectangleMask, finalMask)

        val bitmapSize = Size(bitmap.width.toDouble(), bitmap.height.toDouble())

        val resizedToOriginal = Mat()
        Imgproc.resize(finalMask, resizedToOriginal, bitmapSize)

        val bitmapMat = bitmap.toMat()

        val maskedOut = Mat()
        Core.bitwise_and(bitmapMat, bitmapMat, maskedOut, resizedToOriginal)

        return maskedOut
    }

    private fun later(mat: Mat): Mat {
        val thresh = Mat()
        Imgproc.threshold(mat, thresh, 127.0, 255.0, Imgproc.THRESH_BINARY)

        val contours = mutableListOf<MatOfPoint>()
        Imgproc.findContours(thresh, contours, Mat(), Imgproc.RETR_EXTERNAL, Imgproc.CHAIN_APPROX_SIMPLE)

        contours.sortByDescending { Imgproc.contourArea(it) }
        val largestAreaContour = contours[0]

        val contour2f = MatOfPoint2f()
        largestAreaContour.convertTo(contour2f, CvType.CV_32F)

        val epsilon = 0.02 * Imgproc.arcLength(contour2f, true)
        val approximatedContour = MatOfPoint2f()
        Imgproc.approxPolyDP(contour2f, approximatedContour, epsilon, true)

        val smoothedContour = MatOfPoint()
        approximatedContour.convertTo(smoothedContour, CvType.CV_32S)

        val mask = Mat.zeros(mat.size(), CvType.CV_8UC1)
        Imgproc.drawContours(mask, listOf(smoothedContour), -1, Scalar(255.0, 255.0, 255.0), -1)

        return mask
    }

    private fun reshapeOutput1(masks: FloatArray) : List<Mat> {
        val all = mutableListOf<Mat>()
        for (mask in 0 until MASKS_NUMBERS) {
            val mat = Mat(X_POINTS, Y_POINTS, CvType.CV_32F)
            for (x in 0 until X_POINTS) {
                for (y in 0 until Y_POINTS) {
                    mat.put(y, x, masks[ MASKS_NUMBERS * Y_POINTS *y + MASKS_NUMBERS *x + mask].toDouble())
                }
            }
            all.add(mat)
        }
        return all
    }

    private fun applyNMS(bestOutput0: List<Output0>): List<Output0> {
        val sortedBoxes = bestOutput0.sortedByDescending { it.cnf }.toMutableList()
        val selectedBoxes = mutableListOf<Output0>()

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

    private fun calculateIoU(b1: Output0, b2: Output0): Float {
        val x1 = maxOf(b1.cx - (b1.w/2F), b2.cx - (b2.w/2F))
        val y1 = maxOf(b1.cy - (b1.h/2F), b2.cy - (b2.h/2F))
        val x2 = minOf(b1.cx + (b1.w/2F), b2.cx + (b2.w/2F))
        val y2 = minOf(b1.cy + (b1.h/2F), b2.cy + (b2.h/2F))

        val intersectionArea = maxOf(0F, x2 - x1) * maxOf(0F, y2 - y1)
        val box1Area = b1.w * b1.h
        val box2Area = b2.w * b2.h
        return intersectionArea / (box1Area + box2Area - intersectionArea)
    }

    private data class Output0(
        val cx: Float,
        val cy: Float,
        val w: Float,
        val h: Float,
        val cnf: Float,
        val maskWeight: List<Float>
    )
    class NoOutputFound : Exception()

    companion object {
        private const val TENSOR_WIDTH = 640
        private const val TENSOR_HEIGHT = 640
        private const val INPUT_MEAN = 0f
        private const val INPUT_STANDARD_DEVIATION = 255f
        private val INPUT_IMAGE_TYPE = DataType.FLOAT32
        private val OUTPUT_IMAGE_TYPE = DataType.FLOAT32
        private const val NUM_ELEMENTS = 8400
        private const val NUM_CHANNELS = 37
        private const val BATCH_SIZE = 1
        private const val X_POINTS = 160
        private const val Y_POINTS = 160
        private const val MASKS_NUMBERS = 32
        private const val CONFIDENCE_THRESHOLD = 0.5F
        private const val IOU_THRESHOLD = 0.5F
    }
}