package com.daksh.ml

import org.opencv.core.Core
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.MatOfPoint
import org.opencv.core.Rect
import org.opencv.core.Scalar
import org.opencv.core.Size
import org.opencv.imgproc.Imgproc


object RotationUtils {
    fun invoke(mat: Mat) : Mat {
        try {
            val largestAreaPart = mat.largestAreaObject(true)
//             return rotateFingertip(largestAreaPart)
            return largestAreaPart
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

//    private fun rotateFingertip(fingertip: Mat): Mat {
//        try {
//            val gray = Mat()
//            Imgproc.cvtColor(fingertip, gray, Imgproc.COLOR_BGR2GRAY)
//
//            val lastRow = gray.rows() - 1
//            val lastCol = gray.cols() - 1
//
//            var leftCol = 0
//            var rightCol = lastCol
//            var longestWhiteLine = 0
//            var currentWhiteLine = 0
//
//            for (i in 0 until gray.cols()) {
//                val pixelValue = gray.get(lastRow, i)[0]
//                if (pixelValue == WHITE) {
//                    currentWhiteLine++
//                    if (currentWhiteLine > longestWhiteLine) {
//                        longestWhiteLine = currentWhiteLine
//                        leftCol = i - longestWhiteLine + 1
//                        rightCol = i
//                    }
//                } else {
//                    currentWhiteLine = 0
//                }
//            }
//
//            val midX = (leftCol + rightCol) / 2
//
//            val angle = calculateAngleBetweenPoints(fingertip.center(), Point(midX.toDouble(), lastRow.toDouble()))
//
//            var newAngle = 0.0
//
//            if (angle < 90.0) {
//                val pointL = Point(leftCol.toDouble(), gray.rows().toDouble())
//                val pointC = Point(gray.cols().toDouble(), gray.rows().toDouble())
//                var lowestBlack = lastRow
//                for (r in lastRow downTo 1) {
//                    if (gray.get(r, lastCol)[0] == BLACK) {
//                        lowestBlack = r
//                        break
//                    }
//                }
//                val pointU = Point(gray.cols().toDouble(), lowestBlack.toDouble() - 1.0)
//                val trianglePoints = listOf(pointL, pointC, pointU)
//                val trianglePointsArray = MatOfPoint()
//                trianglePointsArray.fromList(trianglePoints)
//                Imgproc.fillConvexPoly(fingertip, trianglePointsArray, Scalar(0.0, 0.0, 0.0))
//                newAngle = calculateAngleBetweenPoints(pointL, pointU)
//            } else if (angle > 90.0) {
//                val pointR = Point(rightCol.toDouble() + 1.0, gray.rows().toDouble())
//                val pointC = Point(1.0, gray.rows().toDouble())
//                var lowestBlack = lastRow
//                for (r in lastRow downTo 1) {
//                    if (gray.get(r, 0)[0] == BLACK) {
//                        lowestBlack = r
//                        break
//                    }
//                }
//                val pointU = Point(1.0, lowestBlack.toDouble() - 1.0)
//                val trianglePoints = listOf(pointR, pointC, pointU)
//                val trianglePointsArray = MatOfPoint()
//                trianglePointsArray.fromList(trianglePoints)
//                Imgproc.fillConvexPoly(fingertip, trianglePointsArray, Scalar(0.0, 0.0, 0.0))
//                newAngle = calculateAngleBetweenPoints(pointU, pointR)
//            }
//
//            return fingertip.rotateMatWithoutCutting(newAngle).largestAreaObject(true)
//        } catch (e: Exception) {
//            throw Exception(e.message)
//        }
//    }

    private fun Mat.largestAreaObject(submat: Boolean) : Mat {

        val gray = Mat()
        Imgproc.cvtColor(this, gray, Imgproc.COLOR_BGR2GRAY)
        val threshold = Mat()
        Imgproc.threshold(gray, threshold, 8.0, 255.0, Imgproc.THRESH_BINARY)
        val contours = mutableListOf<MatOfPoint>()
        val hierarchy = Mat()
        Imgproc.findContours(threshold, contours, hierarchy, Imgproc.RETR_EXTERNAL, Imgproc.CHAIN_APPROX_SIMPLE)
        contours.sortByDescending { Imgproc.contourArea(it) }
        val largestAreaContour = contours[0]
        val mask = Mat.zeros(this.size(), CvType.CV_8UC1)
        Imgproc.drawContours(mask, listOf(largestAreaContour), -1, Scalar(255.0, 255.0, 255.0), -1)
        val resultMat = Mat()
        Core.bitwise_and(this, this, resultMat, mask)
        if (submat) {
            val boundingRect = Imgproc.boundingRect(largestAreaContour)
            val canvas = Mat.zeros(Size(boundingRect.width.toDouble(), boundingRect.height.toDouble()), CvType.CV_8UC3)
            val roi = resultMat.submat(boundingRect)
            roi.copyTo(canvas.submat(Rect(0, 0, boundingRect.width, boundingRect.height)))
            return roi
        }
        return resultMat
    }

//    private fun Mat.rotateMatWithoutCutting(degrees: Double): Mat {
//        val radians = Math.toRadians(degrees)
//        val sin = abs(sin(radians))
//        val cos = abs(cos(radians))
//        val newWidth = (this.size().width * cos + this.size().height * sin).toInt()
//        val newHeight = (this.size().width * sin + this.size().height * cos).toInt()
//        val newSize = Size(newWidth.toDouble(), newHeight.toDouble())
//        val rotatedMat = Mat.zeros(newSize, this.type())
//        val translationMatrix = Mat(2, 3, CvType.CV_64F)
//        val dx = (newSize.width - this.cols()) / 2.0
//        val dy = (newSize.height - this.rows()) / 2.0
//        translationMatrix.put(0, 0, 1.0, 0.0, dx)
//        translationMatrix.put(1, 0, 0.0, 1.0, dy)
//        Imgproc.warpAffine(this, rotatedMat, translationMatrix, newSize, Imgproc.INTER_LINEAR)
//        val imageCenter = Point(newSize.width / 2.0, newSize.height / 2.0)
//        val rotationMatrix = Imgproc.getRotationMatrix2D(imageCenter, degrees, 1.0)
//        Imgproc.warpAffine(rotatedMat, rotatedMat, rotationMatrix, newSize, Imgproc.INTER_CUBIC)
//        return rotatedMat
//    }

    private const val BLACK = 0.0
    private const val WHITE = 255.0
}