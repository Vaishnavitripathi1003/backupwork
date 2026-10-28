package com.daksh.ml

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.ImageDecoder
import android.graphics.Matrix
import android.graphics.Paint
import android.net.Uri
import android.os.Environment
import android.os.SystemClock
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.OutputStream

object ImageProcessUtils {

    fun bitmapToFile(context: Context, bitmap: Bitmap) : File {
        val fileDir = context.filesDir
        val file = File(fileDir, "${SystemClock.uptimeMillis()}.png")
        val outputStream = FileOutputStream(file)
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
        outputStream.flush()
        outputStream.close()
        return file
    }

    fun createSquareBitmap(originalBitmap: Bitmap): Bitmap {
        val maxSize = maxOf(originalBitmap.width, originalBitmap.height)
        val squareBitmap = Bitmap.createBitmap(maxSize, maxSize, Bitmap.Config.ARGB_8888)
        squareBitmap.eraseColor(Color.BLACK)
        val left = (maxSize - originalBitmap.width) / 2
        val top = (maxSize - originalBitmap.height) / 2
        val canvas = Canvas(squareBitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        canvas.drawBitmap(originalBitmap, left.toFloat(), top.toFloat(), paint)
        return squareBitmap
    }

    fun getBitmapFromAsset(context: Context, filePath: String): Bitmap? {
        val inputStream = context.assets.open(filePath)
        return BitmapFactory.decodeStream(inputStream)
    }


    fun saveBitmapToInternalStorage(bitmap: Bitmap) {
        // Create a directory in internal storage
        val directory = File(Environment.getExternalStorageDirectory().toString() + "/YourAppName")
        if (!directory.exists()) {
            directory.mkdirs()
        }

        val fileName = "image.png"
        val file = File(directory, fileName)

        try {
            val stream: OutputStream = FileOutputStream(file)
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.flush()
            stream.close()
        } catch (e: IOException) {
            e.printStackTrace()
        }
    }

    fun saveBitmapToInternalStorage(context: Context, bitmap: Bitmap) {
        val directory: File = context.getDir("imageDir", Context.MODE_PRIVATE)
        val file = File(directory, "sample_bitmap.png")
        try {
            val fos = FileOutputStream(file)
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, fos)
            fos.close()
        } catch (e: IOException) {
            e.printStackTrace()
        }
    }

    fun Bitmap.rotate(angle: Float) : Bitmap {
        val matrix = Matrix()
        matrix.postRotate(angle)

        return Bitmap.createBitmap(
            this,
            0,
            0,
            this.width,
            this.height,
            matrix,
            true
        )
    }

    fun uriToBitmap(context: Context, uri: Uri): Bitmap? {
        return try {
            val source = ImageDecoder.createSource(context.contentResolver, uri)
            ImageDecoder.decodeBitmap(source)
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}