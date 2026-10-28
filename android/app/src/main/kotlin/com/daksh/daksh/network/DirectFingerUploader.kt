package com.daksh.daksh.network

import android.util.Log
import android.os.SystemClock
import com.daksh.daksh.data.remote.FingerDataY
import com.daksh.daksh.data.remote.FingerPrintScan1Request
import com.daksh.daksh.data.remote.RetrofitInstance
import com.daksh.daksh.ScanResultStore
import com.daksh.daksh.model.EnhancedImageResult
import com.daksh.daksh.model.ScanStep
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import java.io.File
import java.io.IOException

sealed class UploadResult {
    data class Success(
        val sentFingers: List<String>,
        val message: String?
    ) : UploadResult()

    data class Failure(
        val reason: String,
        val httpCode: Int? = null,
        val missingFingers: List<String> = emptyList()
    ) : UploadResult()
}

object DirectFingerUploader {

    private const val TAG = "FingerUploader"

    private fun EnhancedImageResult.toFingerDataY(): FingerDataY = FingerDataY(
        pattern = predictedPattern,
        ridgeCount = ridgeCount,
        patternCode = patternCode
    )

    /** The exact body sent to POST /fingerprintscan1 (also used by the review dialog). */
    fun buildScan1Request(scannedMap: Map<ScanStep, EnhancedImageResult>) = FingerPrintScan1Request(
        fingerLeftThumb = scannedMap[ScanStep.LEFT_THUMB_IND]?.toFingerDataY()
            ?: scannedMap[ScanStep.LEFT_THUMB_GROUP]?.toFingerDataY(),
        fingerLeftIndex = scannedMap[ScanStep.LEFT_INDEX_IND]?.toFingerDataY(),
        fingerLeftMiddle = scannedMap[ScanStep.LEFT_MIDDLE_IND]?.toFingerDataY(),
        fingerLeftRing = scannedMap[ScanStep.LEFT_RING_IND]?.toFingerDataY(),
        fingerLeftLittle = scannedMap[ScanStep.LEFT_LITTLE_IND]?.toFingerDataY(),
        fingerRightThumb = scannedMap[ScanStep.RIGHT_THUMB_IND]?.toFingerDataY()
            ?: scannedMap[ScanStep.RIGHT_THUMB_GROUP]?.toFingerDataY(),
        fingerRightIndex = scannedMap[ScanStep.RIGHT_INDEX_IND]?.toFingerDataY(),
        fingerRightMiddle = scannedMap[ScanStep.RIGHT_MIDDLE_IND]?.toFingerDataY(),
        fingerRightRing = scannedMap[ScanStep.RIGHT_RING_IND]?.toFingerDataY(),
        fingerRightLittle = scannedMap[ScanStep.RIGHT_LITTLE_IND]?.toFingerDataY(),
       isSubmitted = true
    )

