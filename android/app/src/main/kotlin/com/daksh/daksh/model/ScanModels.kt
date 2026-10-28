package com.daksh.daksh.model

import android.graphics.Bitmap

enum class ScanMode(val title: String) {
    GROUP_MODE("Full Hand / 4-Fingers Mode"),
    INDIVIDUAL_MODE("10 Individual Single Fingers"),
    FAST("Fast Scan Mode")
}

enum class HandSide {
    RIGHT,
    LEFT
}

enum class ScanStep(
    val handSide: HandSide,
    val fingerName: String,
    val title: String,
    val description: String,
    val fingerCount: Int,
    val isGroupModeStep: Boolean,
    val isIndividualModeStep: Boolean
) {
    // Group Mode Steps (Thumb + 4 Fingers Cluster)
    LEFT_THUMB_GROUP(
        handSide = HandSide.LEFT,
        fingerName = "Left Thumb",
        title = "Left Hand - Thumb",
        description = "Place your Left Thumb inside the AI camera guide.",
        fingerCount = 1,
        isGroupModeStep = true,
        isIndividualModeStep = false
    ),
    LEFT_FOUR_FINGERS_GROUP(
        handSide = HandSide.LEFT,
        fingerName = "Left Hand",
        title = "Left Hand - 4 Fingers",
        description = "Align Index, Middle, Ring, and Little fingers together.",
        fingerCount = 4,
        isGroupModeStep = true,
        isIndividualModeStep = false
    ),
    RIGHT_THUMB_GROUP(
        handSide = HandSide.RIGHT,
        fingerName = "Right Thumb",
        title = "Right Hand - Thumb",
        description = "Place your Right Thumb inside the AI camera guide.",
        fingerCount = 1,
        isGroupModeStep = true,
        isIndividualModeStep = false
    ),
    RIGHT_FOUR_FINGERS_GROUP(
        handSide = HandSide.RIGHT,
        fingerName = "Right Hand",
        title = "Right Hand - 4 Fingers",
        description = "Align Index, Middle, Ring, and Little fingers together.",
        fingerCount = 4,
        isGroupModeStep = true,
        isIndividualModeStep = false
    ),

    // Individual 10 Finger Steps
    RIGHT_THUMB_IND(
        handSide = HandSide.RIGHT,
        fingerName = "R-Thumb",
        title = "Right Hand - Thumb",
        description = "Align your Right Thumb pad inside the frame.",
        fingerCount = 1,
        isGroupModeStep = false,
        isIndividualModeStep = true
    ),
    RIGHT_INDEX_IND(
        handSide = HandSide.RIGHT,
        fingerName = "R-Index",
        title = "Right Hand - Index Finger",
        description = "Align your Right Index fingertip pad inside the frame.",
        fingerCount = 1,
        isGroupModeStep = false,
        isIndividualModeStep = true
    ),
    RIGHT_MIDDLE_IND(
        handSide = HandSide.RIGHT,
        fingerName = "R-Middle",
        title = "Right Hand - Middle Finger",
        description = "Align your Right Middle fingertip pad inside the frame.",
        fingerCount = 1,
        isGroupModeStep = false,
        isIndividualModeStep = true
    ),
    RIGHT_RING_IND(
        handSide = HandSide.RIGHT,
        fingerName = "R-Ring",
        title = "Right Hand - Ring Finger",
        description = "Align your Right Ring fingertip pad inside the frame.",
        fingerCount = 1,
        isGroupModeStep = false,
        isIndividualModeStep = true
    ),
    RIGHT_LITTLE_IND(
        handSide = HandSide.RIGHT,
        fingerName = "R-Little",
        title = "Right Hand - Little Finger",
        description = "Align your Right Little fingertip pad inside the frame.",
        fingerCount = 1,
        isGroupModeStep = false,
        isIndividualModeStep = true
    ),
    LEFT_THUMB_IND(
        handSide = HandSide.LEFT,
        fingerName = "L-Thumb",
        title = "Left Hand - Thumb",
        description = "Align your Left Thumb pad inside the frame.",
        fingerCount = 1,
        isGroupModeStep = false,
        isIndividualModeStep = true
    ),
    LEFT_INDEX_IND(
        handSide = HandSide.LEFT,
        fingerName = "L-Index",
        title = "Left Hand - Index Finger",
        description = "Align your Left Index fingertip pad inside the frame.",
        fingerCount = 1,
        isGroupModeStep = false,
        isIndividualModeStep = true
    ),
    LEFT_MIDDLE_IND(
        handSide = HandSide.LEFT,
        fingerName = "L-Middle",
        title = "Left Hand - Middle Finger",
        description = "Align your Left Middle fingertip pad inside the frame.",
        fingerCount = 1,
        isGroupModeStep = false,
        isIndividualModeStep = true
    ),
    LEFT_RING_IND(
        handSide = HandSide.LEFT,
        fingerName = "L-Ring",
        title = "Left Hand - Ring Finger",
        description = "Align your Left Ring fingertip pad inside the frame.",
        fingerCount = 1,
        isGroupModeStep = false,
        isIndividualModeStep = true
    ),
    LEFT_LITTLE_IND(
        handSide = HandSide.LEFT,
        fingerName = "L-Little",
        title = "Left Hand - Little Finger",
        description = "Align your Left Little fingertip pad inside the frame.",
        fingerCount = 1,
        isGroupModeStep = false,
        isIndividualModeStep = true
    )
}

data class EnhancedImageResult(
    val originalBitmap: Bitmap,
    val enhancedBitmap: Bitmap,
    val predictedPattern: String,
    val patternDescription: String,
    val confidenceScore: Float,
    val topPredictions: List<Pair<String, Float>>,
    val clarityScore: Int,
    val contrastBoost: Int,
    val resolutionText: String,
    val step: ScanStep,
    val enhancedPath: String = "",
    val rawPath: String = "",
    val ridgeCount: Int = 14,
    val patternCode: String = "W",
    /** False when analysis failed and processor used its existing synthetic ridge-count fallback. */
    val ridgeCountMeasured: Boolean = true,
    /** False when both model and classifier failed and a default pattern was substituted. */
    val patternIdentified: Boolean = true
)

data class UserProfile(
    val id: String,
    val name: String,
    val role: String, // e.g. "Class 8", "College", "Father"
    val isPrimary: Boolean
)

data class IntelligenceScore(
    val title: String,
    val score: Int,
    val ratingText: String
)

data class CareerMatch(
    val title: String,
    val matchPercentage: Int
)

data class ChatMessage(
    val sender: String,
    val message: String,
    val isUser: Boolean,
    val time: String = "Just now"
)
