package com.daksh.daksh.atd

import android.content.Context
import android.graphics.Bitmap
import android.os.SystemClock
import android.util.Log
import androidx.core.content.ContextCompat
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult
import kotlin.math.hypot

private const val TAG = "PalmScan_HandTracker"

enum class PalmPositionStatus {
    TOO_FAR,
    TOO_CLOSE,
    PERFECT
}

class HandTracker(
    private val context: Context,
    private val onHandDetected: (detectedAngle: Float, handLabel: String, positionStatus: PalmPositionStatus, wrist: Point2D, indexA: Point2D, pinkyD: Point2D) -> Unit,
    private val onNoHandDetected: () -> Unit,
    private val onError: (String) -> Unit
) {
    private var handLandmarker: HandLandmarker? = null
    private val mainExecutor = ContextCompat.getMainExecutor(context)
    private var isProcessing = false

    init {
        setupLandmarker()
    }

    private fun setupLandmarker() {
        val candidatePaths = listOf(
            "flutter_assets/assets/atdmodel/hand_landmarker.task",
            "assets/atdmodel/hand_landmarker.task",
            "atdmodel/hand_landmarker.task",
            "hand_landmarker.task"
        )

        var created: HandLandmarker? = null
        var lastError: Exception? = null

        for (path in candidatePaths) {
            try {
                Log.d(TAG, "Attempting to load model asset from path: $path")
                val baseOptions = BaseOptions.builder()
                    .setModelAssetPath(path)
                    .build()

                val options = HandLandmarker.HandLandmarkerOptions.builder()
                    .setBaseOptions(baseOptions)
                    .setMinHandDetectionConfidence(0.6f)
                    .setMinHandPresenceConfidence(0.6f)
                    .setMinTrackingConfidence(0.6f)
                    .setNumHands(1)
                    .setRunningMode(RunningMode.LIVE_STREAM)
                    .setResultListener { result: HandLandmarkerResult, _ ->
                        isProcessing = false
                        processResult(result)
                    }
                    .setErrorListener { error ->
                        isProcessing = false
                        Log.e(TAG, "MediaPipe Error -> ${error.message}")
                        mainExecutor.execute {
                            onError(error.message ?: "Unknown MediaPipe error")
                        }
                    }
                    .build()

                created = HandLandmarker.createFromOptions(context, options)
                Log.i(TAG, "HandLandmarker successfully initialized using asset path: '$path'")
                break
            } catch (e: Exception) {
                lastError = e
                Log.w(TAG, "Could not load model from asset path '$path': ${e.localizedMessage}")
            }
        }

        if (created != null) {
            handLandmarker = created
        } else {
            Log.e(TAG, "CRITICAL: Failed to initialize HandLandmarker from any candidate path!", lastError)
            mainExecutor.execute {
                onError("Failed to init HandLandmarker: ${lastError?.localizedMessage}")
            }
        }
    }

    private fun processResult(result: HandLandmarkerResult) {
        val landmarks = result.landmarks()
        val handednesses = result.handednesses()

        // Require full 21 hand keypoints to ensure strictly valid palm detection
        if (landmarks.isNotEmpty() && landmarks[0].size >= 21) {
            val hand = landmarks[0]

            // Determine Handedness ("Left" / "Right")
            val handLabel = if (handednesses.isNotEmpty() && handednesses[0].isNotEmpty()) {
                val cat = handednesses[0][0]
                if (cat.score() >= 0.35f) "${cat.categoryName()} (${(cat.score() * 100).toInt()}%)" else "Palm"
            } else "Palm"

            // Point T = Wrist (Landmark 0)
            val wrist = Point2D(hand[0].x(), hand[0].y())
            // Point A = Index MCP (Landmark 5)
            val indexA = Point2D(hand[5].x(), hand[5].y())
            // Point D = Pinky MCP (Landmark 17)
            val pinkyD = Point2D(hand[17].x(), hand[17].y())

            val angle = AtdMath.calculateAngle(wrist, indexA, pinkyD)

            // Estimate distance & positioning status based on wrist-index landmark span
            val palmSpan = hypot(indexA.x - wrist.x, indexA.y - wrist.y)
            val positionStatus = when {
                palmSpan < 0.10f -> PalmPositionStatus.TOO_FAR
                palmSpan > 0.60f -> PalmPositionStatus.TOO_CLOSE
                else -> PalmPositionStatus.PERFECT
            }

            Log.d(
                TAG,
                "Result: Hand=$handLabel, Angle=$angle°, Span=$palmSpan, Status=$positionStatus, Wrist=(${wrist.x}, ${wrist.y}), IndexA=(${indexA.x}, ${indexA.y}), PinkyD=(${pinkyD.x}, ${pinkyD.y})"
            )

            // Palm ATD Angle Range Validation (18.0° to 75.0°)
            if (angle in 18.0f..75.0f) {
                Log.i(TAG, "VALID PALM DETECTED -> Angle: $angle°, Hand: $handLabel, Status: $positionStatus")
                mainExecutor.execute {
                    onHandDetected(angle, handLabel, positionStatus, wrist, indexA, pinkyD)
                }
            } else {
                Log.w(TAG, "Palm angle $angle° out of valid range (18.0°-75.0°)")
                mainExecutor.execute {
                    onNoHandDetected()
                }
            }
        } else {
            Log.d(TAG, "No hand landmarks detected in this frame")
            mainExecutor.execute {
                onNoHandDetected()
            }
        }
    }

    fun detectLiveFrame(bitmap: Bitmap) {
        if (handLandmarker == null || isProcessing) return
        try {
            isProcessing = true
            val mpImage = BitmapImageBuilder(bitmap).build()
            val frameTime = SystemClock.uptimeMillis()
            handLandmarker?.detectAsync(mpImage, frameTime)
        } catch (e: Exception) {
            isProcessing = false
            Log.e(TAG, "detectLiveFrame Exception -> ${e.message}", e)
        }
    }

    fun close() {
        handLandmarker?.close()
        handLandmarker = null
    }
}
