package com.daksh.daksh.ui.screens

import android.graphics.Bitmap
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
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.CropFree
import androidx.compose.material.icons.filled.Fingerprint
import androidx.compose.material.icons.filled.Memory
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.daksh.daksh.model.ScanStep

// ── Step code + brain mapping ──
internal fun getGroupStepCodeAndMapping(step: ScanStep): Pair<String, String> {
    return when (step) {
        ScanStep.LEFT_THUMB_GROUP, ScanStep.LEFT_THUMB_IND ->
            Pair("L1", "Left Thumb (Leadership & Vision)")
        ScanStep.LEFT_FOUR_FINGERS_GROUP ->
            Pair("L2-L5", "Left Hand 4 Fingers (Logic, Motor, Auditory, Visual)")
        ScanStep.RIGHT_THUMB_GROUP, ScanStep.RIGHT_THUMB_IND ->
            Pair("R1", "Right Thumb (Management & Action)")
        ScanStep.RIGHT_FOUR_FINGERS_GROUP ->
            Pair("R2-R5", "Right Hand 4 Fingers (Language, Tactile, Audio, Detail)")
        else ->
            Pair("G1", "Group Fingerprints Cluster")
    }
}

// ── APP BAR ──
@Composable
internal fun GroupTopBar(onCloseClicked: () -> Unit) {
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
                "GROUP MODE SCANNER", color = GroupGreen, fontSize = 10.sp,
                fontWeight = FontWeight.Black, letterSpacing = 0.8.sp
            )
            Text(
                "4-Fingers Cluster & Thumbs", color = Color.White,
                fontSize = 16.sp, fontWeight = FontWeight.ExtraBold
            )
        }
        Spacer(Modifier.size(48.dp))
    }
}

// ── PROGRESS CARD ──
@Composable
internal fun GroupProgressCard(capturedCount: Int, totalCount: Int) {
    Surface(
        color = GroupCardNavy.copy(alpha = 0.85f),
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
                    "$capturedCount of $totalCount Group Steps Scanned",
                    color = Color.White, fontSize = 13.sp, fontWeight = FontWeight.Bold
                )
                Text(
                    "${(capturedCount * 100 / totalCount)}%",
                    color = GroupGreen, fontSize = 13.sp, fontWeight = FontWeight.Black
                )
            }
            Spacer(Modifier.height(10.dp))
            val progressVal = (capturedCount.toFloat() / totalCount.toFloat()).coerceIn(0f, 1f)
            LinearProgressIndicator(
                progress = { progressVal },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(8.dp)
                    .clip(RoundedCornerShape(6.dp)),
                color = GroupGreen,
                trackColor = Color.White.copy(alpha = 0.1f)
            )
        }
    }
}

// ── STEP PILLS (L1, L2-L5, R1, R2-R5) ──
@Composable
internal fun GroupStepPills(
    steps: List<ScanStep>,
    currentStepIndex: Int,
    capturedMap: Map<ScanStep, Bitmap>,
    onStepSelected: (Int) -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        steps.forEachIndexed { idx, s ->
            val isSelected = idx == currentStepIndex
            val captured = capturedMap[s] != null
            val sCode = getGroupStepCodeAndMapping(s).first

            Box(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(14.dp))
                    .background(if (isSelected) GroupGreenDark else Color.White.copy(alpha = 0.08f))
                    .border(
                        width = if (isSelected) 1.8.dp else if (captured) 1.5.dp else 1.dp,
                        color = if (isSelected || captured) GroupGreen else Color.Transparent,
                        shape = RoundedCornerShape(14.dp)
                    )
                    .clickable { onStepSelected(idx) }
                    .padding(vertical = 10.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        sCode,
                        color = if (isSelected) Color.White else if (captured) GroupGreen else Color.White.copy(alpha = 0.7f),
                        fontSize = 12.sp, fontWeight = FontWeight.Black
                    )
                    Spacer(Modifier.height(4.dp))
                    if (captured) {
                        Icon(
                            Icons.Default.CheckCircle, null,
                            tint = GroupGreen, modifier = Modifier.size(14.dp)
                        )
                    } else {
                        Box(
                            Modifier
                                .size(6.dp)
                                .background(
                                    if (isSelected) GroupGreen else Color.White.copy(alpha = 0.3f),
                                    CircleShape
                                )
                        )
                    }
                }
            }
        }
    }
}

