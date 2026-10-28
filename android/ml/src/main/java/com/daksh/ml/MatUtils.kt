package com.daksh.ml

import android.graphics.Bitmap
import org.opencv.android.Utils
import org.opencv.core.Core
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.MatOfDouble
import org.opencv.core.Rect
import org.opencv.core.Scalar
import org.opencv.core.Size
import org.opencv.imgproc.Imgproc
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.max
import kotlin.math.roundToInt
import kotlin.math.sin

object MatUtils {

    fun Mat.divide(denominator: Mat) : Mat {
        try {
            val result = Mat()
            Core.divide(this, denominator, result)
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.square() : Mat {
        try {
            val square = Mat()
            Core.pow(this, 2.0, square)
            return square
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.inverse() : Mat {
        try {
            val inv = Mat()
            Core.bitwise_not(this, inv)
            return inv
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.subtract(subtract: Mat) : Mat {
        try {
            val result = Mat()
            Core.subtract(this, subtract, result)
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.add(add: Mat) : Mat {
        try {
            val result = Mat()
            Core.add(this, add, result)
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.filter2D(kernel: Mat) : Mat {
        try {
            val result = Mat()
            Imgproc.filter2D(this, result, CvType.CV_64F, kernel)
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.sqrt() : Mat {
        try {
            val result = Mat()
            Core.sqrt(this, result)
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun arcTan2(src1: Mat, src2: Mat) : Mat {
        try {
            val rows = src1.rows()
            val cols = src1.cols()
            val result = Mat(rows, cols, CvType.CV_32F)
            for (r in 0 until rows) {
                for (c in 0 until cols) {
                    result.put(r, c, atan2(src1[r, c][0], src2[r, c][0]))
                }
            }
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.cos() : Mat {
        try {
            val rows = this.rows()
            val cols = this.cols()
            val result = Mat(rows, cols, CvType.CV_32F)
            for (r in 0 until rows) {
                for (c in 0 until cols) {
                    result.put(r, c, cos(this[r,c][0]))
                }
            }
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.sin() : Mat {
        try {
            val rows = this.rows()
            val cols = this.cols()
            val result = Mat(rows, cols, CvType.CV_32F)
            for (r in 0 until rows) {
                for (c in 0 until cols) {
                    result.put(r, c, sin(this[r,c][0]))
                }
            }
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.mean() : Double {
        try {
            val meanMat = MatOfDouble()
            Core.meanStdDev(this, meanMat, MatOfDouble())
            return meanMat.toArray()[0]
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.addDouble(double: Double) : Mat {
        try {
            val result = Mat()
            Core.add(this, Scalar(double), result)
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.subtractDouble(double: Double) : Mat {
        try {
            val result = Mat()
            Core.subtract(this, Scalar(double), result)
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.multiplyDouble(double: Double) : Mat {
        try {
            val result = Mat()
            Core.multiply(this, Scalar(double), result)
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.divideDouble(double: Double) : Mat {
        try {
            val result = Mat()
            Core.divide(this, Scalar(double), result)
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.exponential() : Mat {
        try {
            val rows = this.rows()
            val cols = this.cols()
            val result = Mat(rows, cols, CvType.CV_32F)
            for (r in 0 until rows) {
                for (c in 0 until cols) {
                    result.put(r, c, exp(this[r,c][0]))
                }
            }
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.abs() : Mat {
        try {
            val absResult = Mat()
            Core.absdiff(this, Scalar.all(0.0), absResult)
            return absResult
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.round() : Mat {
        try {
            val rows = this.rows()
            val cols = this.cols()
            val result = Mat(rows, cols, CvType.CV_32F)

            for (r in 0 until rows) {
                for (c in 0 until cols) {
                    result.put(r, c, this[r,c][0].toInt().toDouble())
                }
            }
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.roundToInt() : Mat {
        try {
            val rows = this.rows()
            val cols = this.cols()
            val result = Mat(rows, cols, CvType.CV_32F)

            for (r in 0 until rows) {
                for (c in 0 until cols) {
                    result.put(r, c, this[r,c][0].roundToInt().toDouble())
                }
            }
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.removePrecision() : Mat {
        try {
            val rows = this.rows()
            val cols = this.cols()
            val result = Mat(rows, cols, CvType.CV_32F)
            for (r in 0 until rows) {
                for (c in 0 until cols) {
                    val value = (this[r,c][0] * 100.0).toInt() / 100.0
                    result.put(r, c, value)
                }
            }
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.normalize() : Mat? {
        try {
            val meanMat = MatOfDouble()
            val stdMat = MatOfDouble()
            Core.meanStdDev(this, meanMat, stdMat)
            val mean = meanMat.toArray()[0]
            val std = stdMat.toArray()[0]
            if (std == 0.0) return null
            val start = -mean/std
            val end = (1.0 - mean)/std
            val normalize = Mat()
            Core.normalize(this, normalize, start, end, Core.NORM_MINMAX, CvType.CV_32F)
            return normalize
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.normalize(mean: Double, std: Double) : Mat {
        try {
            val start = (0.0 -mean)/std
            val end = (1.0 - mean)/std
            val normalize = Mat()
            Core.normalize(this, normalize, start, end, Core.NORM_MINMAX, CvType.CV_32F)
            return normalize
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun convertListToMat(array: Array<FloatArray>): Mat {
        try {
            val rows = array.size
            val cols = array[0].size
            val mat = Mat(rows, cols, CvType.CV_64F)
            for ((index, value) in array.withIndex()) {
                mat.put(index, 0, value)
            }
            return mat
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun convertListToMat(list: List<DoubleArray>): Mat {
        try {
            val rows = list.size
            val cols = list[0].size
            val mat = Mat(rows, cols, CvType.CV_32F)
            for (r in 0 until rows) {
                for (c in 0 until cols) {
                    mat.put(r, c, list[r][c])
                }
            }
            return mat
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.resizeToWidth(newRows: Int): Mat {
        try {
            val rows = this.rows()
            val cols = this.cols()
            val aspectRatio = rows.toDouble() / cols.toDouble()
            val newCols = (newRows / aspectRatio).toInt()
            val newSize = Size(newCols.toDouble(), newRows.toDouble())
            val resizedImg = Mat()
            Imgproc.resize(this, resizedImg, newSize)
            return resizedImg
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun convertListToMat2(list: List<List<Double>>): Mat {
        try {
            val rows = list.size
            val cols = list[0].size
            val mat = Mat(rows, cols, CvType.CV_32F)
            for (r in 0 until rows) {
                for (c in 0 until cols) {
                    mat.put(r, c, list[r][c])
                }
            }
            return mat
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun DoubleArray.mean(): Double {
        try {
            var sum = 0.0
            for (aM in this) {
                sum += aM
            }
            return sum / this.size
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun removeZerosFrom1DMatH(freq1D: Mat): Mat {
        try {
            val nonZeroElements = mutableListOf<Double>()
            for (i in 0 until freq1D.cols()) {
                val value = freq1D.get(0, i)[0]
                if (value != 0.0) {
                    nonZeroElements.add(value)
                }
            }

            return doubleToMat(nonZeroElements)
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.getUniqueElements(): Mat {
        try {
            val uniqueElementsSet = mutableListOf<Double>()
            val rows = this.rows()
            val cols = this.cols()
            for (r in 0 until rows) {
                for (c in 0 until cols) {
                    if (!uniqueElementsSet.contains(this.get(r, c)[0]))
                        uniqueElementsSet.add(this.get(r, c)[0])
                }
            }
            return doubleToMat(uniqueElementsSet)
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun meshGrid(size: Int): Mat {
        try {
            val l = size * 2 + 1
            var value = -size
            val result = Mat(l, l, CvType.CV_32F)
            for (c in 0 until l) {
                for (r in 0 until l) {
                    result.put(r, c, value.toDouble())
                }
                value++
            }
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Bitmap.toMat() : Mat {
        try {
            val mat = Mat()
            Utils.bitmapToMat(this, mat)
            return mat
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.toBitmap(): Bitmap {
        try {
            val outputBitmap = Bitmap.createBitmap(this.width(), this.height(), Bitmap.Config.ARGB_8888)
            Utils.matToBitmap(this, outputBitmap)
            return outputBitmap
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun makeSquare(image: Mat): Mat {
        try {
            val height = image.rows()
            val width = image.cols()
            val maxDimension = max(height, width)
            val newImage = Mat(maxDimension, maxDimension, image.type(), Scalar(0.0, 0.0, 0.0))
            val yOffset = (maxDimension - height) / 2
            val xOffset = (maxDimension - width) / 2
            val roi = Mat(newImage, Rect(xOffset, yOffset, width, height))
            image.copyTo(roi)
            return newImage
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.minimum() : Double {
        try {
            var minimum = Double.MAX_VALUE
            val rows = this.rows()
            val cols = this.cols()
            for (r in 0 until rows) {
                for (c in 0 until cols) {
                    if (minimum > this.get(r, c)[0])
                        minimum = this.get(r, c)[0]
                }
            }
            return minimum
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.maximum() : Double {
        try {
            var maximum = Double.MIN_VALUE
            val rows = this.rows()
            val cols = this.cols()
            for (r in 0 until rows) {
                for (c in 0 until cols) {
                    if (maximum < this.get(r, c)[0])
                        maximum = this.get(r, c)[0]
                }
            }
            return maximum
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    private fun doubleToMat(doubleList: List<Double>) : Mat {
        try {
            val result = Mat(1, doubleList.size, CvType.CV_32F)
            doubleList.forEachIndexed { index, value ->
                result.put(0, index, value)
            }
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun floatListToMat(list: List<Float>) : Mat {
        try {
            val result = Mat(1, list.size, CvType.CV_32F)
            list.forEachIndexed { index, value ->
                result.put(0, index, value.toDouble())
            }
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }

    fun Mat.flipHorizontal() : Mat {
        try {
            val rows = this.rows()
            val cols = this.cols()
            val result = Mat(rows(), cols(), CvType.CV_32F)
            for (r in 0 until rows) {
                for (c in 0 until cols) {
                    result.put(r, cols - 1 - c, this.get(r, c)[0])
                }
            }
            return result
        } catch (e: Exception) {
            throw Exception(e.message)
        }
    }
}