    /**
     * Two server saves, in order: 1) ridge metadata (POST /fingerprintscan1), then 2) HD images (PATCH /fingerprintscanImage).
     * Images are NOT sent if the metadata save fails.
     * @param requireAll if true, nothing is sent unless all 10 fingers have a valid file.
     */
    suspend fun uploadAllFingerprints(
        token: String,
        userDataId: String,
        scannedMap: Map<ScanStep, EnhancedImageResult>,
        requireAll: Boolean = true,
        /** true (individual-finger flow): validate files first, and stop if metadata save fails.
         *  false (default, other flows): legacy behaviour - metadata first, failures only logged. */
        strictMetadata: Boolean = false
    ): UploadResult = withContext(Dispatchers.IO) {
        val uploadStarted = SystemClock.elapsedRealtime()
        try {
            val auth = if (token.startsWith("Bearer ")) token else "Bearer $token"

            if (strictMetadata) {
                if (token.isBlank() || userDataId.isBlank()) {
                    return@withContext UploadResult.Failure("Missing authorization or user ID")
                }
                val mismatched = scannedMap.filter { (step, result) -> result.step != step }.keys
                if (mismatched.isNotEmpty()) {
                    return@withContext UploadResult.Failure("Finger identity mismatch: ${mismatched.joinToString()}")
                }
                val invalid = scannedMap.filter { (_, result) ->
                    result.predictedPattern.isBlank() || result.ridgeCount <= 0 || result.patternCode.isBlank()
                }.keys
                if (invalid.isNotEmpty()) {
                    return@withContext UploadResult.Failure(
                        "Pattern/ridge data unavailable for ${invalid.joinToString()}; re-scan these fingers."
                    )
                }
            }

            // Legacy behaviour (strictMetadata = false): post metadata first, ignore its failure
            if (!strictMetadata) {
                try {
                    val legacyResp = RetrofitInstance.apiService.fingerPrintScan1(
                        auth = auth,
                        userDataId = userDataId,
                        fingerPrintScan1Request = buildScan1Request(scannedMap)
                    )
                    Log.d(TAG, "fingerPrintScan1 HTTP ${legacyResp.code()}")
                } catch (e: Exception) {
                    Log.e(TAG, "fingerPrintScan1 failed (continuing image upload): ${e.message}")
                }
            }

            fun createPart(partName: String, vararg steps: ScanStep): MultipartBody.Part? {
                for (step in steps) {
                    val result = scannedMap[step] ?: continue
                    // Individual scans require the real enhanced file, never silently send raw.
                    val path = if (strictMetadata) result.enhancedPath else result.enhancedPath.ifEmpty { result.rawPath }
                    if (path.isEmpty()) continue
                    val file = File(path)
                   /* if (strictMetadata && !file.name.endsWith("${step.name}_enhanced.jpg")) {*/
                    if (strictMetadata && !file.name.endsWith("${step.name}_enhanced.jpg")) {
                        Log.e(TAG, "Image file identity mismatch for $partName: ${file.name}")
                        continue
                    }
                    if (!ScanResultStore.isValidJpeg(file)) {
                        Log.w(TAG, "$partName: JPEG missing, incomplete or invalid: $path")
                        continue
                    }
                    val uploadFileName = file.name
                    val mime = "image/jpeg"
                    Log.d(TAG, "Uploading $partName <- $uploadFileName (${file.length() / 1024} KB, $mime)")
                    return MultipartBody.Part.createFormData(
                        partName, uploadFileName, file.asRequestBody(mime.toMediaTypeOrNull())
                    )
                }

                return null
            }
                ////////todo raw image work

               /* fun createOrgPart(partName: String, vararg steps: ScanStep): MultipartBody.Part? {
                    for (step in steps) {
                        val result = scannedMap[step] ?: continue
                        val path = result.rawPath.ifEmpty { result.enhancedPath }
                        if (path.isEmpty()) continue
                        val file = File(path)
                        if (!ScanResultStore.isValidJpeg(file)) {
                            Log.w(TAG, "$partName (raw): JPEG missing, incomplete or invalid: $path")
                            continue
                        }
                        val uploadFileName = file.name
                        val mime = "image/jpeg"
                        Log.d(TAG, "Uploading RAW $partName <- $uploadFileName (${file.length() / 1024} KB, $mime)")
                        return MultipartBody.Part.createFormData(
                            partName, uploadFileName, file.asRequestBody(mime.toMediaTypeOrNull())
                        )
                    }




                return null
            }*/

            val parts = linkedMapOf(
                "leftThumb" to createPart("leftThumb", ScanStep.LEFT_THUMB_IND, ScanStep.LEFT_THUMB_GROUP),
                "leftIndex" to createPart("leftIndex", ScanStep.LEFT_INDEX_IND),
                "leftMiddle" to createPart("leftMiddle", ScanStep.LEFT_MIDDLE_IND),
                "leftRing" to createPart("leftRing", ScanStep.LEFT_RING_IND),
                "leftLittle" to createPart("leftLittle", ScanStep.LEFT_LITTLE_IND),
                "rightThumb" to createPart("rightThumb", ScanStep.RIGHT_THUMB_IND, ScanStep.RIGHT_THUMB_GROUP),
                "rightIndex" to createPart("rightIndex", ScanStep.RIGHT_INDEX_IND),
                "rightMiddle" to createPart("rightMiddle", ScanStep.RIGHT_MIDDLE_IND),
                "rightRing" to createPart("rightRing", ScanStep.RIGHT_RING_IND),
                "rightLittle" to createPart("rightLittle", ScanStep.RIGHT_LITTLE_IND)
            )
               /* val orgParts = linkedMapOf(
                    "leftThumbOrg" to createOrgPart("leftThumbOrg", ScanStep.LEFT_THUMB_IND, ScanStep.LEFT_THUMB_GROUP),
                    "leftIndexOrg" to createOrgPart("leftIndexOrg", ScanStep.LEFT_INDEX_IND),
                    "leftMiddleOrg" to createOrgPart("leftMiddleOrg", ScanStep.LEFT_MIDDLE_IND),
                    "leftRingOrg" to createOrgPart("leftRingOrg", ScanStep.LEFT_RING_IND),
                    "leftLittleOrg" to createOrgPart("leftLittleOrg", ScanStep.LEFT_LITTLE_IND),
                    "rightThumbOrg" to createOrgPart("rightThumbOrg", ScanStep.RIGHT_THUMB_IND, ScanStep.RIGHT_THUMB_GROUP),
                    "rightIndexOrg" to createOrgPart("rightIndexOrg", ScanStep.RIGHT_INDEX_IND),
                    "rightMiddleOrg" to createOrgPart("rightMiddleOrg", ScanStep.RIGHT_MIDDLE_IND),
                    "rightRingOrg" to createOrgPart("rightRingOrg", ScanStep.RIGHT_RING_IND),
                    "rightLittleOrg" to createOrgPart("rightLittleOrg", ScanStep.RIGHT_LITTLE_IND)
                )*/
            val missing = parts.filterValues { it == null }.keys.toList()
            val sent = parts.filterValues { it != null }.keys.toList()

            if (sent.isEmpty()) {
                return@withContext UploadResult.Failure("No fingerprint files to upload", missingFingers = missing)
            }
            if (requireAll && missing.isNotEmpty()) {
                return@withContext UploadResult.Failure(
                    "Missing fingers: ${missing.joinToString()}", missingFingers = missing
                )
            }

            // Strict mode only: metadata must be accepted before images are sent
           /* if (strictMetadata) {
                // ── SAVE 1: ridge metadata (pattern, ridge count, pattern code) ──
                // Images are only sent after the metadata has been accepted by the server.
                Log.d(TAG, "Saving metadata (fingerprintscan1) for userDataId = '$userDataId'")
                val scan1Response = RetrofitInstance.apiService.fingerPrintScan1(
                    auth = auth,
                    userDataId = userDataId,
                    fingerPrintScan1Request = buildScan1Request(scannedMap)
                )
                val scan1Body = scan1Response.body()
                Log.d(TAG, "fingerprintscan1 HTTP ${scan1Response.code()} body=$scan1Body")
                if (!scan1Response.isSuccessful) {
                    val err = scan1Response.errorBody()?.string()
                    return@withContext UploadResult.Failure(
                        "Metadata save failed: HTTP ${scan1Response.code()} $err", scan1Response.code(), missing
                    )
                }
                if (scan1Body == null) {
                    return@withContext UploadResult.Failure("Empty metadata response; refusing to upload images")
                }
                if (scan1Body.status_code != null && scan1Body.status_code !in 200..299) {
                    return@withContext UploadResult.Failure(
                        scan1Body.message ?: "Metadata rejected by server", scan1Body.status_code, missing
                    )
                }
            }*/


            // Strict mode only: metadata must be accepted before images are sent
            if (strictMetadata) {
                val scan1Request = buildScan1Request(scannedMap)
                val metaStarted = SystemClock.elapsedRealtime()

                // ── Log exactly what we are about to send ──
                Log.d(TAG, "┌── SAVE METADATA (fingerprintscan1) ──")
                Log.d(TAG, "│ userDataId = '$userDataId'")
                Log.d(TAG, "│ auth = ${auth.take(15)}... (len=${auth.length})")
                Log.d(TAG, "│ request = $scan1Request")
                listOf(
                    "leftThumb" to scan1Request.fingerLeftThumb,
                    "leftIndex" to scan1Request.fingerLeftIndex,
                    "leftMiddle" to scan1Request.fingerLeftMiddle,
                    "leftRing" to scan1Request.fingerLeftRing,
                    "leftLittle" to scan1Request.fingerLeftLittle,
                    "rightThumb" to scan1Request.fingerRightThumb,
                    "rightIndex" to scan1Request.fingerRightIndex,
                    "rightMiddle" to scan1Request.fingerRightMiddle,
                    "rightRing" to scan1Request.fingerRightRing,
                    "rightLittle" to scan1Request.fingerRightLittle
                ).forEach { (name, data) ->
                    Log.d(TAG, "│ $name -> pattern='${data?.pattern}' ridgeCount=${data?.ridgeCount} patternCode='${data?.patternCode}'")
                }
                // If you use Gson: Log.d(TAG, "│ JSON = ${com.google.gson.Gson().toJson(scan1Request)}")

                val scan1Response = RetrofitInstance.apiService.fingerPrintScan1(
                    auth = auth,
                    userDataId = userDataId,
                    fingerPrintScan1Request = scan1Request
                )

                // ── Log the response ──
                val rawReq = scan1Response.raw().request
                val scan1Body = scan1Response.body()
                // errorBody().string() can only be read ONCE, so read it here and reuse it
                val errBody = if (!scan1Response.isSuccessful) scan1Response.errorBody()?.string() else null

                Log.d(TAG, "│ URL = ${rawReq.method} ${rawReq.url}")
                Log.d(TAG, "│ HTTP ${scan1Response.code()} ${scan1Response.message()} in ${SystemClock.elapsedRealtime() - metaStarted}ms")
                Log.d(TAG, "│ response headers = ${scan1Response.headers()}")
                Log.d(TAG, "│ body = $scan1Body")
                Log.d(TAG, "│ errorBody = $errBody")
                Log.d(TAG, "└── END SAVE METADATA ──")

                if (!scan1Response.isSuccessful) {
                    return@withContext UploadResult.Failure(
                        "Metadata save failed: HTTP ${scan1Response.code()} $errBody", scan1Response.code(), missing
                    )
                }
                if (scan1Body == null) {
                    return@withContext UploadResult.Failure("Empty metadata response; refusing to upload images")
                }
                if (scan1Body.status_code != null && scan1Body.status_code !in 200..299) {
                    return@withContext UploadResult.Failure(
                        scan1Body.message ?: "Metadata rejected by server", scan1Body.status_code, missing
                    )
                }
            }

            // ── SAVE 2: enhanced images ──
            Log.d(TAG, "Sending $sent image files for userData_id = '$userDataId'")

            val imageUploadStarted = SystemClock.elapsedRealtime()
            val response = RetrofitInstance.apiService.fingerprintscanImage(
                auth = auth,
                userDataId = userDataId,
                leftThumb = parts["leftThumb"],
                leftIndex = parts["leftIndex"],
                leftMiddle = parts["leftMiddle"],
                leftRing = parts["leftRing"],
                leftLittle = parts["leftLittle"],
                rightThumb = parts["rightThumb"],
                rightIndex = parts["rightIndex"],
                rightMiddle = parts["rightMiddle"],
                rightRing = parts["rightRing"],
                rightLittle = parts["rightLittle"]
            )

            val body = response.body()
            Log.d("FP_PERF", "Image HTTP upload: ${SystemClock.elapsedRealtime() - imageUploadStarted}ms; total upload: ${SystemClock.elapsedRealtime() - uploadStarted}ms")
            Log.d(TAG, "HTTP ${response.code()} body=$body")

            when {
                !response.isSuccessful -> {
                    val err = response.errorBody()?.string()
                    Log.e(TAG, "Upload failed: HTTP ${response.code()} $err")
                    UploadResult.Failure("HTTP ${response.code()}: $err", response.code(), missing)
                }
                body == null -> UploadResult.Failure("Empty response from server", response.code(), missing)
                body.status_code != null && body.status_code !in 200..299 ->
                    UploadResult.Failure(body.message ?: "Server rejected upload", body.status_code, missing)
                body.status_code == null && body.message?.contains("success", ignoreCase = true) != true ->
                    UploadResult.Failure(body.message ?: "Unexpected response", response.code(), missing)
                else -> UploadResult.Success(sent, body.message)
            }
        } catch (e: CancellationException) {
            throw e
        } catch (e: IOException) {
            Log.e(TAG, "Network error", e)
            UploadResult.Failure("Network error: ${e.message}")
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error", e)
            UploadResult.Failure("Unexpected error: ${e.message}")
        }
    }
}
