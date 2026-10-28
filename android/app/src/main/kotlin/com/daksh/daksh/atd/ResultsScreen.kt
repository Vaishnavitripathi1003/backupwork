package com.daksh.daksh.atd

import com.daksh.daksh.R
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Fingerprint
import androidx.compose.material.icons.filled.Lightbulb
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.util.Locale

@Composable
fun ResultsScreen(
    finalAngle: Float,
    leftAngle: Float,
    rightAngle: Float,
    onMeasureAgain: () -> Unit
) {
    val category = remember(finalAngle) { AtdMath.getCategory(finalAngle) }

    Scaffold(
        containerColor = Color(0xFFFBF8F5),
        bottomBar = {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                contentAlignment = Alignment.Center
            ) {
                Button(
                    onClick = onMeasureAgain,
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFE57373)),
                    shape = RoundedCornerShape(24.dp),
                    modifier = Modifier
                        .fillMaxWidth(0.6f)
                        .height(48.dp)
                ) {
                    Icon(Icons.Default.Refresh, contentDescription = null, modifier = Modifier.size(18.dp))
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Measure Again", fontWeight = FontWeight.Bold)
                }
            }
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp, vertical = 12.dp)
        ) {
            // Header Bar with DAKSH Logo, Back and Share
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = onMeasureAgain) {
                    Icon(Icons.Default.ArrowBack, contentDescription = "Back", tint = Color(0xFF212121))
                }

                Row(verticalAlignment = Alignment.CenterVertically) {
                    Image(
                        painter = painterResource(id = R.mipmap.ic_launcher_foreground),
                        contentDescription = "DAKSH Logo",
                        modifier = Modifier.size(28.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = "DAKSH ATD Results",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF212121)
                    )
                }

                IconButton(onClick = { /* Share result */ }) {
                    Icon(Icons.Default.Share, contentDescription = "Share", tint = Color(0xFFE57373))
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Card 1: Final ATD Angle Hero Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(24.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(24.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text("Final ATD Angle", fontSize = 13.sp, color = Color.Gray)
                        Text(
                            text = "${String.format(Locale.getDefault(), "%.1f", finalAngle)}°",
                            fontSize = 44.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = Color(0xFF1E88E5)
                        )
                        Text("Average of both palms", fontSize = 12.sp, color = Color.Gray)
                        Spacer(modifier = Modifier.height(8.dp))
                        Surface(
                            shape = RoundedCornerShape(12.dp),
                            color = Color(0xFFE3F2FD)
                        ) {
                            Text(
                                text = category.profileName,
                                color = Color(0xFF1976D2),
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                            )
                        }
                    }

                    Icon(
                        imageVector = Icons.Default.Fingerprint,
                        contentDescription = null,
                        tint = Color(0xFF80CBC4),
                        modifier = Modifier.size(64.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Card 2: Interpretation & Reference Scale
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
                            Text("Interpretation Profile", fontSize = 11.sp, color = Color.Gray)
                            Text(category.profileName, fontSize = 15.sp, fontWeight = FontWeight.Bold, color = Color(0xFF00897B))
                        }
                    }

                    Spacer(modifier = Modifier.height(12.dp))

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

                    Text("Reference Scale", fontSize = 11.sp, color = Color.Gray)
                    Spacer(modifier = Modifier.height(8.dp))

                    // Reference Scale Pills
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        ScalePill("< 35°\nAthlete", selected = category == InterpretationCategory.BORN_ATHLETE)
                        ScalePill("35-40°\nSmart", selected = category == InterpretationCategory.ACTIVELY_SMART)
                        ScalePill("41-45°\nNormal", selected = category == InterpretationCategory.NORMAL_BALANCED)
                        ScalePill("46-50°\nAverage", selected = category == InterpretationCategory.STEP_BY_STEP)
                        ScalePill("> 50°\nMethodical", selected = category == InterpretationCategory.METHODICAL)
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Card 3: ATD Analysis Chart
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(24.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
            ) {
                Column(modifier = Modifier.padding(20.dp)) {
                    Text("Bilateral Hand Comparison", fontWeight = FontWeight.Bold, fontSize = 16.sp)

                    Spacer(modifier = Modifier.height(24.dp))

                    // Visual Bar Chart for Left, Right, Final
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(140.dp),
                        horizontalArrangement = Arrangement.SpaceEvenly,
                        verticalAlignment = Alignment.Bottom
                    ) {
                        BarColumn(label = "Left Palm", value = leftAngle, color = Color(0xFFEF5350))
                        BarColumn(label = "Right Palm", value = rightAngle, color = Color(0xFF26A69A))
                        BarColumn(label = "Final Average", value = finalAngle, color = Color(0xFF42A5F5))
                    }

                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        text = "Final: ${String.format(Locale.getDefault(), "%.1f", finalAngle)}°",
                        fontSize = 12.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = Color.Gray,
                        modifier = Modifier.align(Alignment.CenterHorizontally)
                    )
                }
            }

            Spacer(modifier = Modifier.height(80.dp))
        }
    }
}

@Composable
fun RowScope.ScalePill(label: String, selected: Boolean) {
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
fun BarColumn(label: String, value: Float, color: Color) {
    val maxVal = 65f
    val barHeight = ((value / maxVal) * 110).coerceIn(10f, 120f)

    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text("${String.format(Locale.getDefault(), "%.1f", value)}°", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = color)
        Spacer(modifier = Modifier.height(4.dp))
        Box(
            modifier = Modifier
                .width(36.dp)
                .height(barHeight.dp)
                .clip(RoundedCornerShape(topStart = 8.dp, topEnd = 8.dp))
                .background(color)
        )
        Spacer(modifier = Modifier.height(6.dp))
        Text(label, fontSize = 12.sp, color = Color.Gray)
    }
}
