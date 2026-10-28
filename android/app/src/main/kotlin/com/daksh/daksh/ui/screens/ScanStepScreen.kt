package com.daksh.daksh.ui.screens
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import android.content.Context
import android.net.Uri
import android.graphics.ImageDecoder
import android.graphics.Bitmap
import android.graphics.Matrix
import androidx.exifinterface.media.ExifInterface
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBackIosNew
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Camera
import androidx.compose.material.icons.filled.CenterFocusStrong
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.CropFree
import androidx.compose.material.icons.filled.Fingerprint
import androidx.compose.material.icons.filled.FlashOff
import androidx.compose.material.icons.filled.FlashOn
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.Memory
import androidx.compose.material.icons.filled.TouchApp
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.daksh.daksh.model.EnhancedImageResult
import com.daksh.daksh.model.HandSide
import com.daksh.daksh.model.ScanMode
import com.daksh.daksh.model.ScanStep
import com.daksh.daksh.processing.FingerprintProcessor
import com.daksh.daksh.ui.camera.CameraPreview
import com.daksh.daksh.ui.camera.ScanningOverlay
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.asCoroutineDispatcher
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.util.concurrent.Executors

private val DarkNavy = Color(0xFF0B132B)
private val CardNavy = Color(0xFF1E293B)
private val NeonCyan = Color(0xFF00E5FF)
private val IndigoAccent = Color(0xFF4F46E5)
private val SkyBlue = Color(0xFF0284C7)
private val GreenSuccess = Color(0xFF22C55E)

