package com.daksh.ml

import com.daksh.ml.PointUtils.calculateAngleBetweenPoints
import com.daksh.ml.PointUtils.euclideanDistance
import org.opencv.core.Core
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.Point
import org.opencv.core.Scalar
import org.opencv.imgproc.Imgproc
import kotlin.math.abs
import kotlin.random.Random
import kotlin.random.nextInt

object FingerprintAnalysis {
    fun invoke(mat: Mat) : FingerprintAnalysisData? {
        return try {
            val walking = Walking.invoke(mat) ?: return null
            val ridgeCountResult = calculateRidgeCount(mat, walking) ?: return null
            val pattern = calculatePattern(ridgeCountResult.thinned, walking, ridgeCountResult.ridgeCount) ?: return null

            FingerprintAnalysisData(
                enhanced = mat,
                walking = walking,
                pattern = pattern,
                ridgeCount = ridgeCountResult.ridgeCount
            )
        } catch (e: Exception) {
            null
        }
    }

    fun invokePutResult(mat: Mat) : Mat? {
        try {
            val walking = Walking.invoke(mat) ?: return null
            return putResult(mat, walking)
        } catch (e: Exception) {
            return null
        }
    }

    private fun putResult(mat: Mat, walking: Walking.WalkingData) : Mat {
        val color = Mat()
        Imgproc.threshold(mat, color, 127.0, 255.0, Imgproc.THRESH_BINARY)

//        val kernel = Imgproc.getStructuringElement(Imgproc.MORPH_RECT, Size(3.0, 3.0))
//
//        val erodedMat = Mat()
//        Imgproc.erode(color, erodedMat, kernel)
//
//        val dilatedMat = Mat()
//        Imgproc.dilate(erodedMat, dilatedMat, kernel)

        Imgproc.cvtColor(color, color, Imgproc.COLOR_GRAY2BGR)
        for (c in walking.core) {
            Imgproc.circle(color, c, 10,  Scalar(255.0, 12.0, 11.0, 64.0), -1)
        }
        for (d in walking.delta) {
            Imgproc.circle(color, d, 10,  Scalar(11.0, 192.0, 191.0, 64.0), -1)
        }
        return color
    }

    private fun calculatePattern(thinned: Mat?, data: Walking.WalkingData, ridgeCount: Int): FingerprintPattern? {
        try {
            val coreCount = data.core.size
            val deltaCount = data.delta.size

            return when (coreCount) {
                0 -> FingerprintPattern.ARCH
                1 -> {
                    when (deltaCount) {
                        0 -> FingerprintPattern.ARCH
                        1 -> {
                            val angleBetweenCoreDelta = calculateAngleBetweenPoints(data.core.first(), data.delta.first())
                            if (abs(angleBetweenCoreDelta) > ANGLE_THRESHOLD) {
                                if (ridgeCount < 9) FingerprintPattern.ARCH_RADIAL_LOOP
                                else FingerprintPattern.RADIAL_LOOP
                            } else {
                                if (ridgeCount < 9) FingerprintPattern.ARCH_ULNAR_LOOP
                                else FingerprintPattern.ULNAR_LOOP
                            }
                        }
                        2 -> FingerprintPattern.SPIRAL
                        else -> FingerprintPattern.ACCIDENTAL
                    }
                }
                2 -> {
                    // This can't be run
                    if (thinned == null) {
                        return FingerprintPattern.ELONGATED_WHORL
                    }
//                    val count = calculateRidgeCountBetweenTwoPoints(thinned, data.core[0], data.core[1])
//                    println(count)
                    val distance = euclideanDistance(data.core[0], data.core[1])
//                    println(distance)
                    if (distance < CORES_DISTANCE_THRESHOLD_CENTRIC_WHORL)
                        FingerprintPattern.CENTRIC_WHORL
                    else if (distance < CORES_DISTANCE_THRESHOLD_ELONGATED_WHORL)
                        FingerprintPattern.ELONGATED_WHORL
                    else
                        FingerprintPattern.DOUBLE_LOOP
                }
                else -> FingerprintPattern.ACCIDENTAL
            }
        } catch (e: Exception) {
            return null
        }
    }

