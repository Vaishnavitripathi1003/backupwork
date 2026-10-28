package com.daksh.daksh.ui.screens

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.OnBackPressedCallback
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.daksh.daksh.ScanResultStore
import com.daksh.daksh.model.EnhancedImageResult
import com.daksh.daksh.model.ScanMode
import com.daksh.daksh.model.ScanStep
import com.daksh.daksh.network.DirectFingerUploader
import com.daksh.daksh.network.UploadResult
import com.daksh.daksh.ui.dialogs.ScanPayloadTestDialog
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class GroupBiometricScanActivity : ComponentActivity() {

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
        Log.d("GroupBiometricScan", "GroupBiometricScanActivity onCreate")
        super.onCreate(savedInstanceState)

        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        window.attributes = window.attributes.apply { screenBrightness = 1.0f }

        val token = intent?.getStringExtra("USER_TOKEN") ?: ""
        userDataId = intent?.getStringExtra("USER_DATA_ID") ?: ""

        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() = finishWith(STATUS_CANCELLED)
        })

        setContent {
            MaterialTheme {
                GroupBiometricScanHost(
                    token = token,
                    userDataId = userDataId,
                    onSuccess = { count, message ->
                        finishWith(STATUS_SUCCESS, message, count)
                    },
                    onFailed = { reason -> finishWith(STATUS_FAILED, reason) },
                    onClose = { finishWith(STATUS_CANCELLED) }
                )
            }
        }
    }

    private fun finishWith(status: String, message: String? = null, uploaded: Int = 0) {
        val data = Intent().apply {
            putExtra(EXTRA_STATUS, status)
            putExtra(EXTRA_USER_DATA_ID, userDataId)
            putExtra(EXTRA_MESSAGE, message)
            putExtra(EXTRA_UPLOADED_COUNT, uploaded)
        }
        setResult(if (status == STATUS_CANCELLED) Activity.RESULT_CANCELED else Activity.RESULT_OK, data)
        finish()
    }
}

@Composable
fun GroupBiometricScanHost(
    token: String,
    userDataId: String,
    onSuccess: (uploadedCount: Int, message: String?) -> Unit,
    onFailed: (reason: String) -> Unit,
    onClose: () -> Unit
) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var currentStepIndex by remember { mutableIntStateOf(0) }
    var selectedMode by remember { mutableStateOf(ScanMode.GROUP_MODE) }
    var isUploading by remember { mutableStateOf(false) }
    var showTestPayloadDialog by remember { mutableStateOf(false) }
    var uploadError by remember { mutableStateOf<String?>(null) }

    val capturedResultsMap = remember { mutableStateMapOf<ScanStep, EnhancedImageResult>() }

    // 4 Group Mode Steps
    val steps = remember {
        listOf(
            ScanStep.LEFT_THUMB_GROUP,
            ScanStep.LEFT_FOUR_FINGERS_GROUP,
            ScanStep.RIGHT_THUMB_GROUP,
            ScanStep.RIGHT_FOUR_FINGERS_GROUP
        )
    }

    fun startUpload() {
        scope.launch {
            isUploading = true
            uploadError = null
            val result = DirectFingerUploader.uploadAllFingerprints(
                token = token,
                userDataId = userDataId,
                scannedMap = capturedResultsMap.toMap(),
                requireAll = false
            )
            isUploading = false

            when (result) {
                is UploadResult.Success -> {
                    Log.d("GroupBiometricScan", "Upload OK for $userDataId")
                    withContext(Dispatchers.IO) { ScanResultStore.clear(context.applicationContext) }
                    onSuccess(result.sentFingers.size, result.message)
                }
                is UploadResult.Failure -> {
                    Log.e("GroupBiometricScan", "Upload failed: ${result.reason}")
                    uploadError = result.reason
                }
            }
        }
    }

    Box(modifier = Modifier.fillMaxSize()) {
        GroupScanStepScreen(
            currentStepIndex = currentStepIndex,
            steps = steps,
            selectedMode = selectedMode,
            onModeChanged = { selectedMode = it },
            onStepSelected = { idx -> currentStepIndex = idx.coerceIn(0, steps.size - 1) },
            onCloseClicked = onClose,

            onResultGenerated = { enhancedResult ->
                scope.launch {
                    val withPaths = withContext(Dispatchers.IO) {
                        val json = ScanResultStore.save(context.applicationContext, enhancedResult)
                        enhancedResult.copy(
                            enhancedPath = json.getString("enhancedPath"),
                            rawPath = json.getString("originalPath")
                        )
                    }
                    capturedResultsMap[withPaths.step] = withPaths

                    // Open Pre-Upload Testing Review Popup when all group steps scanned
                    if (capturedResultsMap.size == steps.size) {
                        showTestPayloadDialog = true
                    } else {
                        val next = steps.indices.firstOrNull { steps[it] !in capturedResultsMap }
                        if (next != null) currentStepIndex = next
                    }
                }
            },

            onNextStepRequested = {
                currentStepIndex = if (currentStepIndex < steps.size - 1) currentStepIndex + 1 else 0
            }
        )

        // Pre-Upload Test Payload Review Popup Dialog
        if (showTestPayloadDialog) {
            ScanPayloadTestDialog(
                userDataId = userDataId,
                token = token,
                scannedMap = capturedResultsMap.toMap(),
                onConfirmSend = {
                    showTestPayloadDialog = false
                    startUpload()
                },
                onDismiss = {
                    showTestPayloadDialog = false
                }
            )
        }

        if (isUploading) {
            Surface(color = Color.Black.copy(alpha = 0.85f), modifier = Modifier.fillMaxSize()) {
                Box(contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        CircularProgressIndicator(color = Color(0xFF00E5FF))
                        Spacer(Modifier.height(16.dp))
                        Text(
                            "Uploading Group Fingerprint Scans to Server...",
                            color = Color.White,
                            style = MaterialTheme.typography.titleMedium
                        )
                    }
                }
            }
        }

        uploadError?.let { reason ->
            Surface(color = Color.Black.copy(alpha = 0.9f), modifier = Modifier.fillMaxSize()) {
                Box(contentAlignment = Alignment.Center) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier.padding(24.dp)
                    ) {
                        Text("Upload failed", color = Color(0xFFFCA5A5), style = MaterialTheme.typography.titleLarge)
                        Spacer(Modifier.height(8.dp))
                        Text(reason, color = Color.White, style = MaterialTheme.typography.bodyMedium)
                        Spacer(Modifier.height(20.dp))
                        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                            TextButton(onClick = { onFailed(reason) }) {
                                Text("Close", color = Color.White)
                            }
                            Button(onClick = { startUpload() }) { Text("Retry") }
                        }
                    }
                }
            }
        }
    }
}
