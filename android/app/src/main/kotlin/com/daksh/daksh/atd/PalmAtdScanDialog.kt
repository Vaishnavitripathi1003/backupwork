/*
package com.daksh.daksh.atd

import android.graphics.Bitmap
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Fingerprint
import androidx.compose.material.icons.filled.Lightbulb
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.daksh.daksh.R
import java.util.Locale

@Composable
fun PalmAtdScanDialog(
    hasCameraPermission: Boolean,
    onRequestPermission: () -> Unit,
    onFrameAvailable: (Bitmap) -> Unit,
    currentAngle: Float,
    detectedHandLabel: String?,
    positionStatus: PalmPositionStatus,
    isHandPresent: Boolean,
    leftAngle: Float?,
    rightAngle: Float?,
    finalCalculatedAngle: Float?,
    currentWrist: Point2D?,
    currentIndexA: Point2D?,
    currentPinkyD: Point2D?,
    leftHandBitmap: Bitmap?,
    rightHandBitmap: Bitmap?,
    onCaptureLeft: () -> Unit,
    onCaptureRight: () -> Unit,
    onCalculateFinal: () -> Unit,
    onReset: () -> Unit,
    onDismiss: () -> Unit
) {
    var showResultView by remember { mutableStateOf(false) }

    // Auto-switch to result view when final calculation completes
    LaunchedEffect(finalCalculatedAngle) {
        if (finalCalculatedAngle != null && finalCalculatedAngle > 0f) {
            showResultView = true
        }
    }

    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(
            usePlatformDefaultWidth = false,
            dismissOnClickOutside = false
        )
    ) {
        Surface(
            modifier = Modifier
                .fillMaxWidth(0.95f)
                .fillMaxHeight(0.92f)
                .clip(RoundedCornerShape(24.dp)),
            color = Color(0xFFF8FAFC),
            border = BorderStroke(1.dp, Color(0xFFE2E8F0)),
            shadowElevation = 12.dp
        ) {
            Column(modifier = Modifier.fillMaxSize()) {

                // Popup Header Bar
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(Color.White)
                        .padding(horizontal = 16.dp, vertical = 12.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Image(
                            painter = painterResource(id = R.mipmap.ic_launcher_foreground),
                            contentDescription = "DAKSH Logo",
                            modifier = Modifier.size(32.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Column {
                            Text(
                                text = "DAKSH • PalmATD Scanner",
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Bold,
                                color = Color(0xFF4F46E5)
                            )
                            Text(
                                text = if (showResultView) "ATD Analysis Report" else "Scan Left & Right Palm",
                                fontSize = 16.sp,
                                fontWeight = FontWeight.ExtraBold,
                                color = Color(0xFF0F172A)
                            )
                        }
                    }

                    IconButton(onClick = onDismiss, modifier = Modifier.size(32.dp)) {
                        Icon(Icons.Default.Close, contentDescription = "Close", tint = Color(0xFF64748B))
                    }
                }

                HorizontalDivider(color = Color(0xFFE2E8F0), thickness = 1.dp)

                // Popup Body Content
                Box(modifier = Modifier.weight(1f)) {
                    if (!showResultView) {
                        // SCANNING VIEW INSIDE POPUP
                        PalmWorkflowScreen(
                            hasCameraPermission = hasCameraPermission,
                            onRequestPermission = onRequestPermission,
                            onFrameAvailable = onFrameAvailable,
                            currentAngle = currentAngle,
                            detectedHandLabel = detectedHandLabel,
                            positionStatus = positionStatus,
                            isHandPresent = isHandPresent,
                            leftAngle = leftAngle,
                            rightAngle = rightAngle,
                            currentWrist = currentWrist,
                            currentIndexA = currentIndexA,
                            currentPinkyD = currentPinkyD,
                            onCaptureLeft = onCaptureLeft,
                            onCaptureRight = onCaptureRight,
                            onCalculateFinal = {
                                onCalculateFinal()
                                showResultView = true
                            },
                            onReset = onReset
                        )
                    } else {
                        // REPORT RESULT VIEW INSIDE POPUP
                        val effectiveFinalAngle = finalCalculatedAngle ?: 40.1f
                        val effectiveLeftAngle = leftAngle ?: 38.8f
                        val effectiveRightAngle = rightAngle ?: 41.4f
                        val category = remember(effectiveFinalAngle) { AtdMath.getCategory(effectiveFinalAngle) }

                        Column(
                            modifier = Modifier
                                .fillMaxSize()
                                .verticalScroll(rememberScrollState())
                                .padding(16.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            // Hero Card: Calculated ATD Angle
                            Card(
                                modifier = Modifier.fillMaxWidth(),
                                shape = RoundedCornerShape(24.dp),
                                colors = CardDefaults.cardColors(containerColor = Color.White),
                                border = BorderStroke(1.dp, Color(0xFFE2E8F0)),
                                elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                            ) {
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(20.dp),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Column {
                                        Text("Calculated ATD Angle", fontSize = 12.sp, color = Color(0xFF64748B))
                                        Text(
                                            text = "${String.format(Locale.getDefault(), "%.1f", effectiveFinalAngle)}°",
                                            fontSize = 42.sp,
                                            fontWeight = FontWeight.Black,
                                            color = Color(0xFF4F46E5)
                                        )
                                        Text("Bilateral palm average", fontSize = 11.sp, color = Color(0xFF64748B))
                                        Spacer(modifier = Modifier.height(8.dp))
                                        Surface(
                                            shape = RoundedCornerShape(12.dp),
                                            color = Color(0xFFEEF2FF)
                                        ) {
                                            Text(
                                                text = category.profileName,
                                                color = Color(0xFF4F46E5),
                                                fontSize = 12.sp,
                                                fontWeight = FontWeight.Bold,
                                                modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                                            )
                                        }
                                    }

                                    Icon(
                                        imageVector = Icons.Default.Fingerprint,
                                        contentDescription = null,
                                        tint = Color(0xFF06B6D4),
                                        modifier = Modifier.size(56.dp)
                                    )
                                }
                            }

                            Spacer(modifier = Modifier.height(14.dp))

                            // Bar Chart Breakdown Card
                            Card(
                                modifier = Modifier.fillMaxWidth(),
                                shape = RoundedCornerShape(20.dp),
                                colors = CardDefaults.cardColors(containerColor = Color.White),
                                border = BorderStroke(1.dp, Color(0xFFE2E8F0)),
                                elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                            ) {
                                Column(modifier = Modifier.padding(18.dp)) {
                                    Text("Bilateral Hand Comparison", fontWeight = FontWeight.Bold, fontSize = 15.sp, color = Color(0xFF0F172A))
                                    Spacer(modifier = Modifier.height(18.dp))

                                    Row(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .height(120.dp),
                                        horizontalArrangement = Arrangement.SpaceEvenly,
                                        verticalAlignment = Alignment.Bottom
                                    ) {
                                        AtdBarColumnItem(label = "Left Palm", value = effectiveLeftAngle, color = Color(0xFF4F46E5))
                                        AtdBarColumnItem(label = "Right Palm", value = effectiveRightAngle, color = Color(0xFF7C3AED))
                                        AtdBarColumnItem(label = "Final Avg", value = effectiveFinalAngle, color = Color(0xFF10B981))
                                    }
                                }
                            }

                            Spacer(modifier = Modifier.height(14.dp))

                            // Captured Palm Images with Overlay
                            if (leftHandBitmap != null || rightHandBitmap != null) {
                                Text(
                                    text = "Captured Palms with ATD Points (T, A, D)",
                                    fontSize = 13.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = Color(0xFF0F172A),
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(bottom = 8.dp)
                                )

                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                                ) {
                                    leftHandBitmap?.let { bmp ->
                                        Column(
                                            modifier = Modifier.weight(1f),
                                            horizontalAlignment = Alignment.CenterHorizontally
                                        ) {
                                            Image(
                                                bitmap = bmp.asImageBitmap(),
                                                contentDescription = "Left Palm Overlay",
                                                modifier = Modifier
                                                    .fillMaxWidth()
                                                    .height(140.dp)
                                                    .clip(RoundedCornerShape(14.dp))
                                                    .border(1.dp, Color(0xFFE2E8F0), RoundedCornerShape(14.dp)),
                                                contentScale = ContentScale.Crop
                                            )
                                            Spacer(modifier = Modifier.height(4.dp))
                                            Text("Left Palm", fontSize = 11.sp, fontWeight = FontWeight.SemiBold, color = Color(0xFF4F46E5))
                                        }
                                    }

                                    rightHandBitmap?.let { bmp ->
                                        Column(
                                            modifier = Modifier.weight(1f),
                                            horizontalAlignment = Alignment.CenterHorizontally
                                        ) {
                                            Image(
                                                bitmap = bmp.asImageBitmap(),
                                                contentDescription = "Right Palm Overlay",
                                                modifier = Modifier
                                                    .fillMaxWidth()
                                                    .height(140.dp)
                                                    .clip(RoundedCornerShape(14.dp))
                                                    .border(1.dp, Color(0xFFE2E8F0), RoundedCornerShape(14.dp)),
                                                contentScale = ContentScale.Crop
                                            )
                                            Spacer(modifier = Modifier.height(4.dp))
                                            Text("Right Palm", fontSize = 11.sp, fontWeight = FontWeight.SemiBold, color = Color(0xFF7C3AED))
                                        }
                                    }
                                }

                                Spacer(modifier = Modifier.height(14.dp))
                            }

                            // Interpretation & Scale Reference Card
                            Card(
                                modifier = Modifier.fillMaxWidth(),
                                shape = RoundedCornerShape(20.dp),
                                colors = CardDefaults.cardColors(containerColor = Color.White),
                                border = BorderStroke(1.dp, Color(0xFFE2E8F0)),
                                elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                            ) {
                                Column(modifier = Modifier.padding(18.dp)) {
                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        Box(
                                            modifier = Modifier
                                                .size(32.dp)
                                                .clip(RoundedCornerShape(8.dp))
                                                .background(Color(0xFFEEF2FF)),
                                            contentAlignment = Alignment.Center
                                        ) {
                                            Icon(Icons.Default.Lightbulb, contentDescription = null, tint = Color(0xFF4F46E5), modifier = Modifier.size(18.dp))
                                        }
                                        Spacer(modifier = Modifier.width(10.dp))
                                        Column {
                                            Text("Interpretation Guide", fontSize = 11.sp, color = Color(0xFF64748B))
                                            Text(category.profileName, fontSize = 15.sp, fontWeight = FontWeight.Bold, color = Color(0xFF4F46E5))
                                        }
                                    }

                                    Spacer(modifier = Modifier.height(10.dp))

                                    Text(
                                        text = category.description,
                                        fontSize = 12.sp,
                                        color = Color(0xFF334155),
                                        lineHeight = 17.sp
                                    )

                                    HorizontalDivider(modifier = Modifier.padding(vertical = 12.dp), color = Color(0xFFE2E8F0))

                                    // Cognitive & Physical Traits
                                    Text("🧠 Cognitive & Processing Trait", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color(0xFF4F46E5))
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(text = category.cognitiveTrait, fontSize = 12.sp, color = Color(0xFF334155), lineHeight = 16.sp)

                                    Spacer(modifier = Modifier.height(10.dp))

                                    Text("⚡ Physical & Reflex Response", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color(0xFF06B6D4))
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(text = category.physicalTrait, fontSize = 12.sp, color = Color(0xFF334155), lineHeight = 16.sp)

                                    Spacer(modifier = Modifier.height(10.dp))

                                    Text("💡 Learning Recommendations", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color(0xFF10B981))
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(text = category.learningRecommendations, fontSize = 12.sp, color = Color(0xFF334155), lineHeight = 16.sp)

                                    Spacer(modifier = Modifier.height(10.dp))

                                    Text("🌟 Key Strengths", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color(0xFF7C3AED))
                                    Spacer(modifier = Modifier.height(4.dp))
                                    category.strengths.forEach { strength ->
                                        Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(vertical = 2.dp)) {
                                            Text("✓ ", color = Color(0xFF10B981), fontWeight = FontWeight.Bold, fontSize = 12.sp)
                                            Text(strength, fontSize = 12.sp, color = Color(0xFF334155))
                                        }
                                    }

                                    Spacer(modifier = Modifier.height(16.dp))

                                    Text("Dermatoglyphic Reference Scale", fontSize = 11.sp, color = Color(0xFF64748B))
                                    Spacer(modifier = Modifier.height(8.dp))

                                    Row(
                                        modifier = Modifier.fillMaxWidth(),
                                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                                    ) {
                                        AtdScalePill("< 35°\nAthlete", selected = category == InterpretationCategory.BORN_ATHLETE)
                                        AtdScalePill("35-40°\nSmart", selected = category == InterpretationCategory.ACTIVELY_SMART)
                                        AtdScalePill("41-45°\nNormal", selected = category == InterpretationCategory.NORMAL_BALANCED)
                                        AtdScalePill("46-50°\nAverage", selected = category == InterpretationCategory.STEP_BY_STEP)
                                        AtdScalePill("> 50°\nMethodical", selected = category == InterpretationCategory.METHODICAL)
                                    }
                                }
                            }

                            Spacer(modifier = Modifier.height(20.dp))

                            // Bottom Popup Action Buttons
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.spacedBy(10.dp)
                            ) {
                                OutlinedButton(
                                    onClick = {
                                        onReset()
                                        showResultView = false
                                    },
                                    modifier = Modifier
                                        .weight(1f)
                                        .height(48.dp),
                                    shape = RoundedCornerShape(14.dp),
                                    border = BorderStroke(1.5.dp, Color(0xFF4F46E5))
                                ) {
                                    Icon(Icons.Default.Refresh, contentDescription = null, tint = Color(0xFF4F46E5), modifier = Modifier.size(18.dp))
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text("Re-Scan", color = Color(0xFF4F46E5), fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                }

                                Button(
                                    onClick = onDismiss,
                                    modifier = Modifier
                                        .weight(1f)
                                        .height(48.dp),
                                    shape = RoundedCornerShape(14.dp),
                                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF4F46E5))
                                ) {
                                    Icon(Icons.Default.Check, contentDescription = null, tint = Color.White, modifier = Modifier.size(18.dp))
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text("Done", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun RowScope.AtdScalePill(label: String, selected: Boolean) {
    Box(
        modifier = Modifier
            .weight(1f)
            .clip(RoundedCornerShape(8.dp))
            .background(if (selected) Color(0xFF4F46E5) else Color(0xFFF1F5F9))
            .padding(vertical = 6.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = label,
            fontSize = 9.sp,
            color = if (selected) Color.White else Color(0xFF64748B),
            fontWeight = if (selected) FontWeight.Bold else FontWeight.Normal,
            lineHeight = 11.sp,
            textAlign = TextAlign.Center
        )
    }
}

@Composable
private fun AtdBarColumnItem(label: String, value: Float, color: Color) {
    val maxVal = 65f
    val barHeight = ((value / maxVal) * 100).coerceIn(10f, 100f)

    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text("${String.format(Locale.getDefault(), "%.1f", value)}°", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = color)
        Spacer(modifier = Modifier.height(4.dp))
        Box(
            modifier = Modifier
                .width(32.dp)
                .height(barHeight.dp)
                .clip(RoundedCornerShape(topStart = 8.dp, topEnd = 8.dp))
                .background(color)
        )
        Spacer(modifier = Modifier.height(6.dp))
        Text(label, fontSize = 11.sp, color = Color(0xFF64748B))
    }
}
*/
package com.daksh.daksh.atd

