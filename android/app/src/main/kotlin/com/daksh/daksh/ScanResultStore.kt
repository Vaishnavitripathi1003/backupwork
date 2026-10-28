package com.daksh.daksh

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.daksh.daksh.model.EnhancedImageResult
import com.daksh.daksh.model.ScanStep
import org.json.JSONArray
import org.json.JSONObject
import java.io.BufferedOutputStream
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.RandomAccessFile
import java.util.concurrent.atomic.AtomicLong
import android.os.SystemClock
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.withContext

/**
 * Turns native scan results into compressed JPG files for fast transmission.
 * Images are saved as high-quality JPGs (85% compression) to reduce file sizes
 * from ~500KB down to ~120KB per image (4x faster network uploads).
 */
object ScanResultStore {

    private const val DIR_NAME = "scans"
    private val fileSequence = AtomicLong(System.currentTimeMillis())

    // Avoid filename collisions when a finger is retaken while an old job is finishing.
    private fun uniqueStamp(): Long = fileSequence.updateAndGet { last ->
        maxOf(System.currentTimeMillis(), last + 1)
    }

    fun save(context: Context, result: EnhancedImageResult): JSONObject {
        val dir = scanDir(context)
        val stamp = uniqueStamp()
        val originalFile = File(dir, "${stamp}_${result.step.name}_original.jpg")
        val enhancedFile = File(dir, "${stamp}_${result.step.name}_enhanced.jpg")

        try {
            writeJpeg(result.originalBitmap, originalFile)
            writeJpeg(result.enhancedBitmap, enhancedFile)
            return toJson(result.step, result, originalFile, enhancedFile)
        } catch (e: Exception) {
            originalFile.delete()
            enhancedFile.delete()
            throw e
        }
    }

    /**
     * Same filenames, JPEG quality and response as save(), but independently
     * compresses the original and enhanced images on two worker threads.
     * This is used by group capture; the existing synchronous API is retained.
     */
    suspend fun saveParallel(context: Context, result: EnhancedImageResult): JSONObject = coroutineScope {
        val startedAt = SystemClock.elapsedRealtime()
        val dir = scanDir(context)
        val stamp = uniqueStamp()
        val originalFile = File(dir, "${stamp}_${result.step.name}_original.jpg")
        val enhancedFile = File(dir, "${stamp}_${result.step.name}_enhanced.jpg")
        try {
            val originalJob = async(Dispatchers.IO) { writeJpeg(result.originalBitmap, originalFile) }
            val enhancedJob = async(Dispatchers.IO) { writeJpeg(result.enhancedBitmap, enhancedFile) }
            originalJob.await()
            enhancedJob.await()
        } catch (e: Exception) {
            originalFile.delete()
            enhancedFile.delete()
            throw e
        }
        check(isValidJpeg(originalFile) && isValidJpeg(enhancedFile)) {
            "Incomplete JPEG persistence: ${result.step.name}"
        }
        Log.d("FP_PERF", "Group JPG save ${result.step.name}: ${SystemClock.elapsedRealtime() - startedAt}ms")
        toJson(result.step, result, originalFile, enhancedFile)
    }

    /** Fast header/trailer integrity check; does not recompress or alter the image. */
    fun isValidJpeg(file: File): Boolean {
        if (!file.isFile || file.length() < 4) return false
        return try {
            RandomAccessFile(file, "r").use { reader ->
                val first = reader.readUnsignedByte() == 0xFF && reader.readUnsignedByte() == 0xD8
                reader.seek(reader.length() - 2)
                val last = reader.readUnsignedByte() == 0xFF && reader.readUnsignedByte() == 0xD9
                first && last
            }
        } catch (_: IOException) { false }
    }

    /** Remove only the files uploaded by this scan, not other scans still in progress. */
    fun clearUploaded(results: Collection<EnhancedImageResult>): Int {
        var deleted = 0
        results.forEach { result ->
            listOf(result.rawPath, result.enhancedPath).filter { it.isNotBlank() }.forEach { path ->
                if (File(path).delete()) deleted++
            }
        }
        return deleted
    }

    fun stepToJson(step: ScanStep): JSONObject = JSONObject().apply {
        put("name", step.name)
        put("handSide", step.handSide.name)
        put("fingerName", step.fingerName)
        put("title", step.title)
        put("description", step.description)
        put("fingerCount", step.fingerCount)
    }

    /** Deletes every saved scan image. Call when the user logs out / finishes a report. */
    fun clear(context: Context): Int {
        val files = scanDir(context).listFiles() ?: return 0
        var deleted = 0
        for (f in files) if (f.delete()) deleted++
        return deleted
    }

    //////////todo manage local start
    private const val TAG_OFFLINE = "FP_OFFLINE"
    private val manifestLock = Any()

    private fun userScanDir(context: Context, userDataId: String): File {
        val cleanId = if (userDataId.isBlank()) "default_session"
        else userDataId.replace(Regex("[^a-zA-Z0-9_-]"), "_")
        return File(context.filesDir, "$DIR_NAME/$cleanId").apply { mkdirs() }
    }