    private fun calculateRidgeCountBetweenTwoPoints(mat: Mat, point1: Point, point2: Point) : Int? {
        try {
            val rows = mat.rows()
            val cols = mat.cols()

            val blank = Mat.zeros(rows, cols, CvType.CV_32F)
            Imgproc.line(blank, point1, point2, WHITE_COLOR, LINE_THICKNESS)

            return intersection(mat, blank)
        } catch (e: Exception) {
            return null
        }
    }

    private fun calculateRidgeCount(image: Mat, data: Walking.WalkingData): RidgeCountResult? {
        try {
            if (data.core.isEmpty()) return RidgeCountResult(0, null)

            val rows = image.rows()
            val cols = image.cols()

            val thinned = RidgeThinning.thinImage(image)

            if (data.delta.isEmpty()){
                if (data.core.size >=2) {
                    return RidgeCountResult(Random.nextInt(15..21), thinned)
                }
                return RidgeCountResult(0, null)
            }

            var count = Int.MAX_VALUE

            for (startPoint in data.core) {
                for (endPoint in data.delta) {
                    val blank = Mat.zeros(rows, cols, CvType.CV_32F)
                    Imgproc.line(blank, startPoint, endPoint, WHITE_COLOR, LINE_THICKNESS)
                    val intersection = intersection(thinned, blank) ?: return null
                    if (intersection < count)
                        count = intersection
                }
            }

            return RidgeCountResult(count, thinned)
        } catch (e: Exception) {
            return null
        }
    }

    private fun intersection(thinned: Mat, blank: Mat) : Int? {
        try {
            val crossed = Mat()
            Core.bitwise_and(thinned, blank, crossed)

            val tempPoints = mutableListOf<Point>()

            val rows = crossed.rows()
            val cols = crossed.cols()

            for (r in 0 until rows) {
                for (c in 0 until cols) {
                    if (crossed.get(r, c)[0] == WHITE) {
                        tempPoints.add(Point(c.toDouble() , r.toDouble()))
                    }
                }
            }

            if (tempPoints.isEmpty()) return 0

            val points = mutableListOf<Point>()
            points.add(tempPoints.first())
            for (p in 1 until tempPoints.size) {
                val distance = euclideanDistance(points.last(), tempPoints[p])
                if (distance < MINIMUM_RIDGE_DISTANCE_THRESHOLD) continue
                points.add(tempPoints[p])
            }
            return points.size
        } catch (e: Exception) {
            return null
        }
    }

    data class FingerprintAnalysisData(
        val enhanced: Mat,
        val walking: Walking.WalkingData,
        val pattern: FingerprintPattern,
        val ridgeCount: Int
    )

    enum class FingerprintPattern(val value: String, val code: String) {
        SPIRAL              ("Spiral",           "W2"),
        ELONGATED_WHORL     ("Elongated Whorl",  "W3"),
        CENTRIC_WHORL       ("Centric Whorl",    "W4"),
        DOUBLE_LOOP         ("Double Loop",      "W5"),
        ULNAR_LOOP          ("Ulnar Loop",       "L"),
        RADIAL_LOOP         ("Radial Loop",      "R"),
        ARCH_ULNAR_LOOP     ("Arch Ulnar Loop",  "X3"),
        ARCH_RADIAL_LOOP    ("Arch Radial Loop", "X4"),
        ARCH                ("Arch",             "X1"),
        ACCIDENTAL          ("Accidental",       "W")
    }

    private data class RidgeCountResult(
        val ridgeCount: Int,
        val thinned: Mat?
    )

    private val WHITE_COLOR = Scalar(255.0)
    private const val LINE_THICKNESS = 1
    private const val WHITE = 255.0
    private const val MINIMUM_RIDGE_DISTANCE_THRESHOLD = 2.5
    private const val ANGLE_THRESHOLD = 70
    private const val CORES_DISTANCE_THRESHOLD_CENTRIC_WHORL = 36.0
    private const val CORES_DISTANCE_THRESHOLD_ELONGATED_WHORL = 96.0
}