@Composable
fun ScanStepScreen(
    currentStepIndex: Int,
    steps: List<ScanStep>,
    selectedMode: ScanMode,
    onModeChanged: (ScanMode) -> Unit,
    onStepSelected: (Int) -> Unit,
    onCloseClicked: () -> Unit,
    onResultGenerated: (EnhancedImageResult) -> Unit,
    onNextStepRequested: () -> Unit,
    showModeSwitch: Boolean = false,
    previews: Map<ScanStep, Bitmap>? = null,
    processingSteps: Set<ScanStep> = emptySet(),
    onImageCaptured: ((ScanStep, Bitmap, Bitmap) -> Unit)? = null
) {
    val context = LocalContext.current
    val step = steps[currentStepIndex.coerceIn(0, steps.size - 1)]
    val scope = rememberCoroutineScope()
    // A stable thread lets FingerprintProcessor's ThreadLocal detector be reused.
    // It processes crops sequentially to prevent detector state mixing between fingers.
    val fingertipCropDispatcher = remember {
        Executors.newSingleThreadExecutor { task ->
            Thread(task, "daksh-fp-crop").apply { isDaemon = true }
        }.asCoroutineDispatcher()
    }
    DisposableEffect(fingertipCropDispatcher) {
        onDispose { fingertipCropDispatcher.close() }
    }

    var showScanner by remember { mutableStateOf(false) }
    var isTorchEnabled by remember { mutableStateOf(true) }
    var isAutoCaptureMode by remember { mutableStateOf(false) }
    var captureTrigger by remember { mutableStateOf(false) }
    var isProcessing by remember { mutableStateOf(false) }
    var isFocusCorrect by remember { mutableStateOf(false) }
    var detectedFingertipOffset by remember { mutableStateOf<Offset?>(null) }

    var pendingResultForConfirmation by remember { mutableStateOf<EnhancedImageResult?>(null) }
    var pendingCrop by remember { mutableStateOf<PendingCrop?>(null) }




    ///todo for gallery
    val galleryLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        if (uri != null) {
            showScanner = true
            isProcessing = true
            val capturedStep = step
            val bgHandler = onImageCaptured
            scope.launch(Dispatchers.IO) {
                val bitmap = loadBitmapFromUri(context, uri)
                if (bitmap != null) {
                    if (bgHandler != null) {
                        val crop = try {
                            FingerprintProcessor.extractFingertipOnly(context, bitmap, capturedStep)
                        } catch (e: Throwable) { null }
                        launch(Dispatchers.Main) {
                            isProcessing = false
                            pendingCrop = PendingCrop(capturedStep, bitmap, crop ?: bitmap)
                        }
                    } else {
                        val result = FingerprintProcessor.processAndEnhanceImage(context, bitmap, capturedStep)
                        launch(Dispatchers.Main) {
                            isProcessing = false
                            pendingResultForConfirmation = result
                        }
                    }
                } else {
                    launch(Dispatchers.Main) {
                        isProcessing = false
                    }
                }
            }
        }
    }

    var localCaptured by remember { mutableStateOf<Map<ScanStep, Bitmap>>(mapOf()) }
    val capturedMap: Map<ScanStep, Bitmap> = previews ?: localCaptured

    val mappingResult = remember(step) { getStepCodeAndMapping(step) }
    val code = mappingResult.first
    val brainMapping = mappingResult.second

    LaunchedEffect(showScanner, isFocusCorrect, isAutoCaptureMode, isProcessing, captureTrigger, pendingResultForConfirmation, pendingCrop) {
        if (showScanner && isAutoCaptureMode && isFocusCorrect && !isProcessing && !captureTrigger && pendingResultForConfirmation == null && pendingCrop == null) {
            delay(400)
            captureTrigger = true
        }
    }

    val pulseTransition = rememberInfiniteTransition(label = "pulse")
    val pulse by pulseTransition.animateFloat(
        initialValue = 0.94f,
        targetValue = 1.06f,
        animationSpec = infiniteRepeatable(tween(1200), RepeatMode.Reverse),
        label = "pulseScale"
    )

    fun closeScanner() {
        showScanner = false
        captureTrigger = false
        isProcessing = false
        isFocusCorrect = false
        detectedFingertipOffset = null
        pendingResultForConfirmation = null
        pendingCrop = null
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    listOf(Color(0xFF0A0E17), DarkNavy, Color(0xFF111B3A))
                )
            )
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding()
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 12.dp, vertical = 8.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = onCloseClicked) {
                    Icon(
                        Icons.Default.ArrowBackIosNew, "Back",
                        tint = Color.White, modifier = Modifier.size(20.dp)
                    )
                }
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        "BIOMETRIC SCANNER", color = NeonCyan, fontSize = 10.sp,
                        fontWeight = FontWeight.Black, letterSpacing = 0.8.sp
                    )
                    Text(
                        "10–Fingerprint Capture", color = Color.White,
                        fontSize = 16.sp, fontWeight = FontWeight.ExtraBold
                    )
                }
                Spacer(Modifier.size(48.dp))
            }

            Column(
                modifier = Modifier
                    .weight(1f)
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 16.dp),
                verticalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                Surface(
                    color = CardNavy.copy(alpha = 0.85f),
                    shape = RoundedCornerShape(20.dp),
                    border = BorderStroke(1.dp, Color.White.copy(alpha = 0.12f)),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(
                                "${capturedMap.size} of ${steps.size} Scanned",
                                color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.Bold
                            )
                            Text(
                                "${(capturedMap.size * 100 / steps.size)}%",
                                color = NeonCyan, fontSize = 13.sp, fontWeight = FontWeight.Black
                            )
                        }
                        Spacer(Modifier.height(10.dp))
                        val progressVal = (capturedMap.size.toFloat() / steps.size.toFloat()).coerceIn(0f, 1f)
                        LinearProgressIndicator(
                            progress = { progressVal },
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(8.dp)
                                .clip(RoundedCornerShape(6.dp)),
                            color = NeonCyan,
                            trackColor = Color.White.copy(alpha = 0.1f)
                        )
                        Spacer(Modifier.height(14.dp))

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            listOf(
                                HandSide.LEFT to "Left Hand (L1 – L5)",
                                HandSide.RIGHT to "Right Hand (R1 – R5)"
                            ).forEach { (side, label) ->
                                val selected = step.handSide == side
                                Box(
                                    modifier = Modifier
                                        .weight(1f)
                                        .clip(RoundedCornerShape(14.dp))
                                        .background(if (selected) IndigoAccent else Color.White.copy(alpha = 0.08f))
                                        .clickable {
                                            val idx = steps.indexOfFirst { it.handSide == side }
                                            if (idx >= 0) onStepSelected(idx)
                                        }
                                        .padding(vertical = 10.dp),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(label, color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                                }
                            }
                        }
                    }
                }

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    steps.filter { it.handSide == step.handSide }.forEach { s ->
                        val idxInAll = steps.indexOf(s)
                        val isSelected = idxInAll == currentStepIndex
                        val capturedBitmap = capturedMap[s]
                        val sCode = getStepCodeAndMapping(s).first

                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .clip(RoundedCornerShape(14.dp))
                                .background(if (isSelected) Color(0xFF4338CA) else Color.White.copy(alpha = 0.08f))
                                .border(
                                    width = if (isSelected) 1.8.dp else if (capturedBitmap != null) 1.5.dp else 1.dp,
                                    color = if (isSelected) NeonCyan else if (capturedBitmap != null) GreenSuccess else Color.Transparent,
                                    shape = RoundedCornerShape(14.dp)
                                )
                                .clickable { onStepSelected(idxInAll) }
                                .padding(vertical = 8.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Text(
                                    sCode,
                                    color = if (isSelected) Color.White else if (capturedBitmap != null) GreenSuccess else Color.White.copy(alpha = 0.7f),
                                    fontSize = 12.sp, fontWeight = FontWeight.Black
                                )
                                Spacer(Modifier.height(2.dp))

                                if (capturedBitmap != null) {
                                    Box(
                                        modifier = Modifier
                                            .size(28.dp)
                                            .clip(RoundedCornerShape(6.dp))
                                            .border(1.dp, GreenSuccess, RoundedCornerShape(6.dp)),
                                        contentAlignment = Alignment.Center
                                    ) {
                                        Image(
                                            bitmap = capturedBitmap.asImageBitmap(),
                                            contentDescription = "Scanned $sCode",
                                            modifier = Modifier.fillMaxSize(),
                                            contentScale = ContentScale.Crop
                                        )
                                        Icon(
                                            Icons.Default.CheckCircle,
                                            contentDescription = null,
                                            tint = GreenSuccess,
                                            modifier = Modifier.size(10.dp).align(Alignment.TopEnd)
                                        )
                                    }
                                } else {
                                    Text(
                                        s.fingerName.replace("Left ", "").replace("Right ", ""),
                                        color = Color.White.copy(alpha = 0.6f), fontSize = 9.5.sp
                                    )
                                    Spacer(Modifier.height(4.dp))
                                    Box(
                                        Modifier
                                            .size(6.dp)
                                            .background(
                                                if (isSelected) NeonCyan else Color.White.copy(alpha = 0.3f),
                                                CircleShape
                                            )
                                    )
                                }
                            }
                        }
                    }
                }

                Surface(
                    color = CardNavy.copy(alpha = 0.85f),
                    shape = RoundedCornerShape(18.dp),
                    border = BorderStroke(1.dp, Color.White.copy(alpha = 0.12f)),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(modifier = Modifier.padding(14.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Box(
                                    modifier = Modifier
                                        .clip(RoundedCornerShape(8.dp))
                                        .background(SkyBlue)
                                        .padding(horizontal = 8.dp, vertical = 3.dp)
                                ) {
                                    Text(code, color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Black)
                                }
                                Spacer(Modifier.width(8.dp))
                                Text(
                                    step.fingerName, color = Color.White,
                                    fontSize = 15.sp, fontWeight = FontWeight.ExtraBold
                                )
                            }

                            val activeCaptured = capturedMap[step]
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(12.dp))
                                    .background(if (activeCaptured != null) Color(0xFF15803D) else Color(0xFF1E1B4B))
                                    .border(1.dp, if (activeCaptured != null) GreenSuccess else IndigoAccent, RoundedCornerShape(12.dp))
                                    .padding(horizontal = 10.dp, vertical = 4.dp)
                            ) {
                                Text(
                                    text = when {
                                        step in processingSteps -> "⏳ Enhancing…"
                                        activeCaptured != null -> "✓ Scanned"
                                        else -> "Ready to Scan"
                                    },
                                    color = if (activeCaptured != null) Color(0xFF86EFAC) else Color(0xFFC7D2FE),
                                    fontSize = 10.5.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                        Spacer(Modifier.height(8.dp))

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Row(
                                modifier = Modifier.weight(1f),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(Icons.Default.Memory, null, tint = NeonCyan, modifier = Modifier.size(14.dp))
                                Spacer(Modifier.width(6.dp))
                                Text("Maps to: $brainMapping", color = Color(0xFF94A3B8), fontSize = 11.sp)
                            }

                            val activeBmp = capturedMap[step]
                            if (activeBmp != null) {
                                Spacer(Modifier.width(8.dp))
                                Image(
                                    bitmap = activeBmp.asImageBitmap(),
                                    contentDescription = "Active Fingerprint",
                                    modifier = Modifier
                                        .size(36.dp)
                                        .clip(RoundedCornerShape(8.dp))
                                        .border(1.dp, GreenSuccess, RoundedCornerShape(8.dp)),
                                    contentScale = ContentScale.Crop
                                )
                            }
                        }
                    }
                }

                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(28.dp))
                        .background(
                            Brush.verticalGradient(
                                listOf(Color(0xFF16213E), Color(0xFF0F1A33))
                            )
                        )
                        .border(
                            width = 2.dp,
                            color = if (capturedMap.containsKey(step)) GreenSuccess else NeonCyan.copy(alpha = 0.8f),
                            shape = RoundedCornerShape(28.dp)
                        )
                        .clickable { showScanner = true }
                        .padding(vertical = 24.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        val activeCapturedBmp = capturedMap[step]

                        if (activeCapturedBmp != null) {
                            Box(
                                modifier = Modifier
                                    .size(110.dp)
                                    .clip(CircleShape)
                                    .border(2.dp, GreenSuccess, CircleShape),
                                contentAlignment = Alignment.Center
                            ) {
                                Image(
                                    bitmap = activeCapturedBmp.asImageBitmap(),
                                    contentDescription = "Scanned $code",
                                    modifier = Modifier.fillMaxSize(),
                                    contentScale = ContentScale.Crop
                                )
                                Box(
                                    modifier = Modifier
                                        .size(28.dp)
                                        .background(GreenSuccess, CircleShape)
                                        .align(Alignment.BottomEnd),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Icon(
                                        Icons.Default.CheckCircle,
                                        contentDescription = null,
                                        tint = Color.White,
                                        modifier = Modifier.size(18.dp)
                                    )
                                }
                            }
                            Spacer(Modifier.height(12.dp))
                            Text(
                                "✓ $code CAPTURED CLEARLY",
                                color = GreenSuccess, fontSize = 13.sp,
                                fontWeight = FontWeight.Black, letterSpacing = 0.8.sp
                            )
                            Spacer(Modifier.height(4.dp))
                            Text(
                                "Tap to re-scan this finger if needed",
                                color = Color.White.copy(alpha = 0.6f), fontSize = 11.sp
                            )
                        } else {
                            Box(
                                modifier = Modifier
                                    .size(110.dp)
                                    .scale(pulse)
                                    .clip(CircleShape)
                                    .background(NeonCyan.copy(alpha = 0.10f))
                                    .border(1.5.dp, NeonCyan.copy(alpha = 0.5f), CircleShape),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(
                                    Icons.Default.Fingerprint, null,
                                    tint = NeonCyan, modifier = Modifier.size(64.dp)
                                )
                            }
                            Spacer(Modifier.height(14.dp))
                            Text(
                                "TAP TO SCAN ($code)", color = NeonCyan, fontSize = 14.sp,
                                fontWeight = FontWeight.Black, letterSpacing = 1.sp
                            )
                            Spacer(Modifier.height(4.dp))
                            Text(
                                "Scan ${step.fingerName}",
                                color = Color.White.copy(alpha = 0.6f), fontSize = 11.sp
                            )
                        }
                    }
                }

                Spacer(Modifier.height(4.dp))
            }

            Box(modifier = Modifier.fillMaxWidth().padding(16.dp)) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp)
                        .clip(RoundedCornerShape(16.dp))
                        .background(Brush.horizontalGradient(listOf(IndigoAccent, SkyBlue, NeonCyan)))
                        .clickable { showScanner = true },
                    contentAlignment = Alignment.Center
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.CropFree, null, tint = Color.White, modifier = Modifier.size(20.dp))
                        Spacer(Modifier.width(8.dp))
                        Text(
                            if (capturedMap.containsKey(step)) "Re-Scan ${step.fingerName} ($code)" else "Scan ${step.fingerName} ($code)",
                            color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.ExtraBold
                        )
                    }
                }
            }
        }
    }

    if (showScanner) {
        Dialog(
            onDismissRequest = { if (!isProcessing) closeScanner() },
            properties = DialogProperties(
                usePlatformDefaultWidth = false,
                dismissOnClickOutside = false
            )
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth(0.94f)
                    .fillMaxHeight(0.88f)
                    .clip(RoundedCornerShape(26.dp))
                    .background(DarkNavy)
                    .border(1.dp, Color.White.copy(alpha = 0.18f), RoundedCornerShape(26.dp))
            ) {
                Column(modifier = Modifier.fillMaxSize()) {

                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(start = 16.dp, end = 6.dp, top = 6.dp, bottom = 6.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                "SCANNING $code", color = NeonCyan, fontSize = 10.sp,
                                fontWeight = FontWeight.Black, letterSpacing = 0.8.sp
                            )
                            Text(
                                step.fingerName, color = Color.White,
                                fontSize = 15.sp, fontWeight = FontWeight.ExtraBold
                            )
                        }
                        IconButton(onClick = { isTorchEnabled = !isTorchEnabled }) {
                            Icon(
                                if (isTorchEnabled) Icons.Default.FlashOn else Icons.Default.FlashOff,
                                "Torch",
                                tint = if (isTorchEnabled) Color(0xFFFDE047) else Color.White
                            )
                        }
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(16.dp))
                                .background(if (isAutoCaptureMode) NeonCyan else SkyBlue)
                                .clickable { isAutoCaptureMode = !isAutoCaptureMode }
                                .padding(horizontal = 10.dp, vertical = 5.dp)
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(
                                    if (isAutoCaptureMode) Icons.Default.AutoAwesome else Icons.Default.TouchApp,
                                    null,
                                    tint = if (isAutoCaptureMode) DarkNavy else Color.White,
                                    modifier = Modifier.size(12.dp)
                                )
                                Spacer(Modifier.width(4.dp))
                                Text(
                                    if (isAutoCaptureMode) "Auto" else "Manual",
                                    color = if (isAutoCaptureMode) DarkNavy else Color.White,
                                    fontSize = 11.sp, fontWeight = FontWeight.Bold
                                )
                            }
                        }
                        IconButton(onClick = { if (!isProcessing) closeScanner() }) {
                            Icon(Icons.Default.Close, "Close", tint = Color.White)
                        }
                    }

                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .fillMaxWidth()
                            .padding(horizontal = 12.dp)
                            .clip(RoundedCornerShape(20.dp))
                            .border(
                                2.dp,
                                if (isFocusCorrect) GreenSuccess else NeonCyan,
                                RoundedCornerShape(20.dp)
                            )
                            .background(Color.Black)
                    ) {
                        CameraPreview(
                            modifier = Modifier.fillMaxSize(),
                            isTorchEnabled = isTorchEnabled,
                            captureTrigger = captureTrigger,
                            onFocusStatusChanged = { isCorrect, offset ->
                                isFocusCorrect = isCorrect
                                detectedFingertipOffset = offset
                            },
                            onImageCaptured = { bitmap ->
                                captureTrigger = false
                                //todo new work
                                if (currentStepIndex == steps.lastIndex) isTorchEnabled = false
                                //todo new work
                                val bgHandler = onImageCaptured
                                if (bgHandler != null) {
                                    val capturedStep = step
                                    isProcessing = true
                                    scope.launch(fingertipCropDispatcher) {
                                        val crop = try {
                                            FingerprintProcessor.extractFingertipOnly(context, bitmap, capturedStep)
                                        } catch (e: Throwable) { null }
                                        launch(Dispatchers.Main) {
                                            isProcessing = false
                                            pendingCrop = PendingCrop(capturedStep, bitmap, crop ?: bitmap)
                                        }
                                    }
                                    return@CameraPreview
                                }
                                isProcessing = true
                                scope.launch(Dispatchers.Default) {
                                    val result = FingerprintProcessor.processAndEnhanceImage(context, bitmap, step)
                                    launch(Dispatchers.Main) {
                                        isProcessing = false
                                        pendingResultForConfirmation = result
                                    }
                                }
                            },
                            onError = {
                                captureTrigger = false
                                isProcessing = false
                            }
                        )

                        ScanningOverlay(
                            step = step,
                            detectedFingertipOffset = detectedFingertipOffset
                        )
                    }

                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(14.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier
                                .background(
                                    if (isFocusCorrect) NeonCyan else Color(0xFFFFD600),
                                    RoundedCornerShape(12.dp)
                                )
                                .padding(horizontal = 12.dp, vertical = 6.dp)
                        ) {
                            Icon(
                                Icons.Default.CenterFocusStrong, null,
                                tint = Color.Black, modifier = Modifier.size(16.dp)
                            )
                            Spacer(Modifier.width(6.dp))
                            Text(
                                text = when {
                                    isFocusCorrect && isAutoCaptureMode -> "Focus Locked - Capturing"
                                    isFocusCorrect -> "Focus Locked - Ready"
                                    detectedFingertipOffset != null -> "Aligning Fingertip"
                                    else -> "Place Finger Inside Guide"
                                },
                                color = Color.Black, fontWeight = FontWeight.Bold, fontSize = 12.sp
                            )
                        }

                        Spacer(Modifier.height(12.dp))

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceEvenly,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            IconButton(
                                onClick = onNextStepRequested,
                                modifier = Modifier
                                    .background(Color.DarkGray.copy(alpha = 0.7f), CircleShape)
                                    .size(46.dp)
                            ) {
                                Icon(
                                    Icons.Default.ArrowBackIosNew, "Skip",
                                    tint = Color.White, modifier = Modifier.size(18.dp)
                                )
                            }

                            Button(
                                onClick = {
                                    if (!isProcessing && pendingResultForConfirmation == null && pendingCrop == null) captureTrigger = true
                                },
                                shape = CircleShape,
                                colors = ButtonDefaults.buttonColors(containerColor = IndigoAccent),
                                modifier = Modifier.size(68.dp)
                            ) {
                                Icon(
                                    Icons.Default.Camera, "Capture",
                                    tint = Color.White, modifier = Modifier.size(32.dp)
                                )
                            }

                            ///todo for gallery
                            IconButton(
                                onClick = {
                                    galleryLauncher.launch("image/*")
                                },
                                modifier = Modifier
                                    .background(Color.DarkGray.copy(alpha = 0.7f), CircleShape)
                                    .size(46.dp)
                            ) {
                                Icon(
                                    Icons.Default.Image, "Gallery",
                                    tint = NeonCyan, modifier = Modifier.size(22.dp)
                                )
                            }

                            ///todo for gallery


                        }
                    }
                }

                AnimatedVisibility(
                    visible = isProcessing,
                    modifier = Modifier.fillMaxSize()
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .clip(RoundedCornerShape(26.dp))
                            .background(Color.Black.copy(alpha = 0.88f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            CircularProgressIndicator(color = NeonCyan, strokeWidth = 4.dp)
                            Spacer(Modifier.height(16.dp))
                        //    Text(if (onImageCaptured != null) "Extracting Fingertip..." else "Enhancing Fingertip Image...", color = Color.White, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                            Spacer(Modifier.height(4.dp))
                          //  Text("DAKSH AI Minutiae Ridge Thinning", color = Color.Gray, fontSize = 12.sp)
                        }
                    }
                }
            }
        }
    }

    val cropToReview = pendingCrop
    if (cropToReview != null) {
        Dialog(
            onDismissRequest = { pendingCrop = null },
            properties = DialogProperties(usePlatformDefaultWidth = false, dismissOnClickOutside = false)
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth(0.90f)
                    .clip(RoundedCornerShape(26.dp))
                    .background(DarkNavy)
                    .border(2.dp, NeonCyan, RoundedCornerShape(26.dp))
                    .padding(20.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        "CAPTURED FINGERTIP ($code)", color = NeonCyan, fontSize = 11.sp,
                        fontWeight = FontWeight.Black, letterSpacing = 0.8.sp
                    )
                    Text(
                        cropToReview.step.fingerName, color = Color.White,
                        fontSize = 16.sp, fontWeight = FontWeight.ExtraBold
                    )
                    Spacer(Modifier.height(14.dp))
                    val fingertipBitmap = cropToReview.crop

                    Image(
                        bitmap = fingertipBitmap.asImageBitmap(),
                        contentDescription = "Extracted fingertip",
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(18.dp))
                            .border(
                                2.dp,
                                GreenSuccess,
                                RoundedCornerShape(18.dp)
                            ),
                        contentScale = ContentScale.FillWidth
                    )
                   /* Box(
                        modifier = Modifier
                            .size(180.dp, 210.dp)
                            .clip(RoundedCornerShape(18.dp))
                            .border(2.dp, GreenSuccess, RoundedCornerShape(18.dp)),
                        contentAlignment = Alignment.Center
                    ) {
                      *//*  Image(
                            bitmap = cropToReview.crop.asImageBitmap(),
                            contentDescription = "Extracted fingertip",
                            modifier = Modifier.fillMaxWidth(),
                            contentScale = ContentScale.FillWidth
                        )*//*
                        Image(
                            bitmap = cropToReview.crop.asImageBitmap(),
                            contentDescription = "Extracted fingertip",
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(18.dp))
                                .border(
                                    2.dp,
                                    GreenSuccess,
                                    RoundedCornerShape(18.dp)
                                ),
                            contentScale = ContentScale.FillWidth
                        )
                    }*/
                    Spacer(Modifier.height(10.dp))
                    /*Text(
                        "Enhancement & analysis will run in background",
                        color = Color(0xFF94A3B8), fontSize = 11.sp
                    )*/
                    Spacer(Modifier.height(18.dp))
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        Button(
                            onClick = { pendingCrop = null },
                            modifier = Modifier.weight(1f).height(48.dp),
                            shape = RoundedCornerShape(14.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF991B1B))
                        ) { Text("Retake", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp) }

                       /* Button(
                            onClick = {
                                val accepted = cropToReview
                                pendingCrop = null
                                //closeScanner()
                                onImageCaptured?.invoke(accepted.step, accepted.raw, accepted.crop)
                            },
                            modifier = Modifier.weight(1f).height(48.dp),
                            shape = RoundedCornerShape(14.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF15803D))
                        ) {
                            Icon(Icons.Default.Check, "Accept", tint = Color.White, modifier = Modifier.size(18.dp))
                            Spacer(Modifier.width(6.dp))
                            Text("Accept", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                        }*/
                        // ✅ Keeps camera scanner open for Finger #2, #3, etc.
                        Button(
                            onClick = {
                                val accepted = cropToReview
                                pendingCrop = null
                                onImageCaptured?.invoke(accepted.step, accepted.raw, accepted.crop)

                                val allCaptured = steps.all { s -> capturedMap.containsKey(s) || s == accepted.step }
                                if (allCaptured) {
                                    closeScanner() // Closes only on finger #10
                                } else {
                                    showScanner = true // Keeps camera scanner open for next finger
                                    captureTrigger = false
                                    isProcessing = false
                                    isFocusCorrect = false
                                    detectedFingertipOffset = null
                                }
                            },
                            modifier = Modifier.weight(1f).height(48.dp),
                            shape = RoundedCornerShape(14.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF15803D))
                        ) {
                            Icon(Icons.Default.Check, "Accept", tint = Color.White, modifier = Modifier.size(18.dp))
                            Spacer(Modifier.width(6.dp))
                            Text("Accept", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                        }
                    }
                }
            }
        }
    }

    val reviewResult: EnhancedImageResult? = pendingResultForConfirmation
    if (reviewResult != null) {
        Dialog(
            onDismissRequest = { pendingResultForConfirmation = null },
            properties = DialogProperties(
                usePlatformDefaultWidth = false,
                dismissOnClickOutside = false
            )
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth(0.90f)
                    .clip(RoundedCornerShape(26.dp))
                    .background(DarkNavy)
                    .border(2.dp, NeonCyan, RoundedCornerShape(26.dp))
                    .padding(20.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        "REVIEW FINGERPRINT ($code)",
                        color = NeonCyan,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Black,
                        letterSpacing = 0.8.sp
                    )
                    Text(
                        step.fingerName,
                        color = Color.White,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.ExtraBold
                    )

                    Spacer(Modifier.height(14.dp))

                    Box(
                        modifier = Modifier
                            .size(160.dp, 190.dp)
                            .clip(RoundedCornerShape(18.dp))
                            .border(2.dp, GreenSuccess, RoundedCornerShape(18.dp)),
                        contentAlignment = Alignment.Center
                    ) {
                        Image(
                            bitmap = reviewResult.enhancedBitmap.asImageBitmap(),
                            contentDescription = "Captured Fingerprint",
                            modifier = Modifier.fillMaxSize(),
                            contentScale = ContentScale.Crop
                        )
                    }

                    Spacer(Modifier.height(12.dp))

                    Row(
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(10.dp))
                                .background(Color(0xFF1E1B4B))
                                .border(1.dp, IndigoAccent, RoundedCornerShape(10.dp))
                                .padding(horizontal = 8.dp, vertical = 4.dp)
                        ) {
                            Text(
                                "Pattern: ${reviewResult.predictedPattern}",
                                color = Color.White,
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(10.dp))
                                .background(Color(0xFF065F46))
                                .padding(horizontal = 8.dp, vertical = 4.dp)
                        ) {
                            Text(
                                "${reviewResult.ridgeCount}% ridgeCount",
                                color = Color(0xFF86EFAC),
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }

                    Spacer(Modifier.height(20.dp))

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        Button(
                            onClick = {
                                pendingResultForConfirmation = null
                            },
                            modifier = Modifier
                                .weight(1f)
                                .height(48.dp),
                            shape = RoundedCornerShape(14.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF991B1B))
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Default.Close, "Reject", tint = Color.White, modifier = Modifier.size(18.dp))
                                Spacer(Modifier.width(6.dp))
                                Text("Reject", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                            }
                        }

                        Button(
                            onClick = {
                                val resultToBind: EnhancedImageResult = reviewResult
                                pendingResultForConfirmation = null
                                localCaptured = localCaptured + (step to resultToBind.enhancedBitmap)
                                closeScanner()
                                onResultGenerated(resultToBind)
                            },
                            modifier = Modifier
                                .weight(1f)
                                .height(48.dp),
                            shape = RoundedCornerShape(14.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF15803D))
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Default.Check, "Accept", tint = Color.White, modifier = Modifier.size(18.dp))
                                Spacer(Modifier.width(6.dp))
                                Text("Accept", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                            }
                        }
                    }
                }
            }
        }
    }
}




