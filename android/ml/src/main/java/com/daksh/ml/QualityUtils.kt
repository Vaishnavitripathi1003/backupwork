package com.daksh.ml

import android.graphics.Bitmap
import org.opencv.android.Utils
import org.opencv.core.Core
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.MatOfDouble
import org.opencv.imgproc.Imgproc

object QualityUtils {
    fun getImageQuality(bitmap: Bitmap) : Double {
        val width = bitmap.width
        val height = bitmap.height
        val sectionWidth = (width * 0.75).toInt()
        val sectionHeight = (height * 0.75).toInt()
        val startX = ((width - sectionWidth) / 2)
        val startY = ((height - sectionHeight) / 2)
        val croppedBitmap = Bitmap.createBitmap(bitmap, startX, startY, sectionWidth, sectionHeight)
        val mat = Mat()
        Utils.bitmapToMat(croppedBitmap, mat)
        val gray = Mat()
        Imgproc.cvtColor(mat, gray, Imgproc.COLOR_BGR2GRAY)
        val laplacian = Mat()
        Imgproc.Laplacian(gray, laplacian, CvType.CV_32F)
        val mean = MatOfDouble()
        val stdDev = MatOfDouble()
        Core.meanStdDev(laplacian, mean, stdDev)
        return stdDev.get(0, 0)[0] * stdDev.get(0, 0)[0]
    }
}