// ── ACTIVE STEP CARD ──
@Composable
internal fun GroupActiveStepCard(
    step: ScanStep,
    code: String,
    brainMapping: String,
    capturedBitmap: Bitmap?
) {
    Surface(
        color = GroupCardNavy.copy(alpha = 0.85f),
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
                            .background(GroupGreenDark)
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

                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(12.dp))
                        .background(if (capturedBitmap != null) GroupGreenDark else Color(0xFF1E1B4B))
                        .border(1.dp, if (capturedBitmap != null) GroupGreen else GroupIndigo, RoundedCornerShape(12.dp))
                        .padding(horizontal = 10.dp, vertical = 4.dp)
                ) {
                    Text(
                        text = if (capturedBitmap != null) "✓ Scanned" else "Ready to Scan",
                        color = if (capturedBitmap != null) Color(0xFF86EFAC) else Color(0xFFC7D2FE),
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
                    Icon(Icons.Default.Memory, null, tint = GroupGreen, modifier = Modifier.size(14.dp))
                    Spacer(Modifier.width(6.dp))
                    Text("Maps to: $brainMapping", color = Color(0xFF94A3B8), fontSize = 11.sp)
                }

                if (capturedBitmap != null) {
                    Spacer(Modifier.width(8.dp))
                    Image(
                        bitmap = capturedBitmap.asImageBitmap(),
                        contentDescription = "Active Fingerprint",
                        modifier = Modifier
                            .size(36.dp)
                            .clip(RoundedCornerShape(8.dp))
                            .border(1.dp, GroupGreen, RoundedCornerShape(8.dp)),
                        contentScale = ContentScale.Crop
                    )
                }
            }
        }
    }
}

// ── TAP TO SCAN CARD ──
@Composable
internal fun GroupTapToScanCard(
    step: ScanStep,
    code: String,
    capturedBitmap: Bitmap?,
    onClick: () -> Unit
) {
    val pulseTransition = rememberInfiniteTransition(label = "groupPulse")
    val pulse by pulseTransition.animateFloat(
        initialValue = 0.94f,
        targetValue = 1.06f,
        animationSpec = infiniteRepeatable(tween(1200), RepeatMode.Reverse),
        label = "groupPulseScale"
    )

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(28.dp))
            .background(Brush.verticalGradient(listOf(Color(0xFF064E3B), Color(0xFF022C22))))
            .border(
                width = 2.dp,
                color = if (capturedBitmap != null) GroupGreen else Color(0xFF34D399),
                shape = RoundedCornerShape(28.dp)
            )
            .clickable(onClick = onClick)
            .padding(vertical = 24.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            if (capturedBitmap != null) {
                Box(
                    modifier = Modifier
                        .size(110.dp)
                        .clip(CircleShape)
                        .border(2.dp, GroupGreen, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Image(
                        bitmap = capturedBitmap.asImageBitmap(),
                        contentDescription = "Scanned $code",
                        modifier = Modifier.fillMaxSize(),
                        contentScale = ContentScale.Crop
                    )
                }
                Spacer(Modifier.height(12.dp))
                Text(
                    "✓ $code CAPTURED CLEARLY",
                    color = GroupGreen, fontSize = 13.sp,
                    fontWeight = FontWeight.Black, letterSpacing = 0.8.sp
                )
                Spacer(Modifier.height(4.dp))
                Text(
                    "Tap to re-scan if needed",
                    color = Color.White.copy(alpha = 0.6f), fontSize = 11.sp
                )
            } else {
                Box(
                    modifier = Modifier
                        .size(110.dp)
                        .scale(pulse)
                        .clip(CircleShape)
                        .background(GroupGreen.copy(alpha = 0.15f))
                        .border(1.5.dp, GroupGreen.copy(alpha = 0.6f), CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        Icons.Default.Fingerprint, null,
                        tint = GroupGreen, modifier = Modifier.size(64.dp)
                    )
                }
                Spacer(Modifier.height(14.dp))
                Text(
                    "TAP TO SCAN ($code)", color = GroupGreen, fontSize = 14.sp,
                    fontWeight = FontWeight.Black, letterSpacing = 1.sp
                )
                Spacer(Modifier.height(4.dp))
                Text(
                    "Camera popup me ${step.fingerName} scan karein",
                    color = Color.White.copy(alpha = 0.6f), fontSize = 11.sp
                )
            }
        }
    }
}

// ── BOTTOM BUTTON ──
@Composable
internal fun GroupBottomScanButton(label: String, onClick: () -> Unit) {
    Box(modifier = Modifier.fillMaxWidth().padding(16.dp)) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(52.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(Brush.horizontalGradient(listOf(GroupGreenDark, Color(0xFF047857), Color(0xFF065F46))))
                .clickable(onClick = onClick),
            contentAlignment = Alignment.Center
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.CropFree, null, tint = Color.White, modifier = Modifier.size(20.dp))
                Spacer(Modifier.width(8.dp))
                Text(label, color = Color.White, fontSize = 14.sp, fontWeight = FontWeight.ExtraBold)
            }
        }
    }
}
