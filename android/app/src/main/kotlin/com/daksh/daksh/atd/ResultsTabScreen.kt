package com.daksh.daksh.atd

import android.graphics.Bitmap
import android.widget.Toast
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DeleteSweep
import androidx.compose.material.icons.filled.Fingerprint
import androidx.compose.material.icons.filled.History
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
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.util.Locale

@Composable
fun ResultsTabScreen(
    currentFinalAngle: Float?,
    currentLeftAngle: Float?,
    currentRightAngle: Float?,
    leftHandBitmap: Bitmap? = null,
    rightHandBitmap: Bitmap? = null,
    profileRepo: UserProfileRepository,
    onMeasureAgain: () -> Unit
) {
    val context = LocalContext.current
    var selectedSubTab by remember { mutableIntStateOf(0) } // 0 = Latest Analysis, 1 = Scan History Log

    var historyList by remember { mutableStateOf(profileRepo.getScanHistory()) }

    val effectiveFinalAngle = currentFinalAngle ?: historyList.firstOrNull()?.finalAngle ?: 40.1f
    val effectiveLeftAngle = currentLeftAngle ?: historyList.firstOrNull()?.leftAngle ?: 38.8f
    val effectiveRightAngle = currentRightAngle ?: historyList.firstOrNull()?.rightAngle ?: 41.4f

    val category = remember(effectiveFinalAngle) { AtdMath.getCategory(effectiveFinalAngle) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFFFBF8F5))
            .verticalScroll(rememberScrollState())
            .padding(bottom = 90.dp)
    ) {
        // Top DAKSH Header
        DakshLogoHeader()

        Column(modifier = Modifier.padding(horizontal = 20.dp, vertical = 16.dp)) {

            // Header Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "ATD Results & History",
                        fontSize = 22.sp,
                        fontWeight = FontWeight.ExtraBold,
                        color = Color(0xFF1A1A1A)
                    )
                    Text(
                        text = "Dermatoglyphic analysis & past measurements",
                        fontSize = 12.sp,
                        color = Color.Gray
                    )
                }

                Button(
                    onClick = onMeasureAgain,
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFE57373)),
                    shape = RoundedCornerShape(16.dp),
                    contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp)
                ) {
                    Icon(Icons.Default.Refresh, contentDescription = null, modifier = Modifier.size(16.dp))
                    Spacer(modifier = Modifier.width(4.dp))
                    Text("New Scan", fontSize = 12.sp, fontWeight = FontWeight.Bold)
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Sub Tab Switcher: Latest vs History
            TabRow(
                selectedTabIndex = selectedSubTab,
                containerColor = Color.White,
                contentColor = Color(0xFFE57373),
                modifier = Modifier.clip(RoundedCornerShape(16.dp))
            ) {
                Tab(
                    selected = selectedSubTab == 0,
                    onClick = { selectedSubTab = 0 },
                    text = { Text("Latest Analysis", fontWeight = FontWeight.Bold, fontSize = 13.sp) }
                )
                Tab(
                    selected = selectedSubTab == 1,
                    onClick = { selectedSubTab = 1 },
                    text = { Text("History Logs (${historyList.size})", fontWeight = FontWeight.Bold, fontSize = 13.sp) }
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            if (selectedSubTab == 0) {
                // LATEST ANALYSIS VIEW

                // Hero Card: ATD Angle
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(24.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White),
                    elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(22.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text("Calculated ATD Angle", fontSize = 12.sp, color = Color.Gray)
                            Text(
                                text = "${String.format(Locale.getDefault(), "%.1f", effectiveFinalAngle)}°",
                                fontSize = 42.sp,
                                fontWeight = FontWeight.ExtraBold,
                                color = Color(0xFF1E88E5)
                            )
                            Text("Bilateral palm average", fontSize = 11.sp, color = Color.Gray)
                            Spacer(modifier = Modifier.height(8.dp))
                            Surface(
                                shape = RoundedCornerShape(12.dp),
                                color = Color(0xFFE3F2FD)
                            ) {
                                Text(
                                    text = category.profileName,
                                    color = Color(0xFF1976D2),
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold,
                                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                                )
                            }
                        }

                        Icon(
                            imageVector = Icons.Default.Fingerprint,
                            contentDescription = null,
                            tint = Color(0xFF80CBC4),
                            modifier = Modifier.size(60.dp)
                        )
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Bar Chart Breakdown Card
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(24.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White),
                    elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                ) {
                    Column(modifier = Modifier.padding(20.dp)) {
                        Text("Bilateral Hand Comparison", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                        Spacer(modifier = Modifier.height(20.dp))

                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(130.dp),
                            horizontalArrangement = Arrangement.SpaceEvenly,
                            verticalAlignment = Alignment.Bottom
                        ) {
                            BarColumnItem(label = "Left Palm", value = effectiveLeftAngle, color = Color(0xFFEF5350))
                            BarColumnItem(label = "Right Palm", value = effectiveRightAngle, color = Color(0xFF26A69A))
                            BarColumnItem(label = "Final Average", value = effectiveFinalAngle, color = Color(0xFF42A5F5))
                        }
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Interpretation & Scale Reference based on user combination
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(24.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White),
                    elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                ) {
                    Column(modifier = Modifier.padding(20.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Box(
                                modifier = Modifier
                                    .size(32.dp)
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(Color(0xFFE0F2F1)),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(Icons.Default.Lightbulb, contentDescription = null, tint = Color(0xFF00897B), modifier = Modifier.size(18.dp))
                            }
                            Spacer(modifier = Modifier.width(10.dp))
                            Column {
                                Text("Interpretation Guide", fontSize = 11.sp, color = Color.Gray)
                                Text(category.profileName, fontSize = 15.sp, fontWeight = FontWeight.Bold, color = Color(0xFF00897B))
                            }
                        }

                        Spacer(modifier = Modifier.height(10.dp))

                        Text(
                            text = category.description,
                            fontSize = 13.sp,
                            color = Color(0xFF616161),
                            lineHeight = 18.sp
                        )

                        HorizontalDivider(modifier = Modifier.padding(vertical = 12.dp), color = Color(0xFFEEEEEE))

                        // Cognitive & Physical Traits
                        Text("🧠 Cognitive & Processing Trait", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1E88E5))
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(text = category.cognitiveTrait, fontSize = 12.sp, color = Color(0xFF424242), lineHeight = 16.sp)

                        Spacer(modifier = Modifier.height(10.dp))

                        Text("⚡ Physical & Reflex Response", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color(0xFF2E7D32))
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(text = category.physicalTrait, fontSize = 12.sp, color = Color(0xFF424242), lineHeight = 16.sp)

                        Spacer(modifier = Modifier.height(10.dp))

                        Text("💡 Learning Recommendations", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color(0xFFE65100))
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(text = category.learningRecommendations, fontSize = 12.sp, color = Color(0xFF424242), lineHeight = 16.sp)

                        Spacer(modifier = Modifier.height(10.dp))

                        Text("🌟 Key Strengths", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color(0xFF6A1B9A))
                        Spacer(modifier = Modifier.height(4.dp))
                        category.strengths.forEach { strength ->
                            Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(vertical = 2.dp)) {
                                Text("✓ ", color = Color(0xFF2E7D32), fontWeight = FontWeight.Bold, fontSize = 12.sp)
                                Text(strength, fontSize = 12.sp, color = Color(0xFF424242))
                            }
                        }

                        Spacer(modifier = Modifier.height(16.dp))

                        Text("Dermatoglyphic Reference Scale", fontSize = 11.sp, color = Color.Gray)
                        Spacer(modifier = Modifier.height(8.dp))

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            ReferenceScalePill("< 35°\nAthlete", selected = category == InterpretationCategory.BORN_ATHLETE)
                            ReferenceScalePill("35-40°\nSmart", selected = category == InterpretationCategory.ACTIVELY_SMART)
                            ReferenceScalePill("41-45°\nNormal", selected = category == InterpretationCategory.NORMAL_BALANCED)
                            ReferenceScalePill("46-50°\nAverage", selected = category == InterpretationCategory.STEP_BY_STEP)
                            ReferenceScalePill("> 50°\nMethodical", selected = category == InterpretationCategory.METHODICAL)
                        }
                    }
                }
            } else {
                // HISTORY LOGS VIEW
                if (historyList.isEmpty()) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(40.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Icon(
                                Icons.Default.History,
                                contentDescription = null,
                                tint = Color.LightGray,
                                modifier = Modifier.size(54.dp)
                            )
                            Spacer(modifier = Modifier.height(12.dp))
                            Text("No Past Scan Records", fontWeight = FontWeight.Bold, color = Color.Gray)
                            Text("Perform a palm scan to save ATD results", fontSize = 12.sp, color = Color.LightGray)
                        }
                    }
                } else {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text("Past Measurement Logs", fontWeight = FontWeight.Bold, fontSize = 14.sp)

                        TextButton(
                            onClick = {
                                profileRepo.clearScanHistory()
                                historyList = emptyList()
                                Toast.makeText(context, "Scan history cleared", Toast.LENGTH_SHORT).show()
                            }
                        ) {
                            Icon(Icons.Default.DeleteSweep, contentDescription = null, tint = Color(0xFFD32F2F), modifier = Modifier.size(16.dp))
                            Spacer(modifier = Modifier.width(4.dp))
                            Text("Clear History", color = Color(0xFFD32F2F), fontSize = 12.sp)
                        }
                    }

                    Spacer(modifier = Modifier.height(8.dp))

                    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        historyList.forEach { record ->
                            ScanHistoryItemCard(record = record)
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun ScanHistoryItemCard(record: ScanHistoryRecord) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(record.timestamp, fontSize = 11.sp, color = Color.Gray)
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "${String.format(Locale.getDefault(), "%.1f", record.finalAngle)}° ATD",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.ExtraBold,
                    color = Color(0xFF1E88E5)
                )
                Text(
                    text = "L: ${String.format(Locale.getDefault(), "%.1f", record.leftAngle)}°  •  R: ${String.format(Locale.getDefault(), "%.1f", record.rightAngle)}°",
                    fontSize = 11.sp,
                    color = Color(0xFF616161)
                )
            }

            Surface(
                shape = RoundedCornerShape(10.dp),
                color = Color(0xFFE8F5E9)
            ) {
                Text(
                    text = record.categoryLabel,
                    color = Color(0xFF2E7D32),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                )
            }
        }
    }
}

