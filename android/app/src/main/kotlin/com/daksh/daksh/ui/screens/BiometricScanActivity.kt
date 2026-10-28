package com.daksh.daksh.ui.screens

import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import android.os.Bundle
import android.os.SystemClock
import android.util.Log
import android.view.WindowManager

import androidx.activity.ComponentActivity
import androidx.activity.OnBackPressedCallback
import androidx.activity.compose.setContent

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.shape.RoundedCornerShape

import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton

import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue

import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

import com.daksh.daksh.ScanResultStore
import com.daksh.daksh.model.EnhancedImageResult
import com.daksh.daksh.model.ScanMode
import com.daksh.daksh.model.ScanStep
import com.daksh.daksh.network.DirectFingerUploader
import com.daksh.daksh.network.UploadResult
import com.daksh.daksh.processing.FingerprintProcessor
import com.daksh.daksh.ui.dialogs.ScanCaptureReviewDialog

import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.asCoroutineDispatcher
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.concurrent.Executors
import androidx.compose.runtime.LaunchedEffect


class BiometricScanActivity : ComponentActivity() {

    companion object {
        const val EXTRA_STATUS = "STATUS"
        const val EXTRA_USER_DATA_ID = "USER_DATA_ID"
        const val EXTRA_MESSAGE = "MESSAGE"
        const val EXTRA_UPLOADED_COUNT = "UPLOADED_COUNT"

        const val STATUS_SUCCESS = "SUCCESS"
        const val STATUS_FAILED = "FAILED"
        const val STATUS_CANCELLED = "CANCELLED"
    }

    private var userDataId: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
        )

        window.attributes = window.attributes.apply {
            screenBrightness = 1.0f
        }

        val token = intent?.getStringExtra("USER_TOKEN") ?: ""
        userDataId = intent?.getStringExtra("USER_DATA_ID") ?: ""

        onBackPressedDispatcher.addCallback(
            this,
            object : OnBackPressedCallback(true) {
                override fun handleOnBackPressed() {
                    finishWith(STATUS_CANCELLED)
                }
            }
        )

        setContent {
            MaterialTheme {
                BiometricScanHost(
                    token = token,
                    userDataId = userDataId,
                    onSuccess = { count, message ->
                        finishWith(
                            STATUS_SUCCESS,
                            message,
                            count
                        )
                    },
                    onFailed = { reason ->
                        finishWith(
                            STATUS_FAILED,
                            reason
                        )
                    },
                    onClose = {
                        finishWith(STATUS_CANCELLED)
                    }
                )
            }
        }
    }

    private fun finishWith(
        status: String,
        message: String? = null,
        uploaded: Int = 0
    ) {
        val data = Intent().apply {
            putExtra(EXTRA_STATUS, status)
            putExtra(EXTRA_USER_DATA_ID, userDataId)
            putExtra(EXTRA_MESSAGE, message)
            putExtra(EXTRA_UPLOADED_COUNT, uploaded)
        }

        setResult(
            if (status == STATUS_CANCELLED)
                Activity.RESULT_CANCELED
            else
                Activity.RESULT_OK,
            data
        )

        finish()
    }
}

/**
 * Individual 10-finger scanning flow.
 *
 * Enhancement begins as soon as each finger is captured.
 * Upload begins only after all 10 enhanced results are available.
 */
