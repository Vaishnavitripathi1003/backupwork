package com.daksh.ml

import com.daksh.ml.MatUtils.add
import com.daksh.ml.MatUtils.addDouble
import com.daksh.ml.MatUtils.convertListToMat
import com.daksh.ml.MatUtils.divide
import com.daksh.ml.MatUtils.filter2D
import com.daksh.ml.MatUtils.flipHorizontal
import com.daksh.ml.MatUtils.maximum
import com.daksh.ml.MatUtils.minimum
import com.daksh.ml.MatUtils.multiplyDouble
import com.daksh.ml.MatUtils.normalize
import com.daksh.ml.MatUtils.round
import com.daksh.ml.MatUtils.sqrt
import com.daksh.ml.MatUtils.square
import com.daksh.ml.MatUtils.subtract
import com.daksh.ml.MatUtils.subtractDouble
import com.daksh.ml.PointUtils.average
import com.daksh.ml.PointUtils.euclideanDistance
import com.daksh.ml.PointUtils.point
import com.daksh.ml.PointUtils.pointsToMat
import com.daksh.ml.PointUtils.toMat
import org.opencv.core.Core
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.MatOfDouble
import org.opencv.core.Point
import org.opencv.core.Rect
import org.opencv.core.Scalar
import org.opencv.imgproc.Imgproc
import kotlin.math.ceil
import kotlin.math.cos
import kotlin.math.roundToInt
import kotlin.math.sin

object Walking {
    fun invoke(mat: Mat) : WalkingData? {
        try {
            val core = mutableListOf<Point>()
            val delta = mutableListOf<Point>()

            val (normalize, mask) = ridgeSegment(mat) ?: return null

            val orientation = ridgeOrient(normalize) ?: return null
            Core.multiply(orientation, Scalar(-1.0), orientation)
            Core.add(orientation, Scalar(Math.PI), orientation)

            val whiteRowsIndices = Mat()
            Core.reduce(mask, whiteRowsIndices, 1, Core.REDUCE_SUM, CvType.CV_64F)
            // Core.findNonZero(whiteRowsIndices, tempR) was buggy
            Core.findNonZero(whiteRowsIndices.t(), whiteRowsIndices)

            val whiteColumnsIndices = Mat()
            Core.reduce(mask, whiteColumnsIndices, 0, Core.REDUCE_SUM, CvType.CV_64F)
            Core.findNonZero(whiteColumnsIndices, whiteColumnsIndices)

            val topLeftPoint = Point(whiteColumnsIndices.minimum(), whiteRowsIndices.minimum())
            val bottomRightPoint = Point(whiteColumnsIndices.maximum(), whiteRowsIndices.maximum())

            val rPartition = ((bottomRightPoint.y - topLeftPoint.y) / (N + 1)).toInt()
            val cPartition = ((bottomRightPoint.x - topLeftPoint.x) / (N + 1)).toInt()

            val sampleRows = listOf(topLeftPoint.y + rPartition, topLeftPoint.y + (2 * rPartition))
            val sampleCols = listOf(topLeftPoint.x + cPartition, topLeftPoint.x + (2 * cPartition))

            val samplesPoints = listOf(
                Point(sampleCols[0], sampleRows[0]),
                Point(sampleCols[1], sampleRows[0]),
                Point(sampleCols[0], sampleRows[1]),
                Point(sampleCols[1], sampleRows[1])
            )

            for (r in 0 until 4) {
                if (core.isNotEmpty()) break

                val wDFc1 = orientation.multiplyDouble(2.0).addDouble(((r + 1) * (Math.PI / 2)))
                var core1 : Point? = null
                var core2 : Point? = null

                for (i in samplesPoints.indices) {
                    val point = samplesPoints[i]
                    if (mask.point(point) == 0.0) continue

                    if (core1 == null) {
                        val tempSp = walkOnce(mask, wDFc1, point)
                        if (checkStable(mask, wDFc1, tempSp) == true) {
                            core1 = tempSp
                        }
                    }

                    if (core2 == null) {
                        val otherDirection = wDFc1.subtractDouble(Math.PI)
                        val tempSp = walkOnce(mask, otherDirection, point)
                        if (checkStable(mask, otherDirection, tempSp) == true) {
                            core2 = tempSp
                        }
                    }
                }
                core1?.let { core.add(it) }
                core2?.let { core.add(it) }
            }

            for (r in 0 until 4) {
                if (delta.isNotEmpty()) break
                val wDFd = orientation.multiplyDouble(-2.0).addDouble(((r + 1) * (Math.PI / 2)))
                for (i in samplesPoints.indices) {
                    val point = samplesPoints[i]
                    if (mask.point(point) == 0.0) continue
                    val tempSp = walkOnce(mask, wDFd, point)
                    if (checkStable(mask, wDFd, tempSp) == true) {
                        if (tempSp != null) {
                            delta.add(tempSp)
                        }
                    }
                }
            }

            val mergedCores = mergeNeighbors(core) ?: return null
            val mergedDelta = mergeNeighbors(delta) ?: return null

            // temp
            val remove = mat.rows().toDouble() * 0.8
            mergedCores.removeIf { it.y > remove }

            return WalkingData(mergedCores, mergedDelta)
        } catch (e: Exception) {
            return null
        }
    }

