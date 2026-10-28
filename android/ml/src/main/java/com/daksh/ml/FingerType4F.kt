package com.daksh.ml

enum class FingerType4F(val value: String) {
    LEFT_THUMB(LEFT_THUMB_STRING_4F),
    RIGHT_THUMB(RIGHT_THUMB_STRING_4F),
    LEFT_HAND(LEFT_HAND_STRING_4F),
    RIGHT_HAND(RIGHT_HAND_STRING_4F);

    fun next(): FingerType4F {
        val values = entries.toTypedArray()
        val currentIndex = ordinal
        val nextIndex = (currentIndex + 1) % values.size
        return values[nextIndex]
    }

    companion object {
        fun fromIndex(index: Int): FingerType4F {
            return when (index) {
                LEFT_THUMB.ordinal      -> LEFT_THUMB
                RIGHT_THUMB.ordinal     -> RIGHT_THUMB
                LEFT_HAND.ordinal       -> LEFT_HAND
                RIGHT_HAND.ordinal      -> RIGHT_HAND
                else -> LEFT_THUMB
            }
        }
    }
}

const val LEFT_THUMB_STRING_4F = "Left Thumb"
const val RIGHT_THUMB_STRING_4F = "Right Thumb"
const val LEFT_HAND_STRING_4F = "Left Hand"
const val RIGHT_HAND_STRING_4F = "Right Hand"