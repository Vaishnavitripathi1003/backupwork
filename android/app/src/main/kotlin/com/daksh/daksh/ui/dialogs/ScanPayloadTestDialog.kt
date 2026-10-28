package com.daksh.daksh.ui.dialogs

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.clickable
import androidx.compose.foundation.lazy.grid.GridItemSpan
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.text.font.FontFamily
import com.daksh.daksh.network.DirectFingerUploader
import com.google.gson.GsonBuilder
import java.io.File
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.BugReport
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.CloudUpload
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.daksh.daksh.model.EnhancedImageResult
import com.daksh.daksh.model.ScanStep

private val DarkNavy = Color(0xFF0B132B)
private val NeonCyan = Color(0xFF00E5FF)
private val GreenSuccess = Color(0xFF22C55E)
private val IndigoAccent = Color(0xFF4F46E5)


@Composable
fun ScanPayloadTestDialog(
    userDataId: String,
    token: String,
    scannedMap: Map<ScanStep, EnhancedImageResult>,
    onConfirmSend: () -> Unit,
    onDismiss: () -> Unit
) {
    val resultsList = remember(scannedMap) { scannedMap.values.sortedBy { it.step.ordinal } }
    var zoomed by remember { mutableStateOf<EnhancedImageResult?>(null) }

    // Exactly what goes to the server, in the order it is sent
    val metadataJson = remember(scannedMap) {
        GsonBuilder().setPrettyPrinting().create()
            .toJson(DirectFingerUploader.buildScan1Request(scannedMap))
    }
    val imageLines = remember(scannedMap) {
        resultsList.map { r ->
            val f = File(r.enhancedPath.ifEmpty { r.rawPath })
            "${r.step.fingerName}: ${f.name} (${f.length() / 1024} KB)"
        }
    }

    zoomed?.let { ZoomedFingerprint(it) { zoomed = null } }

    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(
            usePlatformDefaultWidth = false,
            dismissOnClickOutside = false
        )
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth(0.95f)
                .fillMaxHeight(0.90f)
                .clip(RoundedCornerShape(26.dp))
                .background(DarkNavy)
                .border(2.dp, NeonCyan, RoundedCornerShape(26.dp))
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp)
            ) {
                // Header Row
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            Icons.Default.BugReport,
                            contentDescription = "Test Payload",
                            tint = NeonCyan,
                            modifier = Modifier.size(24.dp)
                        )
                        Spacer(Modifier.width(8.dp))
                        Column {
                            Text(
                                "PRE-UPLOAD TESTING PAYLOAD",
                                color = NeonCyan,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Black,
                                letterSpacing = 0.8.sp
                            )
                            Text(
                                "Review Images & Ridge Data",
                                color = Color.White,
                                fontSize = 15.sp,
                                fontWeight = FontWeight.ExtraBold
                            )
                        }
                    }
                    IconButton(onClick = onDismiss) {
                        Icon(Icons.Default.Close, "Close", tint = Color.White)
                    }
                }

                Spacer(Modifier.height(10.dp))

                // Metadata Details Bar
                Surface(
                    color = Color(0xFF1E293B),
                    shape = RoundedCornerShape(14.dp),
                  //  border = BorderStroke(1.dp, Color.White.copy(alpha = 0.12f)),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(modifier = Modifier.padding(10.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(
                                "userData_id: $userDataId",
                                color = Color.White,
                                fontSize = 11.5.sp,
                                fontWeight = FontWeight.Bold
                            )
                            Text(
                                "Total: ${resultsList.size} Scans",
                                color = GreenSuccess,
                                fontSize = 11.5.sp,
                                fontWeight = FontWeight.Black
                            )
                        }
                        Spacer(Modifier.height(4.dp))
                     /*   Text(
                            "Auth Token: ${if (token.isNotEmpty()) "Present (Bearer ...)" else "Missing"}",
                            color = Color(0xFF94A3B8),
                            fontSize = 10.5.sp
                        )*/
                    }
                }

                Spacer(Modifier.height(12.dp))

                // 2-Column Grid of Fingerprint Cards
                LazyVerticalGrid(
                    columns = GridCells.Fixed(2),
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp),
                    modifier = Modifier.weight(1f)
                ) {
                    items(resultsList) { result ->
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(16.dp))
                                .background(Color(0xFF16213E))
                                .border(1.dp, Color.White.copy(alpha = 0.15f), RoundedCornerShape(16.dp))
                                .padding(8.dp)
                        ) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                // Step Header Pill
                                Box(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .clip(RoundedCornerShape(8.dp))
                                        .background(IndigoAccent)
                                        .padding(vertical = 3.dp),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        result.step.fingerName,
                                        color = Color.White,
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Bold
                                    )
                                }

                                Spacer(Modifier.height(8.dp))

                                // Fingerprint Image Thumbnail
                                Box(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .aspectRatio(0.85f)
                                        .clip(RoundedCornerShape(10.dp))
                                        .border(1.dp, GreenSuccess, RoundedCornerShape(10.dp))
                                        .clickable { zoomed = result },
                                    contentAlignment = Alignment.Center
                                ) {
                                    Image(
                                        bitmap = result.enhancedBitmap.asImageBitmap(),
                                        contentDescription = result.step.fingerName,
                                        modifier = Modifier.fillMaxSize(),
                                        contentScale = ContentScale.Crop
                                    )
                                }

                                Spacer(Modifier.height(6.dp))

                                // Pattern & Code
                                Text(
                                    "Pattern: ${result.predictedPattern}",
                                    color = Color.White,
                                    fontSize = 10.sp,
                                    fontWeight = FontWeight.Bold,
                                    maxLines = 1
                                )
                                Text(
                                    "Code: '${result.patternCode}' | Ridges: ${result.ridgeCount}",
                                    color = NeonCyan,
                                    fontSize = 9.5.sp,
                                    fontWeight = FontWeight.Black
                                )
                                Text(
                                    "Clarity: ${result.clarityScore}% HD",
                                    color = GreenSuccess,
                                    fontSize = 9.sp
                                )
                            }
                        }
                    }
                    // ── Data being sent, in order ──
                    item(span = { GridItemSpan(maxLineSpan) }) {
                        PayloadSection(
                            title = "STEP 1  -  Metadata  (POST fingerprintscan1)",
                            body = metadataJson
                        )
                    }
                    item(span = { GridItemSpan(maxLineSpan) }) {
                        PayloadSection(
                            title = "STEP 2  -  Images  (PATCH fingerprintscanImage)",
                            body = imageLines.joinToString("\n")
                        )
                    }
                }

                Spacer(Modifier.height(14.dp))

                // Action Buttons
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Button(
                        onClick = onDismiss,
                        modifier = Modifier
                            .weight(1f)
                            .height(48.dp),
                        shape = RoundedCornerShape(14.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF475569))
                    ) {
                        Text("Cancel", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                    }

                    Button(
                        onClick = onConfirmSend,
                        modifier = Modifier
                            .weight(1f)
                            .height(48.dp),
                        shape = RoundedCornerShape(14.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF15803D))
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Default.CloudUpload, "Send", tint = Color.White, modifier = Modifier.size(18.dp))
                            Spacer(Modifier.width(6.dp))
                            Text("Send to Server", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                        }
                    }
                }
            }
        }
    }
}