    private fun mergeNeighbors(points: MutableList<Point>) : MutableList<Point>? {
        try {
            val mergedPoints = mutableListOf<Point>()
            while(points.isNotEmpty()) {
                val neighbors = mutableListOf<Point>()
                val first = points.first()
                neighbors.add(first)
                points.remove(first)

                val iterator = points.iterator()
                while (iterator.hasNext()) {
                    val nextPoint = iterator.next()
                    val distance = euclideanDistance(first, nextPoint)
                    if (distance < MERGE_NEIGHBORS_THRESHOLD) {
                        neighbors.add(nextPoint)
                        iterator.remove()
                    }
                }
                mergedPoints.add(average(neighbors))
            }
            return mergedPoints
        } catch (e: Exception) {
            return null
        }
    }

    private fun checkStable(mask: Mat, wDFc1: Mat, tempSp: Point?) : Boolean? {
        try {
            tempSp ?: return false

            val part1 = Mat()
            Core.gemm(Mat.ones(4, 1, CvType.CV_32F), tempSp.toMat(), 1.0, Mat(), 0.0, part1)

            val part2 = convertListToMat(
                listOf(
                    doubleArrayOf(0.0, -1.0),
                    doubleArrayOf(-1.0, 0.0),
                    doubleArrayOf(0.0, 1.0),
                    doubleArrayOf(1.0, 0.0)
                )
            ).multiplyDouble(R)

            val tryStart = part1.add(part2)

            for (r in 0 until 4) {
                val row = tryStart.row(r)
                val point = Point(
                    row.get(0, 1)[0],
                    row.get(0, 0)[0]
                )
                if (point.x < 1 || point.y < 1) return false
                if (point.x > mask.cols() || point.y > mask.rows()) return false
                if (mask.point(point) == 0.0) return false
                val newSp = walkOnce(mask, wDFc1, point) ?: return false
                if (euclideanDistance(tempSp, newSp) > R2) return false
            }

            return true
        } catch (e: Exception) {
            return null
        }
    }

    private fun walkOnce(mask: Mat, wDFc1: Mat, start: Point) : Point? {
        try {
            var sp: Point? = null
            var current = 0
            val path = mutableListOf(start)
            while(true) {
                val currentPoint = path[current]
                current++
                val orientation = wDFc1.point(currentPoint)
                val nextPoint = Point(
                    currentPoint.x + (cos(orientation).roundToInt() * STEP),
                    currentPoint.y - (sin(orientation).roundToInt() * STEP)
                )

                if (nextPoint.x < 1 || nextPoint.y < 1) break
                if (nextPoint.x > mask.cols() || nextPoint.y > mask.rows()) break
                if (mask.point(nextPoint) == 0.0) break

                val depth = Mat()
                Core.gemm(
                    Mat.ones(path.size, 1, CvType.CV_32F),
                    nextPoint.toMat(), 1.0, Mat(), 0.0, depth
                )
                Core.subtract(pointsToMat(path), depth, depth)

                val sqrt = (depth.col(0).square())
                    .add(depth.col(1)
                        .square()).sqrt().t().flipHorizontal()

                val sqrtCompare = Mat()
                Core.compare(sqrt, Scalar(TD), sqrtCompare, Core.CMP_LT)

                if (Core.countNonZero(sqrtCompare) > 0) {
                    val tempNonZero = Mat()
                    Core.findNonZero(sqrtCompare, tempNonZero)
                    val nonZero = tempNonZero.t()
                    val index = sqrt.cols() - nonZero.get(0,0)[0].toInt()
                    if (current == index) {
                        sp = nextPoint
                    } else if (current - index <= 11){
                        val divider = current - index + 1
                        val subList = path.subList(index, path.size)
                        subList.add(nextPoint)
                        val inMat = pointsToMat(subList)
                        Core.reduce(inMat, inMat, 0, Core.REDUCE_SUM, CvType.CV_64F)
                        Core.divide(inMat, Scalar(divider.toDouble()), inMat)
                        val round = inMat.round()
                        sp = Point(round[0, 1][0], round[0, 0][0])
                    }
                    break
                }
                path.add(nextPoint)
            }
            return sp
        } catch (e: Exception) {
            return null
        }
    }