private class PendingCrop(val step: ScanStep, val raw: Bitmap, val crop: Bitmap)

private fun getStepCodeAndMapping(step: ScanStep): Pair<String, String> {
    return when (step) {
        ScanStep.LEFT_THUMB_GROUP, ScanStep.LEFT_THUMB_IND ->
            Pair("L1", "Right Prefrontal (Leadership & Vision)")
        ScanStep.LEFT_INDEX_IND ->
            Pair("L2", "Right Frontal (Logic & Spatial Reasoning)")
        ScanStep.LEFT_MIDDLE_IND ->
            Pair("L3", "Right Parietal (Kinesthetic & Motor Skills)")
        ScanStep.LEFT_RING_IND ->
            Pair("L4", "Right Temporal (Auditory & Musical Perception)")
        ScanStep.LEFT_LITTLE_IND ->
            Pair("L5", "Right Occipital (Visual & Graphic Perception)")

        ScanStep.RIGHT_THUMB_GROUP, ScanStep.RIGHT_THUMB_IND ->
            Pair("R1", "Left Prefrontal (Management & Action Planning)")
        ScanStep.RIGHT_INDEX_IND ->
            Pair("R2", "Left Frontal (Linguistic & Language Analysis)")
        ScanStep.RIGHT_MIDDLE_IND ->
            Pair("R3", "Left Parietal (Fine Motor & Tactile Control)")
        ScanStep.RIGHT_RING_IND ->
            Pair("R4", "Left Temporal (Phonetic & Audio Processing)")
        ScanStep.RIGHT_LITTLE_IND ->
            Pair("R5", "Left Occipital (Visual Identification & Detail)")

        ScanStep.LEFT_FOUR_FINGERS_GROUP ->
            Pair("L2-L5", "Right Hemisphere Lobes (4-Fingers Cluster)")
        ScanStep.RIGHT_FOUR_FINGERS_GROUP ->
            Pair("R2-R5", "Left Hemisphere Lobes (4-Fingers Cluster)")
    }
}