@Composable
private fun PayloadSection(title: String, body: String) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(Color(0xFF0F172A))
            .border(1.dp, NeonCyan.copy(alpha = 0.4f), RoundedCornerShape(12.dp))
            .padding(10.dp)
    ) {
        Text(title, color = NeonCyan, fontSize = 11.sp, fontWeight = FontWeight.Black)
        Spacer(Modifier.height(6.dp))
        Text(body, color = Color(0xFFE2E8F0), fontSize = 10.sp, fontFamily = FontFamily.Monospace)
    }
}

@Composable
private fun ZoomedFingerprint(result: EnhancedImageResult, onClose: () -> Unit) {
    Dialog(
        onDismissRequest = onClose,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth(0.95f)
                .clip(RoundedCornerShape(20.dp))
                .background(DarkNavy)
                .border(2.dp, NeonCyan, RoundedCornerShape(20.dp))
                .clickable { onClose() }
                .padding(14.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(result.step.fingerName, color = Color.White, fontSize = 16.sp, fontWeight = FontWeight.ExtraBold)
            Spacer(Modifier.height(8.dp))
            Image(
                bitmap = result.enhancedBitmap.asImageBitmap(),
                contentDescription = result.step.fingerName,
                modifier = Modifier.fillMaxWidth(),
                contentScale = ContentScale.Fit
            )
            Spacer(Modifier.height(8.dp))
            Text(
                "Pattern: ${result.predictedPattern}  |  Code: '${result.patternCode}'  |  Ridges: ${result.ridgeCount}",
                color = NeonCyan, fontSize = 11.sp, fontWeight = FontWeight.Bold
            )
            Text(
                "Clarity: ${result.clarityScore}%  |  ${result.resolutionText}",
                color = GreenSuccess, fontSize = 11.sp
            )
            Text("Tap to close", color = Color(0xFF94A3B8), fontSize = 10.sp)
        }
    }
}
