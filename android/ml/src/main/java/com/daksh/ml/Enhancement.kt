package com.daksh.ml

import com.daksh.ml.MatUtils.abs
import com.daksh.ml.MatUtils.add
import com.daksh.ml.MatUtils.arcTan2
import com.daksh.ml.MatUtils.cos
import com.daksh.ml.MatUtils.divide
import com.daksh.ml.MatUtils.divideDouble
import com.daksh.ml.MatUtils.exponential
import com.daksh.ml.MatUtils.filter2D
import com.daksh.ml.MatUtils.mean
import com.daksh.ml.MatUtils.meshGrid
import com.daksh.ml.MatUtils.multiplyDouble
import com.daksh.ml.MatUtils.normalize
import com.daksh.ml.MatUtils.removeZerosFrom1DMatH
import com.daksh.ml.MatUtils.sin
import com.daksh.ml.MatUtils.sqrt
import com.daksh.ml.MatUtils.square
import com.daksh.ml.MatUtils.subtract
import org.opencv.core.Core
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.MatOfDouble
import org.opencv.core.Point
import org.opencv.core.Rect
import org.opencv.core.Scalar
import org.opencv.imgproc.Imgproc
import kotlin.math.atan2
import kotlin.math.ceil
import kotlin.math.max
import kotlin.math.pow
import kotlin.math.roundToInt
import kotlin.math.sqrt

object Enhancement {
    fun invoke(mat: Mat): Mat? {
        try {
            val (normalize, mask) = ridgeSegment(mat) ?: return null
            val orientation = ridgeOrient(normalize) ?: return null
            val (frequency, mean) = ridgeFrequency(normalize, mask, orientation) ?: return null
            return ridgeFilter(normalize, orientation, frequency, mean)
        } catch (e: Exception) {
            return null
        }
    }

    private fun ridgeFilter(normalize: Mat, orientation: Mat, frequency: Mat, mean: Double): Mat? {
        try {
            val rows = normalize.rows()
            val cols = normalize.cols()

            val newImage = Mat.zeros(rows, cols, CvType.CV_32F)
            val sigmaX = KX / mean
            val sigmaY = KY / mean

            var size = (3.0 * max(sigmaX, sigmaY)).roundToInt()
            if (size % 2 != 0)
                size++

            val x = meshGrid(size)
            val y = x.t()

            val part1 = x.square().divideDouble(sigmaX.pow(2))
                .add(y.square().divideDouble(sigmaY.pow(2)))
                .multiplyDouble(-1.0)
                .exponential()

            val part2 = x.multiplyDouble(mean).multiplyDouble(Math.PI).multiplyDouble(2.0).cos()

            val refFilter = part1.mul(part2)

            val filterRows = refFilter.rows()
            val filterCols = refFilter.cols()

            val angleRange = (180.0 / ANGLE_INC).roundToInt()

            val gaborFilters = mutableListOf<Mat>()
            val center = Point(filterCols / 2.0, filterRows / 2.0)
            for (i in 0 until angleRange) {
                val rotateAngle = -((i * ANGLE_INC) + 90.0)
                val rotationMatrix = Imgproc.getRotationMatrix2D(center, rotateAngle, 1.0)
                val rotated = Mat()
                Imgproc.warpAffine(refFilter, rotated, rotationMatrix, refFilter.size())
                gaborFilters.add(rotated)
            }


            val maxOrientIndex = 180.0 / ANGLE_INC
            val multiplier = maxOrientIndex / Math.PI
            val orientationIndices = orientation.multiplyDouble(multiplier)

            for (r in 0 until rows) {
                for (c in 0 until cols) {
                    if (orientationIndices.get(r, c)[0] < 1.0) {
                        val put = orientationIndices.get(r, c)[0] + maxOrientIndex
                        orientationIndices.put(r, c, put)
                    }
                    if (orientationIndices.get(r, c)[0] > maxOrientIndex) {
                        val put = orientationIndices.get(r, c)[0] - maxOrientIndex + 1
                        orientationIndices.put(r, c, put)
                    }
                }
            }


            for (r in 0 until rows) {
                for (c in 0 until cols) {
                    if (frequency.get(r, c)[0] > 0
                        && r > (size)
                        && r < rows - size
                        && c > size
                        && c < cols - size) {

                        val orientationIndex = gaborFilters[orientationIndices.get(r, c)[0].roundToInt() - 1]

                        val sub = normalize.submat(
                            r - size, r + size + 1,
                            c - size, c + size  + 1
                        )

                        val s = Core.sumElems(sub.mul(orientationIndex)).`val`[0]

                        newImage.put(r, c, s)
                    }
                }
            }

            val final = Mat()
            Core.compare(newImage, Scalar(RIDGE_FILTER_THRESHOLD), final, Core.CMP_LT)
            return final
        } catch (e: Exception) {
            return null
        }
    }