import android.graphics.Bitmap
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.daksh.daksh.R
import java.util.Locale

@Composable
fun PalmAtdScanDialog(
    hasCameraPermission: Boolean,
    onRequestPermission: () -> Unit,
    onFrameAvailable: (Bitmap) -> Unit,
    currentAngle: Float,
    detectedHandLabel: String?,
    positionStatus: PalmPositionStatus,
    isHandPresent: Boolean,
    leftAngle: Float?,
    rightAngle: Float?,
    finalCalculatedAngle: Float?,
    currentWrist: Point2D?,
    currentIndexA: Point2D?,
    currentPinkyD: Point2D?,
    leftHandBitmap: Bitmap?,
    rightHandBitmap: Bitmap?,
    isUploading: Boolean,
    onCaptureLeft: () -> Unit,
    onCaptureRight: () -> Unit,
    onCalculateFinal: () -> Unit,
    onSubmit: () -> Unit,
    onReset: () -> Unit,
    onDismiss: () -> Unit
) {
    // Submit is visible as soon as BOTH palms are captured
    val bothPalmsCaptured = leftAngle != null && rightAngle != null

    Dialog(
        onDismissRequest = { if (!isUploading) onDismiss() },
        properties = DialogProperties(
            usePlatformDefaultWidth = false,
            dismissOnClickOutside = false
        )
    ) {
        Surface(
            modifier = Modifier
                .fillMaxWidth(0.95f)
                .fillMaxHeight(0.92f)
                .clip(RoundedCornerShape(24.dp)),
            color = Color(0xFFF8FAFC),
            border = BorderStroke(1.dp, Color(0xFFE2E8F0)),
            shadowElevation = 12.dp
        ) {
            Column(modifier = Modifier.fillMaxSize()) {

                // Popup Header Bar
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(Color.White)
                        .padding(horizontal = 16.dp, vertical = 12.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Image(
                            painter = painterResource(id = R.mipmap.ic_launcher_foreground),
                            contentDescription = "DAKSH Logo",
                            modifier = Modifier.size(32.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Column {
                            Text(
                                text = "DAKSH • PalmATD Scanner",
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Bold,
                                color = Color(0xFF4F46E5)
                            )
                            Text(
                                text = "Scan Left & Right Palm",
                                fontSize = 16.sp,
                                fontWeight = FontWeight.ExtraBold,
                                color = Color(0xFF0F172A)
                            )
                        }
                    }

                    IconButton(
                        onClick = onDismiss,
                        enabled = !isUploading,
                        modifier = Modifier.size(32.dp)
                    ) {
                        Icon(Icons.Default.Close, contentDescription = "Close", tint = Color(0xFF64748B))
                    }
                }

                HorizontalDivider(color = Color(0xFFE2E8F0), thickness = 1.dp)

                // Popup Body Content
                Column(modifier = Modifier.weight(1f)) {

                    // Scanning screen
                    Box(modifier = Modifier.weight(1f)) {
                        PalmWorkflowScreen(
                            hasCameraPermission = hasCameraPermission,
                            onRequestPermission = onRequestPermission,
                            onFrameAvailable = onFrameAvailable,
                            currentAngle = currentAngle,
                            detectedHandLabel = detectedHandLabel,
                            positionStatus = positionStatus,
                            isHandPresent = isHandPresent,
                            leftAngle = leftAngle,
                            rightAngle = rightAngle,
                            currentWrist = currentWrist,
                            currentIndexA = currentIndexA,
                            currentPinkyD = currentPinkyD,
                            onCaptureLeft = onCaptureLeft,
                            onCaptureRight = onCaptureRight,
                            onCalculateFinal = onCalculateFinal,
                            onReset = onReset
                        )
                    }

                    // Submit bar: visible right after both palms are captured
                    if (bothPalmsCaptured) {
                        HorizontalDivider(color = Color(0xFFE2E8F0), thickness = 1.dp)
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .background(Color.White)
                                .padding(16.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            val avg = (((leftAngle ?: 0f) + (rightAngle ?: 0f)) / 2f * 10f).toInt() / 10f
                            Text(
                                text = "Left: ${String.format(Locale.getDefault(), "%.1f", leftAngle)}°   " +
                                        "Right: ${String.format(Locale.getDefault(), "%.1f", rightAngle)}°   " +
                                        "Avg: ${String.format(Locale.getDefault(), "%.1f", avg)}°",
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Bold,
                                color = Color(0xFF4F46E5)
                            )
                            Spacer(modifier = Modifier.height(10.dp))
                            Button(
                                onClick = onSubmit,
                                enabled = !isUploading,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(48.dp),
                                shape = RoundedCornerShape(14.dp),
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = Color(0xFF10B981),
                                    disabledContainerColor = Color(0xFF94A3B8)
                                )
                            ) {
                                if (isUploading) {
                                    CircularProgressIndicator(
                                        modifier = Modifier.size(18.dp),
                                        color = Color.White,
                                        strokeWidth = 2.dp
                                    )
                                    Spacer(modifier = Modifier.width(8.dp))
                                    Text("Uploading...", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                } else {
                                    Icon(Icons.Default.Check, contentDescription = null, tint = Color.White, modifier = Modifier.size(18.dp))
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text("Submit", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}