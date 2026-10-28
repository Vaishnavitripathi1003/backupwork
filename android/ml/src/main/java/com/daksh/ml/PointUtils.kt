package com.daksh.ml

import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.Point
import kotlin.math.atan2
import kotlin.math.pow
import kotlin.math.roundToInt
import kotlin.math.sqrt

object PointUtils {
    fun Mat.point(point: Point) : Double {
        try {
            return this.get(point.y.toInt(), point.x.toInt())[0]
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun average(points: List<Point>) : Point {
        try {
            var colsTotal = 0.0
            var rowsTotal = 0.0
            val n = points.size
            points.forEach {
                colsTotal += it.x
                rowsTotal += it.y
            }
            val averageX = (colsTotal / n).roundToInt().toDouble()
            val averageY = (rowsTotal / n).roundToInt().toDouble()

            return Point(averageX, averageY)
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Point.toMat() : Mat {
        try {
            val result = Mat(1, 2, CvType.CV_32F)
            result.put(0, 0, this.y)
            result.put(0, 1, this.x)
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun pointsToMat(pointList: List<Point>) : Mat {
        try {
            val result = Mat(pointList.size, 2, CvType.CV_32F)
            pointList.forEachIndexed { index, value ->
                result.put(index, 0, value.y)
                result.put(index, 1, value.x)
            }
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun euclideanDistance(point1: Point, point2: Point): Double {
        try {
            return sqrt((point1.x - point2.x).pow(2) + (point1.y - point2.y).pow(2))
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun calculateAngleBetweenPoints(point1: Point, point2: Point): Double {
        try {
            val deltaY = point2.y - point1.y
            val deltaX = point2.x - point1.x
            val angleRadians = atan2(deltaY, deltaX)
            return Math.toDegrees(angleRadians)
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.center(): Point {
        try {
            val centerX = this.cols() / 2
            val centerY = this.rows() / 2
            return Point(centerX.toDouble(), centerY.toDouble())
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }
}