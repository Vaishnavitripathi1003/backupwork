package com.daksh.ml

import org.opencv.core.Core
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.MatOfFloat
import org.opencv.core.MatOfInt
import org.opencv.core.Rect
import org.opencv.core.Scalar
import org.opencv.core.Size
import org.opencv.imgproc.Imgproc
import kotlin.math.max
import kotlin.math.min

object FilterUtils {
    fun skinExtraction(matX: Mat) : Mat {
        val trfResult = Mat()
        val gtzResult = Mat()

        val rgb8 = Mat()
        Imgproc.cvtColor(matX, rgb8, Imgproc.COLOR_RGBA2RGB)

        val img = Mat()
        rgb8.convertTo(img, CvType.CV_32F)

        val mask00 = Mat()
        mask00.setTo(Scalar(0.0))

        val mask01 = Mat()
        mask01.setTo(Scalar(0.0))

        val mask1 = Mat()
        mask1.setTo(Scalar(0.0))

        val mask2 = Mat()
        mask2.setTo(Scalar(0.0))

        val c00: Mat = MatUtils.convertListToMat(
            arrayOf(
                floatArrayOf(1.0f, 0.0f, 0.0f, -95.0f),
                floatArrayOf(0.0f, 1.0f, 0.0f, -40.0f),
                floatArrayOf(0.0f, 0.0f, 1.0f, -20.0f),
                floatArrayOf(1.0f, -1.0f, 0.0f, 0.0f),
                floatArrayOf(1.0f, 0.0f, -1.0f, 0.0f)
            )
        )

        val c01: Mat = MatUtils.convertListToMat(
            arrayOf(
                floatArrayOf(1.0f, -1.0f, 0.0f, -15.0f),
                floatArrayOf(-1.0f, 1.0f, 0.0f, -15.0f)
            )
        )

        val c1: Mat = MatUtils.convertListToMat(
            arrayOf(
                floatArrayOf(50.0f, -60.0f, 10.0f, 0.0f),
                floatArrayOf(0.77f, 0.0f, -1.0f, 0.0f),
                floatArrayOf(-0.32f, 0.0f, 1.0f, 0.0f)
            )
        )

        val c2: Mat = MatUtils.convertListToMat(
            arrayOf(
                floatArrayOf(0.499813f, -0.418531f, -0.081282f, -7.0f),
                floatArrayOf(-0.168636f, -0.331068f, 0.499704f, 43.0f),
                floatArrayOf(0.299f, 0.587f, 0.114f, -80.0f),
                floatArrayOf(-0.7673034f, -0.10660906f, 0.8739125f, 95.0336f),
                floatArrayOf(0.5579587f, -0.30437875f, -0.25357994f, 7.6587f),
                floatArrayOf(-0.27004406f, -1.9299226f, 2.1999667f, 477.7804f),
                floatArrayOf(-0.3058816f, 0.7992592f, -0.4933776f, 26.55f),
                floatArrayOf(-0.114361696f, 1.1752532f, -1.0608914f, 12.2804f)
            )
        )

        fun transformBitwiseOr(mat: Mat, mat2: Mat, mat3: Mat) {
            val rows = mat2.rows()
            for (i in 0 until rows) {
                Core.transform(mat, trfResult, mat2.row(i))
                Core.compare(trfResult, Scalar(0.0), gtzResult, 2)
                if (i == 0) {
                    val mat4: Mat = gtzResult
                    Core.copyTo(mat4, mat3, mat4)
                } else {
                    Core.bitwise_or(mat3, gtzResult, mat3)
                }
            }
        }

        fun transformBitwise(image: Mat, arr: Mat, mask: Mat) {
            val rows = arr.rows()
            for (i in 0 until rows) {
                Core.transform(image, trfResult, arr.row(i))
                Core.compare(trfResult, Scalar(0.0), gtzResult, 2)
                if (i == 0) {
                    val matT4: Mat = gtzResult
                    Core.copyTo(matT4, mask, matT4)
                } else {
                    Core.bitwise_and(mask, gtzResult, mask)
                }
            }
        }

        transformBitwise(img, c00, mask00)
        transformBitwiseOr(img, c01, mask01)
        transformBitwise(img, c1, mask1)
        transformBitwise(img, c2, mask2)

        val mat: Mat = mask1
        Core.bitwise_or(mat, mask2, mat)

        val mat2: Mat = mask00
        Core.bitwise_and(mat2, mask01, mat2)

        val mat3: Mat = mask00
        Core.bitwise_and(mat3, mask1, mat3)

        val mat4: Mat = mask00
        Imgproc.GaussianBlur(mat4, mat4, Size(51.0, 51.0), 8.0)

        Core.compare(mask00, Scalar(192.0), mask00, Core.CMP_GE)

        return mask00
    }