/*
@Composable
fun BiometricScanHost(
    token: String,
    userDataId: String,
    onSuccess: (uploadedCount: Int, message: String?) -> Unit,
    onFailed: (reason: String) -> Unit,
    onClose: () -> Unit
) {

    val context = LocalContext.current
    val appContext = context.applicationContext

    val scope = rememberCoroutineScope()
    // ThreadLocal model instances in FingerprintProcessor are reused on these
    // two stable workers, rather than constructing models on many Default threads.
    // Bounded parallelism also reduces RAM/thermal contention on midrange phones.
    val enhancementDispatcher = remember {
        Executors.newFixedThreadPool(2) { task ->
            Thread(task, "daksh-fp-enhancement").apply { isDaemon = true }
        }.asCoroutineDispatcher()
    }
    DisposableEffect(enhancementDispatcher) {
        onDispose { enhancementDispatcher.close() }
    }

    var currentStepIndex by remember { mutableIntStateOf(0) }
    var selectedMode by remember { mutableStateOf(ScanMode.FAST) }
    var showReviewDialog by remember { mutableStateOf(false) }
    var savingText by remember { mutableStateOf<String?>(null) }
    var uploadError by remember { mutableStateOf<String?>(null) }



    //////////todo manage local start
    val effectiveUserDataId = remember(userDataId) {
        if (userDataId.isBlank()) "default_session" else userDataId
    }

    val previews = remember(effectiveUserDataId) { mutableStateMapOf<ScanStep, Bitmap>() }
    val rawCaptures = remember(effectiveUserDataId) { HashMap<ScanStep, Bitmap>() }
    val enhancedResults = remember(effectiveUserDataId) { HashMap<ScanStep, EnhancedImageResult>() }
    val enhancementJobs = remember(effectiveUserDataId) { HashMap<ScanStep, Deferred<Result<EnhancedImageResult>>>() }
    /////todo manage local end


    */