    private fun updateManifest(dir: File, userDataId: String, step: ScanStep, entry: JSONObject) =
        synchronized(manifestLock) {
            val file = File(dir, "session_manifest.json")
            val json = try { JSONObject(file.readText()) } catch (_: Exception) { JSONObject() }
            json.put(step.name, entry)
            json.put("lastUpdated", System.currentTimeMillis())
            json.put("userDataId", userDataId)
            val tmp = File(dir, "session_manifest.json.tmp")
            tmp.writeText(json.toString(2))
            if (!tmp.renameTo(file)) {
                if (file.exists()) file.delete()
                if (!tmp.renameTo(file)) throw IOException("Could not publish manifest")
            }
        }
    /////todo manage local end






    private fun toJson(
        step: ScanStep,
        r: EnhancedImageResult,
        original: File,
        enhanced: File
    ): JSONObject = JSONObject().apply {
        put("step", step.name)
        put("handSide", step.handSide.name)
        put("fingerName", step.fingerName)
        put("fingerCount", step.fingerCount)
        put("pattern", r.predictedPattern)
        put("description", r.patternDescription)
        put("confidence", r.confidenceScore.toDouble())
        put(
            "topPredictions",
            JSONArray().apply {
                r.topPredictions.forEach { (label, score) ->
                    put(JSONObject().put("label", label).put("score", score.toDouble()))
                }
            }
        )
        put("clarity", r.clarityScore)
        put("contrastBoost", r.contrastBoost)
        put("resolution", r.resolutionText)
        put("originalPath", original.absolutePath)
        put("enhancedPath", enhanced.absolutePath)
    }

    private fun scanDir(context: Context): File =
        File(context.cacheDir, DIR_NAME).apply { mkdirs() }

    /** Atomic per-file publication: no other operation sees a partially written JPG. */
    private fun writeJpeg(bitmap: Bitmap, file: File) {
        val temp = File(file.parentFile, file.name + ".writing")
        val maxDim = 1000
        val targetBmp = if (bitmap.width > maxDim || bitmap.height > maxDim) {
            val scale = maxDim.toFloat() / maxOf(bitmap.width, bitmap.height)
            Bitmap.createScaledBitmap(
                bitmap,
                (bitmap.width * scale).toInt().coerceAtLeast(1),
                (bitmap.height * scale).toInt().coerceAtLeast(1),
                true
            )
        } else {
            bitmap
        }
        try {
            FileOutputStream(temp).use { out ->
                // Buffered writes reduce small disk writes without modifying JPEG bytes.
                val buffered = BufferedOutputStream(out, 64 * 1024)
                if (!targetBmp.compress(Bitmap.CompressFormat.JPEG, 82, buffered)) {
                    throw IOException("JPEG encoding failed: ${file.name}")
                }
                buffered.flush()
                // Keep durability: publish only after all bytes are flushed to disk.
                out.fd.sync()
            }
            if (!isValidJpeg(temp)) throw IOException("JPEG is invalid: ${file.name}")
            if (!temp.renameTo(file)) throw IOException("Could not publish JPEG: ${file.name}")
            if (!isValidJpeg(file)) throw IOException("Published JPEG is invalid: ${file.name}")
        } catch (e: Exception) {
            temp.delete()
            file.delete()
            throw e
        } finally {
            if (targetBmp !== bitmap) targetBmp.recycle()
        }
    }




    //////////todo manage local start
    data class SavedUserCapture(
        val step: ScanStep,
        val rawPath: String,
        val cropPath: String,
        val enhancedPath: String,
        val rawBitmap: Bitmap,
        val cropBitmap: Bitmap,
        val enhancedBitmap: Bitmap,
        val result: EnhancedImageResult,
        val isEnhanced: Boolean
    )
    fun saveQuickCapture(
        context: Context,
        userDataId: String,
        step: ScanStep,
        rawBitmap: Bitmap,
        cropBitmap: Bitmap
    ): JSONObject {
        val dir = userScanDir(context, userDataId)
        val originalFile = File(dir, "${step.name}_original.jpg")
        val cropFile = File(dir, "${step.name}_crop.jpg")

        writeJpeg(rawBitmap, originalFile)
        writeJpeg(cropBitmap, cropFile)

        val json = JSONObject().apply {
            put("step", step.name)
            put("handSide", step.handSide.name)
            put("fingerName", step.fingerName)
            put("fingerCount", step.fingerCount)
            put("pattern", "Captured")
            put("description", "Scanned Fingerprint")
            put("confidence", 0.90)
            put("topPredictions", JSONArray())
            put("clarity", 80)
            put("contrastBoost", 0)
            put("resolution", "${cropBitmap.width}x${cropBitmap.height}")
            put("originalPath", originalFile.absolutePath)
            put("cropPath", cropFile.absolutePath)
            put("enhancedPath", cropFile.absolutePath)
            put("enhanced", false)
        }
        updateManifest(dir, userDataId, step, json)
        Log.i(TAG_OFFLINE, "Quick saved ${step.name} for user [$userDataId]")
        return json
    }