    private fun ridgeOrient(mat: Mat) : Mat? {
        try {
            val normalize = Mat()
            mat.convertTo(normalize, CvType.CV_64F)

            val kSize = (6 * GRADIENT_SIGMA) + 1
            val gauss = Imgproc.getGaussianKernel(kSize, GRADIENT_SIGMA.toDouble())
            val gaussT = gauss.t()
            val f = Mat()
            Core.gemm(gauss, gaussT, 1.0, Mat(), 0.0, f)

            val fx = Mat()
            val fy = Mat()
            Imgproc.Scharr(f, fx, CvType.CV_64F, 1, 0)
            Imgproc.Scharr(f, fy, CvType.CV_64F, 0, 1)

            val gx = normalize.filter2D(fx)
            val gy = normalize.filter2D(fy)
            val gxx = gx.square()
            val gyy = gy.square()

            val gxy = Mat()
            Core.multiply(gx, gy, gxy)
            // ----------------------------------------------------
            val kSize2 = (6 * BLOCK_SIGMA) + 1
            val gauss2 = Imgproc.getGaussianKernel(kSize2, BLOCK_SIGMA.toDouble())
            val gaussT2 = Mat()
            Core.transpose(gauss2, gaussT2)

            val f2 = Mat()
            Core.gemm(gauss2, gaussT2, 1.0, Mat(), 0.0, f2)

            val gxx2 = gxx.filter2D(f2)
            val gyy2 = gyy.filter2D(f2)
            val gxy2 = gxy.filter2D(f2)
            Core.multiply(gxy2, Scalar(2.0), gxy2)

            val denominator = (gxy2.square().add(gxx2.subtract(gyy2).square())).sqrt()
            Core.add(denominator, Scalar(Double.MIN_VALUE), denominator)

            val sin2Theta = gxy2.divide(denominator)
            val cos2Theta = gxx2.subtract(gyy2).divide(denominator)

            //        ------------------------------------------------
            val kSize3 = (6 * ORIENT_SMOOTH_SIGMA) + 1
            val gauss3 = Imgproc.getGaussianKernel(kSize3, ORIENT_SMOOTH_SIGMA.toDouble())
            val gaussT3 = Mat()
            Core.transpose(gauss3, gaussT3)

            val f3 = Mat()
            Core.gemm(gauss3, gaussT3, 1.0, Mat(), 0.0, f3)

            val cos2Theta2 = cos2Theta.filter2D(f3)
            val sin2Theta2 = sin2Theta.filter2D(f3)

            val orientation = MatUtils.arcTan2(sin2Theta2, cos2Theta2)
            Core.divide(orientation, Scalar(2.0), orientation)
            Core.add(orientation, Scalar(Math.PI/2), orientation)
            return orientation
        } catch (e: Exception) {
            return null
        }
    }

    private fun ridgeSegment(mat: Mat): Pair<Mat, Mat>? {
        try {
            val rows = mat.rows()
            val cols = mat.cols()

            val normalize = Mat()
            Core.normalize(mat, normalize, 0.0, 1.0, Core.NORM_MINMAX, CvType.CV_32F)

            val newRows = (RIDGE_SEGMENT_BLOCK_SIZE * ceil(rows.toDouble() / RIDGE_SEGMENT_BLOCK_SIZE)).toInt()
            val newCols = (RIDGE_SEGMENT_BLOCK_SIZE * ceil(cols.toDouble() / RIDGE_SEGMENT_BLOCK_SIZE)).toInt()

            val paddedImg = Mat.zeros(newRows, newCols, CvType.CV_32F)
            val stddevImg = Mat.zeros(newRows, newCols, CvType.CV_32F)

            normalize.copyTo(paddedImg.submat(0, rows, 0, cols))

            for (i in 0 until newRows step RIDGE_SEGMENT_BLOCK_SIZE) {
                for (j in 0 until newCols step RIDGE_SEGMENT_BLOCK_SIZE) {
                    val block = Mat(paddedImg, Rect(j, i, RIDGE_SEGMENT_BLOCK_SIZE, RIDGE_SEGMENT_BLOCK_SIZE))
                    val std = MatOfDouble()
                    Core.meanStdDev(block, MatOfDouble(), std)
                    Core.multiply(
                        Mat.ones(block.size(), CvType.CV_32F),
                        Scalar(std.toArray()[0]), Mat(stddevImg, Rect(j, i, RIDGE_SEGMENT_BLOCK_SIZE, RIDGE_SEGMENT_BLOCK_SIZE))
                    )
                }
            }
            val submat = stddevImg.submat(0, rows, 0, cols)

            val mask = Mat()
            Core.compare(submat, Scalar(RIDGE_SEGMENT_THRESHOLD), mask, Core.CMP_GT)

            val meanMat = MatOfDouble()
            val stdMat = MatOfDouble()
            Core.meanStdDev(normalize, meanMat, stdMat, mask)

            val normalizeFinal = normalize.normalize(meanMat.toArray()[0], stdMat.toArray()[0])

            return Pair(normalizeFinal, mask)
        } catch (e: Exception) {
            return null
        }
    }

    private const val RIDGE_SEGMENT_BLOCK_SIZE = 16
    private const val RIDGE_SEGMENT_THRESHOLD = 0.00000001
    private const val GRADIENT_SIGMA = 1
    private const val BLOCK_SIGMA = 3
    private const val ORIENT_SMOOTH_SIGMA = 3
    private const val N = 2
    private const val STEP = 7
    private const val TD = 2.0
    private const val R = 16.0
    private const val R2 = 16.0
    private const val MERGE_NEIGHBORS_THRESHOLD = 20

    data class WalkingData(
        val core: List<Point>,
        val delta: List<Point>
    )
}