/* old work

    // Extracted fingertip previews.
    val previews = remember { mutableStateMapOf<ScanStep, Bitmap>() }

    // Original camera captures.
    val rawCaptures = remember { HashMap<ScanStep, Bitmap>() }

    // Successfully enhanced and saved results.
    val enhancedResults = remember { HashMap<ScanStep, EnhancedImageResult>() }

    // Background enhancement jobs.
    val enhancementJobs = remember { HashMap<ScanStep, Deferred<Result<EnhancedImageResult>>>() }
    //old work

*//*


    val steps = remember {
        listOf(
            ScanStep.LEFT_THUMB_IND,
            ScanStep.LEFT_INDEX_IND,
            ScanStep.LEFT_MIDDLE_IND,
            ScanStep.LEFT_RING_IND,
            ScanStep.LEFT_LITTLE_IND,

            ScanStep.RIGHT_THUMB_IND,
            ScanStep.RIGHT_INDEX_IND,
            ScanStep.RIGHT_MIDDLE_IND,
            ScanStep.RIGHT_RING_IND,
            ScanStep.RIGHT_LITTLE_IND
        )
    }
    //////////todo manage local start
    LaunchedEffect(effectiveUserDataId) {
        previews.clear()
        rawCaptures.clear()
        enhancedResults.clear()
        enhancementJobs.values.forEach { it.cancel() }
        enhancementJobs.clear()

        val savedSession = ScanResultStore.loadUserSession(appContext, effectiveUserDataId)
        if (savedSession.isNotEmpty()) {
            savedSession.forEach { (step, savedCapture) ->
                previews[step] = savedCapture.cropBitmap
                rawCaptures[step] = savedCapture.rawBitmap
                enhancedResults[step] = savedCapture.result
            }
            val firstUnscanned = steps.indexOfFirst { it !in previews }
            if (firstUnscanned >= 0) currentStepIndex = firstUnscanned
        }
    }
    /////todo manage local end


    val allCaptured = steps.all { it in previews }

    suspend fun enhanceAndPersist(
        step: ScanStep,
        raw: Bitmap,
        crop: Bitmap
    ): EnhancedImageResult {

        val cpuStarted = SystemClock.elapsedRealtime()
        val enhanced = withContext(enhancementDispatcher) {
            currentCoroutineContext().ensureActive()
            FingerprintProcessor.processAndEnhanceImage(
                appContext,
                raw,
                step,
                preCropped = crop,
                saveIntermediateImages = false
            ).also { currentCoroutineContext().ensureActive() }
        }
        Log.d("FP_PERF", "ML/OpenCV ${step.name}: ${SystemClock.elapsedRealtime() - cpuStarted}ms")

        val diskStarted = SystemClock.elapsedRealtime()
        //old
      ///  val json = ScanResultStore.saveParallel(appContext, enhanced)
        //////////todo manage local start
        val json = ScanResultStore.saveUserCapture(appContext, effectiveUserDataId, enhanced)
        /////todo manage local end
        Log.d("FP_PERF", "JPEG persist ${step.name}: ${SystemClock.elapsedRealtime() - diskStarted}ms")

        return enhanced.copy(
            enhancedPath = json.getString("enhancedPath"),
            rawPath = json.getString("originalPath")
        )
    }

    fun startEnhancingInBackground(
        step: ScanStep,
        raw: Bitmap,
        crop: Bitmap
    ) {

        enhancementJobs.remove(step)?.cancel()

        enhancementJobs[step] = scope.async(enhancementDispatcher) {
            val started = SystemClock.elapsedRealtime()
            try {
                Log.d("FP_PERF", "Enhancement started: ${step.name}")
                val result: EnhancedImageResult = enhanceAndPersist(step, raw, crop)
                val elapsed = SystemClock.elapsedRealtime() - started
                Log.d("FP_PERF", "Enhancement completed ${step.name}: ${elapsed}ms")

                withContext(Dispatchers.Main.immediate) {
                    // Retakes cancel the old job; do not let its result overwrite the new capture.
                    currentCoroutineContext().ensureActive()
                    if (rawCaptures[step] === raw && previews[step] === crop) {
                        check(result.step == step) { "Wrong finger returned: ${result.step} != $step" }
                        enhancedResults[step] = result
                        rawCaptures.remove(step)
                    } else {
                        Log.w("FP_PERF", "Ignoring outdated enhancement for $step")
                    }
                }

                Result.success(result)
            } catch (e: CancellationException) {
                Log.d("FP_PERF", "Enhancement cancelled: ${step.name}")
                throw e
            } catch (e: Exception) {
                Log.e("FP_PERF", "Enhancement failed: ${step.name}", e)
                Result.failure(e)
            }
        }
    }

    fun startSave() {

        if (savingText != null) return
        savingText = "uploading fingerprints..."

        Log.d("FP_PERF", "Finishing fingerprints..:")
        scope.launch {

            uploadError = null
            val totalStarted = SystemClock.elapsedRealtime()

            try {
                // Snapshot inputs on the main thread. Never read a changing Compose map
                // from worker threads and never pair a different capture with a finger.
                val existing = enhancedResults.toMap()
                val rawAtSave = rawCaptures.toMap()
                val cropsAtSave = previews.toMap()
                val tasksAtSave = enhancementJobs.toMap()
                check(steps.all { it in cropsAtSave }) { "Please scan all 10 fingers first" }

                val completed = steps.map { step ->
                    async {
                        val result = existing[step] ?: run {
                            val task = tasksAtSave[step]
                            if (task != null) {
                                val attempt = task.await()
                                attempt.getOrElse { error ->
                                    Log.w("FP_PERF", "Retrying $step: ${error.message}")
                                    enhanceAndPersist(
                                        step,
                                        checkNotNull(rawAtSave[step]) { "Missing original for $step" },
                                        checkNotNull(cropsAtSave[step]) { "Missing crop for $step" }
                                    )
                                }
                            } else {
                                enhanceAndPersist(
                                    step,
                                    checkNotNull(rawAtSave[step]) { "Missing original for $step" },
                                    checkNotNull(cropsAtSave[step]) { "Missing crop for $step" }
                                )
                            }
                        }
                        check(result.step == step) { "Enhancement identity mismatch for $step" }
                        step to result
                    }
                }.awaitAll().toMap()

                // Freeze the full set once. No partial/old results can enter the request.
                enhancedResults.putAll(completed)
                val uploadSnapshot = steps.associateWith { step ->
                    checkNotNull(completed[step]) { "Missing enhanced result for $step" }
                }

                val enhancementElapsed = SystemClock.elapsedRealtime() - totalStarted
                Log.d("FP_PERF", "All 10 fingers ready in save flow: ${enhancementElapsed}ms")

                savingText = "Uploading fingerprints..."
                val uploadStarted = SystemClock.elapsedRealtime()
                val result = DirectFingerUploader.uploadAllFingerprints(
                    token = token,
                    userDataId = userDataId,
                    scannedMap = uploadSnapshot,
                    strictMetadata = true
                )

                val uploadElapsed = SystemClock.elapsedRealtime() - uploadStarted
                Log.d("FP_PERF", "Upload completed in ${uploadElapsed}ms")

                when (result) {
                    is UploadResult.Success -> {
                        Log.d("BiometricScan", "Upload successful for $userDataId")
                       */