private fun loadBitmapFromUri(context: android.content.Context, uri: Uri): Bitmap? {
    return try {
        val originalBitmap = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
            val source = ImageDecoder.createSource(context.contentResolver, uri)
            ImageDecoder.decodeBitmap(source) { decoder, _, _ ->
                decoder.allocator = ImageDecoder.ALLOCATOR_SOFTWARE
                decoder.isMutableRequired = true
            }
        } else {
            @Suppress("DEPRECATION")
            android.provider.MediaStore.Images.Media.getBitmap(context.contentResolver, uri)
        } ?: return null

        val softwareBitmap = if (originalBitmap.config != Bitmap.Config.ARGB_8888 || !originalBitmap.isMutable) {
            originalBitmap.copy(Bitmap.Config.ARGB_8888, true)
        } else {
            originalBitmap
        }

        val rotatedBitmap = try {
            context.contentResolver.openInputStream(uri)?.use { inputStream ->
                val exif = ExifInterface(inputStream)
                val orientation = exif.getAttributeInt(
                    ExifInterface.TAG_ORIENTATION,
                    ExifInterface.ORIENTATION_NORMAL
                )
                val rotationDegrees = when (orientation) {
                    ExifInterface.ORIENTATION_ROTATE_90 -> 90f
                    ExifInterface.ORIENTATION_ROTATE_180 -> 180f
                    ExifInterface.ORIENTATION_ROTATE_270 -> 270f
                    else -> 0f
                }
                if (rotationDegrees != 0f) {
                    val matrix = Matrix().apply { postRotate(rotationDegrees) }
                    Bitmap.createBitmap(softwareBitmap, 0, 0, softwareBitmap.width, softwareBitmap.height, matrix, true)
                } else {
                    softwareBitmap
                }
            } ?: softwareBitmap
        } catch (e: Throwable) {
            softwareBitmap
        }

        val maxDim = maxOf(rotatedBitmap.width, rotatedBitmap.height)
        val scaledBitmap = if (maxDim > 1920) {
            val scale = 1920f / maxDim
            val targetWidth = (rotatedBitmap.width * scale).toInt()
            val targetHeight = (rotatedBitmap.height * scale).toInt()
            Bitmap.createScaledBitmap(rotatedBitmap, targetWidth, targetHeight, true)
        } else {
            rotatedBitmap
        }

        com.daksh.daksh.ui.camera.enhanceImageClarity(scaledBitmap)
    } catch (e: Throwable) {
        e.printStackTrace()
        null
    }
}
