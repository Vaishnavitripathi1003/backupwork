package com.daksh.ml

import android.graphics.Bitmap
import com.daksh.ml.MatUtils.resizeToWidth
import com.daksh.ml.MatUtils.toMat
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.Size
import org.opencv.imgproc.Imgproc
object FingerprintUtils {
    fun invoke(fingertip: Bitmap) : Mat? {
        try {
            val rotatedFingerTip = RotationUtils.invoke(fingertip.toMat())
            val fingerprint = getFingerprint(rotatedFingerTip.resizeToWidth(1080))

            // final width and height should not be divisible by 16
            // because in walking block size is 16
            // or else it will throw error
            val resized = resizeForBlockSize(fingerprint)

            // This padding ensure side don't get cut in enhancement
            // and also the walking mask don't touch edges
            return addPadding(resized)
//
        } catch (e: Exception) {
            return null
        }
    }

    private fun getFingerprint(mat: Mat) : Mat {
        val gray = Mat()
        Imgproc.cvtColor(mat, gray, Imgproc.COLOR_BGR2GRAY)

        val blur = Mat()
        Imgproc.GaussianBlur(gray, blur, Size(3.0, 3.0), 0.0, 0.0)

//        val equalizedImage = Mat()
//        Imgproc.equalizeHist(blur, equalizedImage)

        val thresh = Mat()
        Imgproc.adaptiveThreshold(blur, thresh, 255.0, Imgproc.ADAPTIVE_THRESH_MEAN_C, Imgproc.THRESH_BINARY, 31, 0.0)

        return thresh
    }

    private fun resizeForBlockSize(mat: Mat, blockSize: Int = 16) : Mat {
        val temp = mat.resizeToWidth(520)
        var rows = temp.rows()
        val cols = temp.cols()

        if (rows % blockSize == 0)
            rows += 8

        val resized = Mat()
        Imgproc.resize(temp, resized, Size(cols.toDouble(), rows.toDouble()))
        return resized
    }

    private fun addPadding(image: Mat, padding: Int = 128): Mat {
        val height = image.rows()
        val width = image.cols()

        val newHeight = height + padding
        val newWidth = width + padding

        val yOffset = (newHeight - height) / 2
        val xOffset = (newWidth - width) / 2

        val newImage = Mat.zeros(newHeight, newWidth, CvType.CV_8U)

        val roi = newImage.submat(yOffset, yOffset + height, xOffset, xOffset + width)
        image.copyTo(roi)

        return newImage
    }
}