    private fun ridgeFrequency(normalize: Mat, mask: Mat, orientation: Mat): Pair<Mat, Double>? {
        try {
            val rows = normalize.rows()
            val cols = normalize.cols()
            val frequency = Mat.zeros(rows, cols, CvType.CV_32F)

            for (r in 0 until rows - RIDGE_FREQUENCY_BLOCK_SIZE step RIDGE_FREQUENCY_BLOCK_SIZE) {
                for (c in 0 until cols - RIDGE_FREQUENCY_BLOCK_SIZE step RIDGE_FREQUENCY_BLOCK_SIZE) {
                    val (r1, r2) = Pair(r, r + RIDGE_FREQUENCY_BLOCK_SIZE)
                    val (c1, c2) = Pair(c, c + RIDGE_FREQUENCY_BLOCK_SIZE)
                    val blockNormalize = normalize.submat(r1, r2, c1, c2)
                    val blockOrientation = orientation.submat(r1, r2, c1, c2)

                    val freq = calculateFrequency(blockNormalize, blockOrientation) ?: return null
                    freq.copyTo(frequency.rowRange(r1, r2).colRange(c1, c2))
                }
            }

            val normalizedMak = Mat()
            Core.normalize(mask, normalizedMak, 0.0, 1.0, Core.NORM_MINMAX, CvType.CV_32F)

            val maskMultiply = frequency.mul(normalizedMak)

            val frequency1D = maskMultiply.reshape(0, 1)
            //        val indices = Mat()
            //        Core.findNonZero(frequency1D, indices)
            val nonZeroElements = removeZerosFrom1DMatH(frequency1D)
            //        median_freq = np.median(nonZeroElements)
            val mean = nonZeroElements.mean()
            return Pair(normalizedMak.multiplyDouble(mean), mean)
        } catch (e: Exception) {
            return null
        }
    }

    private fun calculateFrequency(blockNormalize: Mat, blockOrientation: Mat): Mat? {
        try {
            val rows = blockNormalize.rows()
            val cols = blockNormalize.cols()

            val blockOrientationClone = blockOrientation.clone().multiplyDouble(2.0)

            val sinOrientation = blockOrientationClone.sin().mean()
            val cosOrientation = blockOrientationClone.cos().mean()

            val orientation = atan2(sinOrientation, cosOrientation) / 2.0

            val center = Point(cols / 2.0, rows / 2.0)
            val rotateAngle = orientation / Math.PI * 180.0 + 90.0
            val rotationMatrix = Imgproc.getRotationMatrix2D(center, rotateAngle, 1.0)

            val rotated = Mat()
            Imgproc.warpAffine(blockNormalize, rotated, rotationMatrix, blockNormalize.size())

            val cropSize = (rows / sqrt(2.0)).toInt()
            val offset = (rows - cropSize) / 2 - 1
            val cropped = rotated.submat(offset, offset + cropSize, offset, offset + cropSize)

            val proj = Mat()
            Core.reduce(cropped, proj, 0, Core.REDUCE_SUM, CvType.CV_64F)

            val dilationKernel = Mat.ones(RIDGE_FREQUENCY_WINDOW_SIZE, RIDGE_FREQUENCY_WINDOW_SIZE, CvType.CV_32F)
            val dilation = Mat()
            Imgproc.dilate(proj, dilation, dilationKernel, Point(-1.0, -1.0), 1)

            val temp1 = dilation.subtract(proj).abs()
            val temp2 = Mat()
            Core.compare(temp1, Scalar(PEAK_THRESHOLD), temp2, Core.CMP_LT)
            val temp3 = Mat()
            Core.compare(proj, Scalar(proj.mean()), temp3, Core.CMP_GT)

            val maximumPoints = Mat()
            Core.bitwise_and(temp2, temp3, maximumPoints)

            val maxIndices = mutableListOf<Int>()
            for (i in 0 until maximumPoints.cols()) {
                val value = maximumPoints.get(0, i)[0]
                if (value == 255.0) {
                    maxIndices.add(i)
                }
            }

            val peaks = maxIndices.size
            if (peaks >= 2) {
                val waveLength = (maxIndices[peaks - 1] - maxIndices[0]).toDouble() / (peaks - 1).toDouble()
                if (waveLength in MINIMUM_WAVE_LENGTH..MAXIMUM_WAVE_LENGTH) {
                    return Mat.ones(rows, cols, CvType.CV_32F).multiplyDouble(1.0 / waveLength)
                }
            }
            return Mat.zeros(rows, cols, CvType.CV_32F)
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

            val orientation = arcTan2(sin2Theta2, cos2Theta2)
            Core.divide(orientation, Scalar(2.0), orientation)
            Core.add(orientation, Scalar(Math.PI/2), orientation)
            return orientation
        } catch (e: Exception) {
            return null
        }
    }

    private const val RIDGE_SEGMENT_BLOCK_SIZE = 16
    private const val RIDGE_SEGMENT_THRESHOLD = 0.00000001
    private const val GRADIENT_SIGMA = 1
    private const val BLOCK_SIGMA = 7
    private const val ORIENT_SMOOTH_SIGMA = 7
    private const val RIDGE_FREQUENCY_BLOCK_SIZE = 38
    private const val RIDGE_FREQUENCY_WINDOW_SIZE = 5
    private const val MINIMUM_WAVE_LENGTH = 5.0
    private const val MAXIMUM_WAVE_LENGTH = 15.0
    private const val PEAK_THRESHOLD = 2.0
    private const val KX = 0.65
    private const val KY = 0.65
    private const val ANGLE_INC = 3.0
    private const val RIDGE_FILTER_THRESHOLD = -3.0
}