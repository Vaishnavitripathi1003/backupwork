package com.daksh.daksh.ui.screens

import android.graphics.Bitmap
import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.daksh.daksh.model.EnhancedImageResult
import com.daksh.daksh.model.ScanMode
import com.daksh.daksh.model.ScanStep
import com.daksh.daksh.processing.FingerprintProcessor
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Group screen = state + layout only.
 * Pieces: GroupScanComponents.kt, GroupScannerDialog.kt, GroupReviewDialog.kt,
 *         GroupCameraPreview.kt, GroupScanningOverlay.kt (package ui.camera)
 * Signature is unchanged, so GroupBiometricScanHost needs no edits.
 */
@Composable
fun GroupScanStepScreen(
    currentStepIndex: Int,
    steps: List<ScanStep>,
    selectedMode: ScanMode,
    onModeChanged: (ScanMode) -> Unit,
    onStepSelected: (Int) -> Unit,
    onCloseClicked: () -> Unit,
    onResultGenerated: (EnhancedImageResult) -> Unit,
    onNextStepRequested: () -> Unit,
    showModeSwitch: Boolean = false
) {
    val context = LocalContext.current
    val step = steps[currentStepIndex.coerceIn(0, steps.size - 1)]
    val scope = rememberCoroutineScope()

    var showScanner by remember { mutableStateOf(false) }
    var isTorchEnabled by remember { mutableStateOf(true) }
    var isAutoCaptureMode by remember { mutableStateOf(false) }
    var captureTrigger by remember { mutableStateOf(false) }
    var isProcessing by remember { mutableStateOf(false) }
    var isFocusCorrect by remember { mutableStateOf(false) }
    var detectedFingertipOffset by remember { mutableStateOf<Offset?>(null) }

    var pendingResultForConfirmation by remember { mutableStateOf<EnhancedImageResult?>(null) }
    var capturedMap by remember { mutableStateOf<Map<ScanStep, Bitmap>>(mapOf()) }

    val (code, brainMapping) = remember(step) { getGroupStepCodeAndMapping(step) }
    val activeCaptured = capturedMap[step]

    // Auto capture when focus is locked
    LaunchedEffect(showScanner, isFocusCorrect, isAutoCaptureMode, isProcessing, captureTrigger, pendingResultForConfirmation) {
        if (showScanner && isAutoCaptureMode && isFocusCorrect && !isProcessing && !captureTrigger && pendingResultForConfirmation == null) {
            delay(400)
            captureTrigger = true
        }
    }

    fun closeScanner() {
        showScanner = false
        captureTrigger = false
        isProcessing = false
        isFocusCorrect = false
        detectedFingertipOffset = null
        pendingResultForConfirmation = null
    }

    // ═════════ MAIN SCREEN ═════════
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(listOf(Color(0xFF0A0E17), GroupDarkNavy, Color(0xFF111B3A))))
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding()
        ) {
            GroupTopBar(onCloseClicked = onCloseClicked)

            Column(
                modifier = Modifier
                    .weight(1f)
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 16.dp),
                verticalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                GroupProgressCard(capturedCount = capturedMap.size, totalCount = steps.size)

                GroupStepPills(
                    steps = steps,
                    currentStepIndex = currentStepIndex,
                    capturedMap = capturedMap,
                    onStepSelected = onStepSelected
                )

                GroupActiveStepCard(
                    step = step,
                    code = code,
                    brainMapping = brainMapping,
                    capturedBitmap = activeCaptured
                )

                GroupTapToScanCard(
                    step = step,
                    code = code,
                    capturedBitmap = activeCaptured,
                    onClick = { showScanner = true }
                )

                Spacer(Modifier.height(4.dp))
            }

            GroupBottomScanButton(
                label = if (activeCaptured != null) "Re-Scan ${step.fingerName} ($code)" else "Scan ${step.fingerName} ($code)",
                onClick = { showScanner = true }
            )
        }
    }

    // ═════════ CAMERA POPUP ═════════
    if (showScanner) {
        GroupScannerDialog(
            step = step,
            code = code,
            isTorchEnabled = isTorchEnabled,
            isAutoCaptureMode = isAutoCaptureMode,
            isFocusCorrect = isFocusCorrect,
            isProcessing = isProcessing,
            captureTrigger = captureTrigger,
            detectedFingertipOffset = detectedFingertipOffset,
            onTorchToggle = { isTorchEnabled = !isTorchEnabled },
            onAutoModeToggle = { isAutoCaptureMode = !isAutoCaptureMode },
            onFocusStatusChanged = { isCorrect, offset ->
                isFocusCorrect = isCorrect
                detectedFingertipOffset = offset
            },
            onImageCaptured = { bitmap ->
                captureTrigger = false
                isProcessing = true
                scope.launch {
                    try {
                        val result = withContext(Dispatchers.Default) {
                            FingerprintProcessor.processAndEnhanceImage(context, bitmap, step)
                        }
                        pendingResultForConfirmation = result
                    } catch (t: Throwable) {
                        Log.e("GroupScan", "Processing FAILED -> ${t.javaClass.simpleName}: ${t.message}", t)
                    } finally {
                        isProcessing = false
                    }
                }
            },
            onCameraError = {
                captureTrigger = false
                isProcessing = false
            },
            onCaptureClick = {
                if (!isProcessing && pendingResultForConfirmation == null) captureTrigger = true
            },
            onSkipClick = onNextStepRequested,
            onDismiss = { closeScanner() }
        )
    }

    // ═════════ ACCEPT / REJECT POPUP ═════════
    val reviewResult = pendingResultForConfirmation
    if (reviewResult != null) {
        GroupReviewDialog(
            result = reviewResult,
            step = step,
            code = code,
            onReject = { pendingResultForConfirmation = null },
            onAccept = { accepted ->
                pendingResultForConfirmation = null
                capturedMap = capturedMap + (step to accepted.enhancedBitmap)
                closeScanner()
                onResultGenerated(accepted)
            }
        )
    }
}