@Composable
fun RowScope.ReferenceScalePill(label: String, selected: Boolean) {
    Box(
        modifier = Modifier
            .weight(1f)
            .clip(RoundedCornerShape(8.dp))
            .background(if (selected) Color(0xFF1E88E5) else Color(0xFFF0F2F5))
            .padding(vertical = 6.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = label,
            fontSize = 9.sp,
            color = if (selected) Color.White else Color(0xFF9E9E9E),
            fontWeight = if (selected) FontWeight.Bold else FontWeight.Normal,
            lineHeight = 11.sp,
            textAlign = TextAlign.Center
        )
    }
}

@Composable
fun BarColumnItem(label: String, value: Float, color: Color) {
    val maxVal = 65f
    val barHeight = ((value / maxVal) * 100).coerceIn(10f, 110f)

    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text("${String.format(Locale.getDefault(), "%.1f", value)}°", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = color)
        Spacer(modifier = Modifier.height(4.dp))
        Box(
            modifier = Modifier
                .width(34.dp)
                .height(barHeight.dp)
                .clip(RoundedCornerShape(topStart = 8.dp, topEnd = 8.dp))
                .background(color)
        )
        Spacer(modifier = Modifier.height(6.dp))
        Text(label, fontSize = 11.sp, color = Color.Gray)
    }
}