    suspend fun saveUserCapture(
        context: Context,
        userDataId: String,
        result: EnhancedImageResult
    ): JSONObject = coroutineScope {
        val dir = userScanDir(context, userDataId)
        val step = result.step
        val originalFile = File(dir, "${step.name}_original.jpg")
        val enhancedFile = File(dir, "${step.name}_enhanced.jpg")
        val cropFile = File(dir, "${step.name}_crop.jpg")

        // Don't overwrite the raw image saved by saveQuickCapture
        val enhancedJob = async(Dispatchers.IO) { writeJpeg(result.enhancedBitmap, enhancedFile) }
        val originalJob = if (!originalFile.exists())
            async(Dispatchers.IO) { writeJpeg(result.originalBitmap, originalFile) } else null
        enhancedJob.await()
        originalJob?.await()

        val json = toJson(step, result, originalFile, enhancedFile).apply {
            put("cropPath", (if (cropFile.exists()) cropFile else originalFile).absolutePath)
            put("enhanced", true)
        }
        withContext(Dispatchers.IO) { updateManifest(dir, userDataId, step, json) }
        Log.i(TAG_OFFLINE, "Enhanced save for ${step.name} for user [$userDataId]")
        json
    }
    suspend fun loadUserSession(
        context: Context,
        userDataId: String
    ): Map<ScanStep, SavedUserCapture> = withContext(Dispatchers.IO) {
        val dir = userScanDir(context, userDataId)
        val manifestFile = File(dir, "session_manifest.json")
        if (!manifestFile.exists()) return@withContext emptyMap()

        val resultMap = mutableMapOf<ScanStep, SavedUserCapture>()
        try {
            val manifest = JSONObject(manifestFile.readText())
            val keys = manifest.keys()
            while (keys.hasNext()) {
                val key = keys.next()
                if (key == "lastUpdated" || key == "userDataId") continue
                val step = ScanStep.entries.firstOrNull { it.name == key } ?: continue
                val item = manifest.optJSONObject(key) ?: continue

                val origPath = item.optString("originalPath", "")
                val cropPath = item.optString("cropPath", "")
                val enhPath = item.optString("enhancedPath", "")
                val origFile = File(origPath)
                val cropFile = if (cropPath.isNotBlank()) File(cropPath) else origFile
                val enhFile = File(enhPath)

                if (!isValidJpeg(origFile) || !isValidJpeg(enhFile)) {
                    Log.w(TAG_OFFLINE, "Corrupt JPEGs for ${step.name}, skipping")
                    continue
                }

                val rawBitmap = decodeBitmapFromFile(origFile) ?: continue
                val cropBitmap = if (isValidJpeg(cropFile)) decodeBitmapFromFile(cropFile) ?: rawBitmap else rawBitmap
                val enhancedBitmap = decodeBitmapFromFile(enhFile) ?: continue

                val result = EnhancedImageResult(
                    step = step,
                    originalBitmap = cropBitmap,
                    enhancedBitmap = enhancedBitmap,
                    predictedPattern = item.optString("pattern", "Loop"),
                    patternDescription = item.optString("description", "Analyzed"),
                    confidenceScore = item.optDouble("confidence", 0.95).toFloat(),
                    topPredictions = emptyList(),
                    clarityScore = item.optInt("clarity", 80),
                    contrastBoost = item.optInt("contrastBoost", 0),
                    resolutionText = item.optString("resolution", "1000x1000"),
                    enhancedPath = enhPath,
                    rawPath = origPath
                )

                resultMap[step] = SavedUserCapture(
                    step, origPath, cropFile.absolutePath, enhPath,
                    rawBitmap, cropBitmap, enhancedBitmap, result,
                    isEnhanced = item.optBoolean("enhanced", false)
                )
            }
        } catch (e: Exception) {
            Log.e(TAG_OFFLINE, "Error loading session for $userDataId", e)
        }
        resultMap
    }
    fun clearUserSession(context: Context, userDataId: String): Boolean {
        val dir = userScanDir(context, userDataId)
        dir.listFiles()?.forEach { it.delete() }
        return dir.delete()
    }

    private fun decodeBitmapFromFile(file: File, maxDim: Int = 1600): Bitmap? {
        if (!file.exists() || file.length() <= 0) return null
        return try {
            val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeFile(file.absolutePath, bounds)
            val w = bounds.outWidth
            val h = bounds.outHeight
            if (w <= 0 || h <= 0) return null

            var sample = 1
            while (w / (sample * 2) >= maxDim && h / (sample * 2) >= maxDim) sample *= 2

            val opts = BitmapFactory.Options().apply {
                inSampleSize = sample
                inPreferredConfig = Bitmap.Config.ARGB_8888
            }
            BitmapFactory.decodeFile(file.absolutePath, opts)
        } catch (e: Exception) { null }
    }
    /////todo manage local end
}
