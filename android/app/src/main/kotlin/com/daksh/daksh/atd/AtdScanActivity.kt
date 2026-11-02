package com.daksh.daksh.atd

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.core.content.ContextCompat
import androidx.lifecycle.lifecycleScope
import com.daksh.daksh.network.DirectFingerUploader
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class AtdScanActivity : ComponentActivity() {

    private var hasCameraPermission by mutableStateOf(false)
    private var userToken: String = ""
    private var userDataId: String = ""

    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        hasCameraPermission = isGranted
        if (!isGranted) {
            Toast.makeText(this, "Camera permission is required to detect ATD angle", Toast.LENGTH_LONG).show()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        userToken = intent.getStringExtra("USER_TOKEN") ?: ""
        userDataId = intent.getStringExtra("USER_DATA_ID") ?: ""
        Log.i("PalmScan", "AtdScanActivity initialized -> USER_DATA_ID: '$userDataId', USER_TOKEN length: ${userToken.length}")

        // Initial camera permission check
        hasCameraPermission = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.CAMERA
        ) == PackageManager.PERMISSION_GRANTED

        if (!hasCameraPermission) {
            requestPermissionLauncher.launch(Manifest.permission.CAMERA)
        }

        val appStatusManager = AppStatusManager(this)

        setContent {
            MaterialTheme {
                val coroutineScope = rememberCoroutineScope()

                var appStatus by remember { mutableStateOf(appStatusManager.statusState.value) }

                var currentLiveAngle by remember { mutableFloatStateOf(0.0f) }
                var detectedHandLabel by remember { mutableStateOf<String?>(null) }
                var positionStatus by remember { mutableStateOf(PalmPositionStatus.PERFECT) }
                var isHandPresent by remember { mutableStateOf(false) }
                var leftHandAngle by remember { mutableStateOf<Float?>(null) }
                var rightHandAngle by remember { mutableStateOf<Float?>(null) }
                var finalCalculatedAngle by remember { mutableStateOf<Float?>(null) }

                // Upload state (true while Submit is uploading)
                var isUploading by remember { mutableStateOf(false) }

                // Frame and landmarks for drawing ATD points overlay on captured hands
                var latestFrameBitmap by remember { mutableStateOf<Bitmap?>(null) }
                var currentWrist by remember { mutableStateOf<Point2D?>(null) }
                var currentIndexA by remember { mutableStateOf<Point2D?>(null) }
                var currentPinkyD by remember { mutableStateOf<Point2D?>(null) }

                var leftHandBitmap by remember { mutableStateOf<Bitmap?>(null) }
                var rightHandBitmap by remember { mutableStateOf<Bitmap?>(null) }

                // HandTracker integration with strict palm validation & auto positioning
                val handTracker = remember {
                    HandTracker(
                        context = this@AtdScanActivity,
                        onHandDetected = { angle, label, posStatus, wrist, indexA, pinkyD ->
                            Log.i("PalmScan", "ON_HAND_DETECTED -> Angle: $angle°, Hand: $label, Status: $posStatus, Wrist: (${wrist.x}, ${wrist.y}), IndexA: (${indexA.x}, ${indexA.y}), PinkyD: (${pinkyD.x}, ${pinkyD.y})")
                            currentLiveAngle = angle
                            detectedHandLabel = label
                            positionStatus = posStatus
                            isHandPresent = true
                            currentWrist = wrist
                            currentIndexA = indexA
                            currentPinkyD = pinkyD
                        },
                        onNoHandDetected = {
                            if (isHandPresent) {
                                Log.d("PalmScan", "ON_NO_HAND_DETECTED -> Palm moved out of frame or invalid angle")
                            }
                            isHandPresent = false
                            currentLiveAngle = 0.0f
                            detectedHandLabel = null
                        },
                        onError = {
                            err ->
                            Log.e("PalmScan", "HAND_TRACKER_ERROR -> $err")
                        }
                    )
                }

                DisposableEffect(Unit) {
                    onDispose {
                        handTracker.close()
                    }
                }

                // Perform async APK discontinue check on startup
                LaunchedEffect(Unit) {
                    val updatedStatus = appStatusManager.checkAppStatus(currentVersionCode = 2)
                    appStatus = updatedStatus
                }

                // If remote API or local flag indicates APK is discontinued, present DiscontinuedScreen
                if (appStatus.isDiscontinued) {
                    DiscontinuedScreen(
                        statusInfo = appStatus,
                        onRetryCheck = {
                            coroutineScope.launch {
                                val status = appStatusManager.checkAppStatus(currentVersionCode = 2)
                                appStatus = status
                            }
                        },
                        onResetTestState = {
                            appStatusManager.setTestDiscontinuedState(false)
                            appStatus = appStatusManager.statusState.value
                            Toast.makeText(this@AtdScanActivity, "App reactivated!", Toast.LENGTH_SHORT).show()
                        }
                    )
                } else {
                    // Render ONLY the Popup Dialog (No Bottom Navigation Bar)
                    Surface(
                        modifier = Modifier.fillMaxSize(),
                        color = Color(0x99000000) // Translucent backdrop overlay
                    ) {
                        PalmAtdScanDialog(
                            hasCameraPermission = hasCameraPermission,
                            onRequestPermission = {
                                requestPermissionLauncher.launch(Manifest.permission.CAMERA)
                            },
                            onFrameAvailable = { bitmap ->
                                latestFrameBitmap = bitmap
                                handTracker.detectLiveFrame(bitmap)
                            },
                            currentAngle = currentLiveAngle,
                            detectedHandLabel = detectedHandLabel,
                            positionStatus = positionStatus,
                            isHandPresent = isHandPresent,
                            leftAngle = leftHandAngle,
                            rightAngle = rightHandAngle,
                            finalCalculatedAngle = finalCalculatedAngle,
                            currentWrist = currentWrist,
                            currentIndexA = currentIndexA,
                            currentPinkyD = currentPinkyD,
                            leftHandBitmap = leftHandBitmap,
                            rightHandBitmap = rightHandBitmap,
                            isUploading = isUploading,
                            onCaptureLeft = {
                                if (!isHandPresent || currentLiveAngle <= 0f) {
                                    Log.w("PalmScan", "Capture Left ignored -> Hand not present or invalid angle ($currentLiveAngle°)")
                                    return@PalmAtdScanDialog
                                }
                                leftHandAngle = currentLiveAngle
                                Log.i("PalmScan", "LEFT PALM CAPTURED -> Angle: $currentLiveAngle°, Hand: $detectedHandLabel")

                                val frame = latestFrameBitmap
                                val w = currentWrist
                                val a = currentIndexA
                                val d = currentPinkyD
                                if (frame != null && w != null && a != null && d != null) {
                                    leftHandBitmap = AtdImageUtils.drawAtdOverlay(
                                        sourceBitmap = frame,
                                        wrist = w,
                                        indexA = a,
                                        pinkyD = d,
                                        angle = currentLiveAngle,
                                        handLabel = "Left Palm"
                                    )
                                    Log.i("PalmScan", "Left Palm Overlay generated cleanly")
                                }

                                Toast.makeText(this@AtdScanActivity, "Left hand captured! Now show your right palm.", Toast.LENGTH_SHORT).show()
                            },
                            onCaptureRight = {
                                if (!isHandPresent || currentLiveAngle <= 0f) {
                                    Log.w("PalmScan", "Capture Right ignored -> Hand not present or invalid angle ($currentLiveAngle°)")
                                    return@PalmAtdScanDialog
                                }
                                rightHandAngle = currentLiveAngle
                                Log.i("PalmScan", "RIGHT PALM CAPTURED -> Angle: $currentLiveAngle°, Hand: $detectedHandLabel")

                                val frame = latestFrameBitmap
                                val w = currentWrist
                                val a = currentIndexA
                                val d = currentPinkyD
                                if (frame != null && w != null && a != null && d != null) {
                                    rightHandBitmap = AtdImageUtils.drawAtdOverlay(
                                        sourceBitmap = frame,
                                        wrist = w,
                                        indexA = a,
                                        pinkyD = d,
                                        angle = currentLiveAngle,
                                        handLabel = "Right Palm"
                                    )
                                    Log.i("PalmScan", "Right Palm Overlay generated cleanly")
                                }
                            },
                            onCalculateFinal = {
                                // Only calculates. NO upload here.
                                val left = leftHandAngle ?: currentLiveAngle
                                val right = rightHandAngle ?: currentLiveAngle
                                val avg = ((left + right) / 2f * 10f).toInt() / 10f
                                finalCalculatedAngle = avg
                                Log.i("PalmScanResult", "Left: $left°, Right: $right°, Avg: $avg°")
                            },
                            onSubmit = {
                                val left = leftHandAngle
                                val right = rightHandAngle
                                if (left == null || right == null) {
                                    Toast.makeText(this@AtdScanActivity, "Capture both palms first", Toast.LENGTH_SHORT).show()
                                    return@PalmAtdScanDialog
                                }
                                if (isUploading) return@PalmAtdScanDialog

                                val avg = ((left + right) / 2f * 10f).toInt() / 10f
                                finalCalculatedAngle = avg
                                isUploading = true

                                lifecycleScope.launch {
                                    try {
                                        val result = withContext(Dispatchers.IO) {
                                            DirectFingerUploader.uploadAtdOnly(
                                                token = userToken,
                                                userDataId = userDataId,
                                                atdLeft = left.toDouble(),
                                                atdRight = right.toDouble(),
                                                atdAvg = avg.toDouble(),
                                                isAtdReportGenerated = true
                                            )
                                        }
                                        Log.d("PalmScanResult", "uploadAtdOnly result: $result")
                                        Toast.makeText(this@AtdScanActivity, "Submitted successfully", Toast.LENGTH_SHORT).show()

                                        val resultIntent = Intent().apply {
                                            putExtra("STATUSATD", "SUCCESS")
                                            putExtra("FINAL_ATD_ANGLE", avg)
                                            putExtra("LEFT_ATD_ANGLE", left)
                                            putExtra("RIGHT_ATD_ANGLE", right)
                                            putExtra("USER_TOKEN", userToken)
                                            putExtra("USER_DATA_ID", userDataId)
                                        }
                                        setResult(Activity.RESULT_OK, resultIntent)
                                        finish()
                                    } catch (e: Exception) {
                                        Log.e("PalmScanResult", "uploadAtdOnly failed: ${e.message}", e)
                                        isUploading = false
                                        Toast.makeText(this@AtdScanActivity, "Upload failed, try again", Toast.LENGTH_SHORT).show()
                                    }
                                }
                            },
                            onReset = {
                                leftHandAngle = null
                                rightHandAngle = null
                                finalCalculatedAngle = null
                                leftHandBitmap = null
                                rightHandBitmap = null
                                currentLiveAngle = 0.0f
                                isHandPresent = false
                                detectedHandLabel = null
                                isUploading = false
                            },
                            onDismiss = {
                                val statusStr = if (finalCalculatedAngle != null) "SUCCESS" else "CANCELLED"
                                val resultIntent = Intent().apply {
                                    putExtra("STATUS", statusStr)
                                    putExtra("FINAL_ATD_ANGLE", finalCalculatedAngle ?: 0f)
                                    putExtra("LEFT_ATD_ANGLE", leftHandAngle ?: 0f)
                                    putExtra("RIGHT_ATD_ANGLE", rightHandAngle ?: 0f)
                                    putExtra("USER_TOKEN", userToken)
                                    putExtra("USER_DATA_ID", userDataId)
                                }
                                setResult(Activity.RESULT_OK, resultIntent)
                                finish()
                            }
                        )
                    }
                }
            }
        }
    }
}