/* withContext(Dispatchers.IO) {
                            ScanResultStore.clearUploaded(uploadSnapshot.values)
                        }*//*

                        //////////todo manage local start
                        withContext(Dispatchers.IO) {
                            ScanResultStore.clearUploaded(uploadSnapshot.values)
                            ScanResultStore.clearUserSession(appContext, effectiveUserDataId)
                        }
                        /////todo manage local end

                        savingText = null
                        onSuccess(result.sentFingers.size, result.message)
                    }

                    is UploadResult.Failure -> {
                        Log.e("BiometricScan", "Upload failed: ${result.reason}")
                        savingText = null
                        uploadError = result.reason
                    }
                }

            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                Log.e("BiometricScan", "Enhancement or upload failed", e)
                savingText = null
                uploadError = " upload failed: ${e.message}"
            }
        }
    }

    Box(modifier = Modifier.fillMaxSize()) {

        ScanStepScreen(
            currentStepIndex = currentStepIndex,
            steps = steps,
            selectedMode = selectedMode,
            onModeChanged = { selectedMode = it },
            onStepSelected = { index ->
                currentStepIndex = index.coerceIn(0, steps.size - 1)
            },
            onCloseClicked = onClose,
            previews = previews,

         */
/*   onImageCaptured = { step, raw, fingertip ->
                if (savingText != null) {
                    Log.w("FP_PERF", "Ignoring capture while saving: $step")
                } else {
                rawCaptures[step] = raw
                previews[step] = fingertip
                enhancedResults.remove(step)

                startEnhancingInBackground(step, raw, fingertip)

                if (steps.all { it in previews }) {
                    showReviewDialog = true
                } else {
                    val next = steps.indices.firstOrNull { steps[it] !in previews }
                    if (next != null) {
                        currentStepIndex = next
                    }
                }
                }
            },*//*



            //////////todo manage local start
            onImageCaptured = { step, raw, fingertip ->
                if (savingText != null) {
                    Log.w("FP_PERF", "Ignoring capture while saving: $step")
                } else {
                    rawCaptures[step] = raw
                    previews[step] = fingertip
                    enhancedResults.remove(step)

                    scope.launch(Dispatchers.IO) {
                        try {
                            ScanResultStore.saveQuickCapture(appContext, effectiveUserDataId, step, raw, fingertip)
                        } catch (e: Exception) {
                            Log.e("BiometricScan", "Quick save failed for $step", e)
                        }
                    }

                    startEnhancingInBackground(step, raw, fingertip)

                    if (steps.all { it in previews }) {
                        showReviewDialog = true
                    } else {
                        steps.indices.firstOrNull { steps[it] !in previews }?.let { currentStepIndex = it }
                    }
                }
            },
                    /////todo manage local end

            onResultGenerated = { },

            onNextStepRequested = {
                currentStepIndex = if (currentStepIndex < steps.size - 1) {
                    currentStepIndex + 1
                } else {
                    0
                }
            }
        )

        if (allCaptured && !showReviewDialog && savingText == null && uploadError == null) {
            StatusPill(
                text = "Review & Save",
                background = Color(0xFF15803D),
                modifier = Modifier.align(Alignment.TopCenter),
                onClick = { showReviewDialog = true }
            )
        }

        if (showReviewDialog) {
            ScanCaptureReviewDialog(
                userDataId = userDataId,
                thumbnails = previews.toMap(),
                onSave = {
                    showReviewDialog = false
                    startSave()
                },
                onDismiss = { showReviewDialog = false }
            )
        }

        savingText?.let { message ->
            Surface(
                color = Color.Black.copy(alpha = 0.85f),
                modifier = Modifier.fillMaxSize()
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        CircularProgressIndicator(color = Color(0xFF00E5FF))
                        Spacer(Modifier.height(16.dp))
                        Text(
                            text = message,
                            color = Color.White,
                            style = MaterialTheme.typography.titleMedium
                        )
                    }
                }
            }
        }

        uploadError?.let { reason ->
            Surface(
                color = Color.Black.copy(alpha = 0.9f),
                modifier = Modifier.fillMaxSize()
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier.padding(24.dp)
                    ) {
                        Text(
                            text = "Save failed",
                            color = Color(0xFFFCA5A5),
                            style = MaterialTheme.typography.titleLarge
                        )
                        Spacer(Modifier.height(8.dp))
                        Text(
                            text = reason,
                            color = Color.White,
                            style = MaterialTheme.typography.bodyMedium
                        )
                        Spacer(Modifier.height(20.dp))
                        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                            TextButton(onClick = { uploadError = null; showReviewDialog = false }) {
                                Text("Back to scans", color = Color.White)
                            }
                            TextButton(onClick = { onFailed(reason) }) {
                                Text("Close", color = Color.White)
                            }
                            Button(onClick = { startSave() }) {
                                Text("Retry")
                            }
                        }
                    }
                }
            }
        }
    }
}
*/

