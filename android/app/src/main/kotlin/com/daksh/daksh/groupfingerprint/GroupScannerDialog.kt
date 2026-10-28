package com.daksh.daksh.ui.screens

import android.graphics.Bitmap
import androidx.compose.animation.AnimatedVisibility
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
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBackIosNew
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Camera
import androidx.compose.material.icons.filled.CenterFocusStrong
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.FlashOff
import androidx.compose.material.icons.filled.FlashOn
import androidx.compose.material.icons.filled.TouchApp
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.daksh.daksh.model.ScanStep
import com.daksh.daksh.ui.camera.GroupCameraPreview
import com.daksh.daksh.ui.camera.GroupScanningOverlay

/** Camera popup for the group scanner (uses GroupCameraPreview + GroupScanningOverlay). */
@Composable
internal fun GroupScannerDialog(
    step: ScanStep,
    code: String,
    isTorchEnabled: Boolean,
    isAutoCaptureMode: Boolean,
    isFocusCorrect: Boolean,
    isProcessing: Boolean,
    captureTrigger: Boolean,
    detectedFingertipOffset: Offset?,
    onTorchToggle: () -> Unit,
    onAutoModeToggle: () -> Unit,
    onFocusStatusChanged: (Boolean, Offset?) -> Unit,
    onImageCaptured: (Bitmap) -> Unit,
    onCameraError: () -> Unit,
    onCaptureClick: () -> Unit,
    onSkipClick: () -> Unit,
    onDismiss: () -> Unit
) {
    Dialog(
        onDismissRequest = { if (!isProcessing) onDismiss() },
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
                .background(GroupDarkNavy)
                .border(1.dp, Color.White.copy(alpha = 0.18f), RoundedCornerShape(26.dp))
        ) {
            Column(modifier = Modifier.fillMaxSize()) {

                // Header
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(start = 16.dp, end = 6.dp, top = 6.dp, bottom = 6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            "GROUP SCANNING $code", color = GroupGreen, fontSize = 10.sp,
                            fontWeight = FontWeight.Black, letterSpacing = 0.8.sp
                        )
                        Text(
                            step.fingerName, color = Color.White,
                            fontSize = 15.sp, fontWeight = FontWeight.ExtraBold
                        )
                    }
                    IconButton(onClick = onTorchToggle) {
                        Icon(
                            if (isTorchEnabled) Icons.Default.FlashOn else Icons.Default.FlashOff,
                            "Torch",
                            tint = if (isTorchEnabled) Color(0xFFFDE047) else Color.White
                        )
                    }
                    // Auto / Manual toggle (same as the single-finger popup)
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(16.dp))
                            .background(if (isAutoCaptureMode) GroupGreen else GroupSkyBlue)
                            .clickable(onClick = onAutoModeToggle)
                            .padding(horizontal = 10.dp, vertical = 5.dp)
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                if (isAutoCaptureMode) Icons.Default.AutoAwesome else Icons.Default.TouchApp,
                                null,
                                tint = if (isAutoCaptureMode) GroupDarkNavy else Color.White,
                                modifier = Modifier.size(12.dp)
                            )
                            Spacer(Modifier.width(4.dp))
                            Text(
                                if (isAutoCaptureMode) "Auto" else "Manual",
                                color = if (isAutoCaptureMode) GroupDarkNavy else Color.White,
                                fontSize = 11.sp, fontWeight = FontWeight.Bold
                            )
                        }
                    }
                    IconButton(onClick = { if (!isProcessing) onDismiss() }) {
                        Icon(Icons.Default.Close, "Close", tint = Color.White)
                    }
                }

                // Camera area
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxWidth()
                        .padding(horizontal = 12.dp)
                        .clip(RoundedCornerShape(20.dp))
                        .border(
                            2.dp,
                            if (isFocusCorrect) GroupGreen else GroupNeonCyan,
                            RoundedCornerShape(20.dp)
                        )
                        .background(Color.Black)
                ) {
                    GroupCameraPreview(
                        modifier = Modifier.fillMaxSize(),
                        isTorchEnabled = isTorchEnabled,
                        captureTrigger = captureTrigger,
                        onFocusStatusChanged = onFocusStatusChanged,
                        onImageCaptured = onImageCaptured,
                        onError = { onCameraError() }
                    )

                    GroupScanningOverlay(
                        step = step,
                        detectedFingertipOffset = detectedFingertipOffset
                    )
                }

                // Bottom controls
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
                                if (isFocusCorrect) GroupGreen else Color(0xFFFFD600),
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
                                detectedFingertipOffset != null -> "Aligning Finger Cluster"
                                else -> "Place Fingers Inside Guide"
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
                            onClick = onSkipClick,
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
                            onClick = onCaptureClick,
                            shape = CircleShape,
                            colors = ButtonDefaults.buttonColors(containerColor = GroupGreenDark),
                            modifier = Modifier.size(68.dp)
                        ) {
                            Icon(
                                Icons.Default.Camera, "Capture",
                                tint = Color.White, modifier = Modifier.size(32.dp)
                            )
                        }
                    }
                }
            }

            // Processing overlay
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
                        CircularProgressIndicator(color = GroupGreen, strokeWidth = 4.dp)
                        Spacer(Modifier.height(16.dp))
                        Text("Enhancing Group Fingerprints...", color = Color.White, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                        Spacer(Modifier.height(4.dp))
                        Text("DAKSH AI Minutiae Ridge Extraction", color = Color.Gray, fontSize = 12.sp)
                    }
                }
            }
        }
    }
}