    fun removeBackgroundWithHistogramBackprojection(inputMat: Mat): Mat {
        val rgb = Mat()
        Imgproc.cvtColor(inputMat, rgb, Imgproc.COLOR_BGR2RGB)
        val centerROI = getCenterRegion(rgb, 0.5)
        val roiHistogram = calculateHistogram(centerROI)
        val backProjection = calculateHistogramBackprojection(rgb, roiHistogram)

//        val ellipseKernel = Imgproc.getStructuringElement(Imgproc.MORPH_ELLIPSE, Size(15.0, 15.0))
//
//        val resultMat = Mat()
//        Imgproc.filter2D(backProjection, resultMat, -1, ellipseKernel)

        val foreground = Mat()
        Imgproc.threshold(backProjection, foreground, 8.0, 255.0, Imgproc.THRESH_BINARY)

        return foreground
    }

    private fun getCenterRegion(mat: Mat, percentage: Double): Mat {
        val centerWidth = (mat.cols() * percentage).toInt()
        val centerHeight = (mat.rows() * percentage).toInt()
        val startX = (mat.cols() - centerWidth) / 2
        val startY = (mat.rows() - centerHeight) / 2
        val roi = Mat(mat, Rect(startX, startY, centerWidth, centerHeight))
        return roi.clone()
    }

    private fun calculateHistogram(roi: Mat): Mat {
        val roiHSV = Mat()
        Imgproc.cvtColor(roi, roiHSV, Imgproc.COLOR_RGB2HSV)
        val histSize = MatOfInt(180, 256)
        val histRanges = MatOfFloat(0f, 180f, 0f, 256f)
        val channels = MatOfInt(0, 1)
        val hist = Mat()
        Imgproc.calcHist(listOf(roiHSV), channels, Mat(), hist, histSize, histRanges)
        Core.normalize(hist, hist, 0.0, 255.0, Core.NORM_MINMAX)
        return hist
    }

    private fun calculateHistogramBackprojection(inputMat: Mat, roiHistogram: Mat): Mat {
        val inputHSV = Mat()
        Imgproc.cvtColor(inputMat, inputHSV, Imgproc.COLOR_RGB2HSV)
        val backProjection = Mat()
        val histRanges = MatOfFloat(0f, 180f, 0f, 256f)
        val channels = MatOfInt(0, 1)
        Imgproc.calcBackProject(listOf(inputHSV), channels, roiHistogram, backProjection, histRanges, 1.0)
        return backProjection
    }

    fun hueFilter(mat: Mat) : Mat {
        val roi = getCenterRegion(mat, 0.5)

        val hsv = Mat()
        Imgproc.cvtColor(roi, hsv, Imgproc.COLOR_BGR2HSV)

        val channels = mutableListOf<Mat>()
        Core.split(hsv, channels)

        val meanHue = Core.mean(channels[0]).`val`[0]
        val meanSaturation = Core.mean(channels[1]).`val`[0]
        val meanValue = Core.mean(channels[2]).`val`[0]

        val hueDeviation = 16.0
        val saturationDeviation = 64.0
        val valueDeviation = 128.0

        val hueRange = doubleArrayOf(
            max(0.0, meanHue - hueDeviation),
            min(255.0, meanHue + hueDeviation)
        )

        val saturationRange = doubleArrayOf(
            max(0.0, meanSaturation - saturationDeviation),
            min(255.0, meanSaturation + saturationDeviation)
        )

        val valueRange = doubleArrayOf(
            max(0.0, meanValue - valueDeviation),
            min(255.0, meanValue + valueDeviation)
        )

        val lowerThreshold = Scalar(hueRange[0], saturationRange[0], valueRange[0])
        val upperThreshold = Scalar(hueRange[1], saturationRange[1], valueRange[1])

        val hsvMat = Mat()
        Imgproc.cvtColor(mat, hsvMat, Imgproc.COLOR_BGR2HSV)

        val mask = Mat()
        Core.inRange(hsvMat, lowerThreshold, upperThreshold, mask)

        val kernel = Imgproc.getStructuringElement(Imgproc.MORPH_RECT, Size(5.0, 5.0))

        val closed = Mat()
        Imgproc.morphologyEx(mask, closed, Imgproc.MORPH_CLOSE, kernel)

        val result = Mat()
        Core.bitwise_and(mat, mat, result, closed)

        return result
    }
}