@Composable
fun BiometricScanHost(
    token: String,
    userDataId: String,
    onSuccess: (uploadedCount: Int, message: String?) -> Unit,
    onFailed: (reason: String) -> Unit,
    onClose: () -> Unit
) {

    val context = LocalContext.current
    val appContext = context.applicationContext

    val scope = rememberCoroutineScope()
    // ThreadLocal model instances in FingerprintProcessor are reused on these
    // two stable workers, rather than constructing models on many Default threads.
    // Bounded parallelism also reduces RAM/thermal contention on midrange phones.
    val enhancementDispatcher = remember {
        Executors.newFixedThreadPool(2) { task ->
            Thread(task, "daksh-fp-enhancement").apply { isDaemon = true }
        }.asCoroutineDispatcher()
    }
    DisposableEffect(enhancementDispatcher) {
        onDispose { enhancementDispatcher.close() }
    }

    var currentStepIndex by remember { mutableIntStateOf(0) }
    var selectedMode by remember { mutableStateOf(ScanMode.FAST) }
    var showReviewDialog by remember { mutableStateOf(false) }
    var savingText by remember { mutableStateOf<String?>(null) }
    var uploadError by remember { mutableStateOf<String?>(null) }

    val effectiveUserDataId = remember(userDataId) {
        if (userDataId.isBlank()) "default_session" else userDataId
    }

    // Extracted fingertip previews (keyed by effectiveUserDataId so switching users resets state)
    val previews = remember(effectiveUserDataId) { mutableStateMapOf<ScanStep, Bitmap>() }

    // Original camera captures.
    val rawCaptures = remember(effectiveUserDataId) { HashMap<ScanStep, Bitmap>() }

    // Successfully enhanced and saved results.
    val enhancedResults = remember(effectiveUserDataId) { HashMap<ScanStep, EnhancedImageResult>() }

    // Background enhancement jobs.
    val enhancementJobs = remember(effectiveUserDataId) { HashMap<ScanStep, Deferred<Result<EnhancedImageResult>>>() }

    val steps = remember {
        listOf(
            ScanStep.LEFT_THUMB_IND,
            ScanStep.LEFT_INDEX_IND,
            ScanStep.LEFT_MIDDLE_IND,
            ScanStep.LEFT_RING_IND,
            ScanStep.LEFT_LITTLE_IND,

            ScanStep.RIGHT_THUMB_IND,
            ScanStep.RIGHT_INDEX_IND,
            ScanStep.RIGHT_MIDDLE_IND,
            ScanStep.RIGHT_RING_IND,
            ScanStep.RIGHT_LITTLE_IND
        )
    }

    suspend fun enhanceAndPersist(
        step: ScanStep,
        raw: Bitmap,
        crop: Bitmap
    ): EnhancedImageResult {

        val cpuStarted = SystemClock.elapsedRealtime()
        val enhanced = withContext(enhancementDispatcher) {
            currentCoroutineContext().ensureActive()
            FingerprintProcessor.processAndEnhanceImage(
                appContext,
                raw,
                step,
                preCropped = crop,
                saveIntermediateImages = false
            ).also { currentCoroutineContext().ensureActive() }
        }
        Log.d("FP_PERF", "ML/OpenCV ${step.name}: ${SystemClock.elapsedRealtime() - cpuStarted}ms")

        val diskStarted = SystemClock.elapsedRealtime()
        val json = ScanResultStore.saveUserCapture(appContext, effectiveUserDataId, enhanced)
        Log.d("FP_PERF", "JPEG persist ${step.name}: ${SystemClock.elapsedRealtime() - diskStarted}ms")

        return enhanced.copy(
            enhancedPath = json.getString("enhancedPath"),
            rawPath = json.getString("originalPath")
        )
    }

    fun startEnhancingInBackground(
        step: ScanStep,
        raw: Bitmap,
        crop: Bitmap
    ) {

        enhancementJobs.remove(step)?.cancel()

        enhancementJobs[step] = scope.async(enhancementDispatcher) {
            val started = SystemClock.elapsedRealtime()
            try {
                Log.d("FP_PERF", "Enhancement started: ${step.name}")
                val result: EnhancedImageResult = enhanceAndPersist(step, raw, crop)
                val elapsed = SystemClock.elapsedRealtime() - started
                Log.d("FP_PERF", "Enhancement completed ${step.name}: ${elapsed}ms")

                withContext(Dispatchers.Main.immediate) {
                    // Retakes cancel the old job; do not let its result overwrite the new capture.
                    currentCoroutineContext().ensureActive()
                    if (rawCaptures[step] === raw && previews[step] === crop) {
                        check(result.step == step) { "Wrong finger returned: ${result.step} != $step" }
                        enhancedResults[step] = result
                    } else {
                        Log.w("FP_PERF", "Ignoring outdated enhancement for $step")
                    }
                }

                Result.success(result)
            } catch (e: CancellationException) {
                Log.d("FP_PERF", "Enhancement cancelled: ${step.name}")
                throw e
            } catch (e: Exception) {
                Log.e("FP_PERF", "Enhancement failed: ${step.name}", e)
                Result.failure(e)
            }
        }
    }

    LaunchedEffect(effectiveUserDataId) {
        // Explicitly clear in-memory state so previous candidate's captures never leak
        previews.clear()
        rawCaptures.clear()
        enhancedResults.clear()
        enhancementJobs.values.forEach { it.cancel() }
        enhancementJobs.clear()

        Log.i("FP_OFFLINE", "🚀 BiometricScanHost launched for user [$effectiveUserDataId]")
        val savedSession = ScanResultStore.loadUserSession(appContext, effectiveUserDataId)
        if (savedSession.isNotEmpty()) {
            savedSession.forEach { (step, savedCapture) ->
                previews[step] = savedCapture.cropBitmap
                rawCaptures[step] = savedCapture.rawBitmap
                if (savedCapture.isEnhanced) {
                    enhancedResults[step] = savedCapture.result
                } else {
                    Log.i("FP_OFFLINE", "Resuming background enhancement for $step")
                    startEnhancingInBackground(step, savedCapture.rawBitmap, savedCapture.cropBitmap)
                }
            }
            val firstUnscanned = steps.indexOfFirst { it !in previews }
            if (firstUnscanned >= 0) {
                currentStepIndex = firstUnscanned
                Log.i("FP_OFFLINE", "🎯 Auto-positioned to step index $firstUnscanned (${steps[firstUnscanned].fingerName}) for user [$effectiveUserDataId]")
            } else {
                Log.i("FP_OFFLINE", "🎯 All 10 fingers already scanned for user [$effectiveUserDataId]")
            }
        } else {
            Log.i("FP_OFFLINE", "ℹ️ No saved offline fingerprints found for user [$effectiveUserDataId], starting from step 0 (${steps[0].fingerName})")
        }
    }

    val allCaptured = steps.all { it in previews }

    fun startSave() {

        if (savingText != null) return
        savingText = "uploading fingerprints..."

        Log.d("FP_PERF", "Finishing fingerprints..:")
        scope.launch {

            uploadError = null
            val totalStarted = SystemClock.elapsedRealtime()

            try {
                // Snapshot inputs on the main thread. Never read a changing Compose map
                // from worker threads and never pair a different capture with a finger.
                val existing = enhancedResults.toMap()
                val rawAtSave = rawCaptures.toMap()
                val cropsAtSave = previews.toMap()
                val tasksAtSave = enhancementJobs.toMap()
                check(steps.all { it in cropsAtSave }) { "Please scan all 10 fingers first" }

                val completed = steps.map { step ->
                    async {
                        val result = existing[step] ?: run {
                            val task = tasksAtSave[step]
                            if (task != null) {
                                val attempt = task.await()
                                attempt.getOrElse { error ->
                                    Log.w("FP_PERF", "Retrying $step: ${error.message}")
                                    enhanceAndPersist(
                                        step,
                                        checkNotNull(rawAtSave[step]) { "Missing original for $step" },
                                        checkNotNull(cropsAtSave[step]) { "Missing crop for $step" }
                                    )
                                }
                            } else {
                                enhanceAndPersist(
                                    step,
                                    checkNotNull(rawAtSave[step]) { "Missing original for $step" },
                                    checkNotNull(cropsAtSave[step]) { "Missing crop for $step" }
                                )
                            }
                        }
                        check(result.step == step) { "Enhancement identity mismatch for $step" }
                        step to result
                    }
                }.awaitAll().toMap()

                // Freeze the full set once. No partial/old results can enter the request.
                enhancedResults.putAll(completed)
                val uploadSnapshot = steps.associateWith { step ->
                    checkNotNull(completed[step]) { "Missing enhanced result for $step" }
                }

                val enhancementElapsed = SystemClock.elapsedRealtime() - totalStarted
                Log.d("FP_PERF", "All 10 fingers ready in save flow: ${enhancementElapsed}ms")

                savingText = "Uploading fingerprints..."
                val uploadStarted = SystemClock.elapsedRealtime()
                val result = DirectFingerUploader.uploadAllFingerprints(
                    token = token,
                    userDataId = userDataId,
                    scannedMap = uploadSnapshot,
                    strictMetadata = true
                )

                val uploadElapsed = SystemClock.elapsedRealtime() - uploadStarted
                Log.d("FP_PERF", "Upload completed in ${uploadElapsed}ms")

                when (result) {
                    is UploadResult.Success -> {
                        Log.d("BiometricScan", "Upload successful for $userDataId")
                        withContext(Dispatchers.IO) {
                            ScanResultStore.clearUploaded(uploadSnapshot.values)
                            ScanResultStore.clearUserSession(appContext, effectiveUserDataId)
                        }
                        savingText = null
                        onSuccess(result.sentFingers.size, result.message)
                    }

                    is UploadResult.Failure -> {
                        Log.e("BiometricScan", "Upload failed: ${result.reason}")
                        savingText = null
                        uploadError = result.reason
                    }
                }

            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                Log.e("BiometricScan", "Enhancement or upload failed", e)
                savingText = null
                uploadError = " upload failed: ${e.message}"
            }
        }
    }

    Box(modifier = Modifier.fillMaxSize()) {

        ScanStepScreen(
            currentStepIndex = currentStepIndex,
            steps = steps,
            selectedMode = selectedMode,
            onModeChanged = { selectedMode = it },
            onStepSelected = { index ->
                currentStepIndex = index.coerceIn(0, steps.size - 1)
            },
            onCloseClicked = onClose,
            previews = previews,

            onImageCaptured = { step, _, fingertip ->
                if (savingText != null) {
                    Log.w("FP_PERF", "Ignoring capture while saving: $step")
                } else {
                    rawCaptures[step] = fingertip
                    previews[step] = fingertip
                    enhancedResults.remove(step)

                    scope.launch(Dispatchers.IO) {
                        try {
                            ScanResultStore.saveQuickCapture(appContext, effectiveUserDataId, step, fingertip, fingertip)
                        } catch (e: Exception) {
                            Log.e("BiometricScan", "Quick save failed for $step", e)
                        }
                    }

                    startEnhancingInBackground(step, fingertip, fingertip)

                    if (steps.all { it in previews }) {
                        showReviewDialog = true
                    } else {
                        val next = steps.indices.firstOrNull { steps[it] !in previews }
                        if (next != null) {
                            currentStepIndex = next
                        }
                    }
                }
            },

            onResultGenerated = { },

            onNextStepRequested = {
                currentStepIndex = if (currentStepIndex < steps.size - 1) {
                    currentStepIndex + 1
                } else {
                    0
                }
            }
        )

        if (allCaptured && !showReviewDialog && savingText == null && uploadError == null) {
            StatusPill(
                text = "Review & Save",
                background = Color(0xFF15803D),
                modifier = Modifier.align(Alignment.TopCenter),
                onClick = { showReviewDialog = true }
            )
        }

        if (showReviewDialog) {
            ScanCaptureReviewDialog(
                userDataId = userDataId,
                thumbnails = previews.toMap(),
                onSave = {
                    showReviewDialog = false
                    startSave()
                },
                onDismiss = { showReviewDialog = false }
            )
        }

        savingText?.let { message ->
            Surface(
                color = Color.Black.copy(alpha = 0.85f),
                modifier = Modifier.fillMaxSize()
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        CircularProgressIndicator(color = Color(0xFF00E5FF))
                        Spacer(Modifier.height(16.dp))
                        Text(
                            text = message,
                            color = Color.White,
                            style = MaterialTheme.typography.titleMedium
                        )
                    }
                }
            }
        }

        uploadError?.let { reason ->
            Surface(
                color = Color.Black.copy(alpha = 0.9f),
                modifier = Modifier.fillMaxSize()
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier.padding(24.dp)
                    ) {
                        Text(
                            text = "Save failed",
                            color = Color(0xFFFCA5A5),
                            style = MaterialTheme.typography.titleLarge
                        )
                        Spacer(Modifier.height(8.dp))
                        Text(
                            text = reason,
                            color = Color.White,
                            style = MaterialTheme.typography.bodyMedium
                        )
                        Spacer(Modifier.height(20.dp))
                        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                            TextButton(onClick = { uploadError = null; showReviewDialog = false }) {
                                Text("Back to scans", color = Color.White)
                            }
                            TextButton(onClick = { onFailed(reason) }) {
                                Text("Close", color = Color.White)
                            }
                            Button(onClick = { startSave() }) {
                                Text("Retry")
                            }
                        }
                    }
                }
            }
        }
    }
}


@Composable
private fun StatusPill(
    text: String,
    background: Color,
    modifier: Modifier = Modifier,
    onClick: (() -> Unit)? = null
) {
    Box(
        modifier = modifier
            .statusBarsPadding()
            .padding(top = 64.dp)
            .clip(RoundedCornerShape(20.dp))
            .background(background)
            .then(
                if (onClick != null) {
                    Modifier.clickable { onClick() }
                } else {
                    Modifier
                }
            )
            .padding(horizontal = 16.dp, vertical = 8.dp)
    ) {
        Text(
            text = text,
            color = Color.White,
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold
        )
    }
}
