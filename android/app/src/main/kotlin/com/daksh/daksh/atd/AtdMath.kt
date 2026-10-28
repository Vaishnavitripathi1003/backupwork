package com.daksh.daksh.atd

import kotlin.math.acos
import kotlin.math.hypot
import kotlin.math.roundToInt

data class Point2D(val x: Float, val y: Float)

data class AtdResult(
    val leftAngle: Float,
    val rightAngle: Float,
    val finalAverageAngle: Float,
    val interpretationCategory: InterpretationCategory
)



data class AtdResultFinal(
    val leftAngle: Float,
    val rightAngle: Float,
    val finalAverageAngle: Float,
    val UserDataId: String,

    val interpretationCategory: InterpretationCategory
)



enum class InterpretationCategory(
    val profileName: String,
    val label: String,
    val description: String,
    val cognitiveTrait: String,
    val physicalTrait: String,
    val learningRecommendations: String,
    val strengths: List<String>,
    val rangeTag: String
) {
    BORN_ATHLETE(
        profileName = "Born Athlete / Hyper-Agile",
        label = "Born Athlete / Hyper-Agile (< 35°)",
        description = "Exceptional neuromuscular reflex speed, acute physical instincts, rapid spatial comprehension, and high motor dexterity. Processes physical information instantly.",
        cognitiveTrait = "Rapid information processing, quick instinctual decision making, high spatial intelligence.",
        physicalTrait = "Peak neuromuscular reflex speed, excellent hand-eye coordination, swift physical response time.",
        learningRecommendations = "Thrives in fast-paced, interactive environments. Benefits from hands-on learning, physical activities, dynamic problem-solving, and active sports or martial arts.",
        strengths = listOf("Hyper-fast physical reflexes", "Superior spatial awareness", "Instant motor response", "High adaptability under pressure"),
        rangeTag = "< 35° Born Athlete"
    ),
    ACTIVELY_SMART(
        profileName = "Actively Smart / Sharp Learner",
        label = "Actively Smart / Sharp Learner (35°–40°)",
        description = "Above-average brain-body coordination and motor dexterity. Absorbs new concepts quickly and excels across academics, arts, and physical skill acquisition.",
        cognitiveTrait = "High cognitive flexibility, quick concept absorption, balanced analytical and creative thinking.",
        physicalTrait = "Strong hand-eye coordination, fine motor dexterity, smooth muscle memory formation.",
        learningRecommendations = "Provide diverse challenges in both academics and sports. Excellent candidate for musical instruments, strategy games, fast-track learning modules, and multi-disciplinary projects.",
        strengths = listOf("Rapid concept mastery", "High motor dexterity", "Strong hand-eye coordination", "Versatile problem solver"),
        rangeTag = "35°–40° Actively Smart"
    ),
    NORMAL_BALANCED(
        profileName = "Normal / Balanced (Majority)",
        label = "Normal / Balanced (41°–45°)",
        description = "Standard range representing the majority of population. Demonstrates steady learning pace, reliable coordination, and strong retention through structured practice.",
        cognitiveTrait = "Methodical and balanced information processing, steady memory retention, reliable logic.",
        physicalTrait = "Balanced physical coordination, steady endurance, reliable motor control.",
        learningRecommendations = "Responds best to structured study routines, clear step-by-step instructions, balanced study-rest cycles, and practice-based skill building.",
        strengths = listOf("Consistent learning pace", "Strong memory retention", "Reliable motor skills", "High adaptability to standard routines"),
        rangeTag = "41°–45° Normal"
    ),
    STEP_BY_STEP(
        profileName = "Average / Step-by-Step Learner",
        label = "Average / Step-by-Step Learner (46°–50°)",
        description = "Moderate coordination speed with deliberate processing. Performs best with repetitive practice, structured task breakdowns, and sequential instructions.",
        cognitiveTrait = "Sequential and systematic processing, thoughtful decision making, thorough execution.",
        physicalTrait = "Moderate reaction speed, builds high precision through structured repetition and habituation.",
        learningRecommendations = "Break complex subjects into smaller sequential steps. Use visual aids, repeated practice drills, structured schedules, and patient guidance.",
        strengths = listOf("Thorough and detailed approach", "High patience and persistence", "Excellent execution of structured tasks", "Strong procedural memory"),
        rangeTag = "46°–50° Step-by-Step"
    ),
    METHODICAL(
        profileName = "Methodical / Special Attention",
        label = "Methodical / Special Attention (> 50°)",
        description = "Reflective and deliberate physical and cognitive reaction rate. Requires additional processing time, multi-sensory teaching approaches, and frequent encouragement.",
        cognitiveTrait = "Deep reflective processing, benefits from visual and tactile learning reinforcement.",
        physicalTrait = "Slower reflex response rate; benefits from warm-up routines and deliberate motor exercises.",
        learningRecommendations = "Implement multi-sensory learning techniques (visual + audio + kinesthetic). Offer gentle encouragement, extra processing time, and supportive 1-on-1 instruction.",
        strengths = listOf("Deep reflective focus", "Strong imaginative instincts", "Persistent when supported", "Unique creative perspectives"),
        rangeTag = "> 50° Methodical"
    )
}

object AtdMath {
    /**
     * Calculates the dermatoglyphic ATD angle in degrees.
     * @param wrist Point T (axial triradius / palm base)
     * @param indexMcp Point A (sub-digital triradius at index finger base)
     * @param pinkyMcp Point D (sub-digital triradius at little finger base)
     */
    fun calculateAngle(wrist: Point2D, indexMcp: Point2D, pinkyMcp: Point2D): Float {
        val vTAx = indexMcp.x - wrist.x
        val vTAy = indexMcp.y - wrist.y

        val vTDx = pinkyMcp.x - wrist.x
        val vTDy = pinkyMcp.y - wrist.y

        val dot = vTAx * vTDx + vTAy * vTDy
        val magTA = hypot(vTAx, vTAy)
        val magTD = hypot(vTDx, vTDy)

        if (magTA == 0f || magTD == 0f) return 0f

        val cosVal = (dot / (magTA * magTD)).coerceIn(-1.0f, 1.0f)
        val angleRad = acos(cosVal)
        val angleDeg = Math.toDegrees(angleRad.toDouble()).toFloat()

        return (angleDeg * 10f).roundToInt() / 10f
    }

    fun getCategory(angle: Float): InterpretationCategory {
        return when {
            angle < 35f -> InterpretationCategory.BORN_ATHLETE
            angle in 35f..40f -> InterpretationCategory.ACTIVELY_SMART
            angle in 40.1f..45f -> InterpretationCategory.NORMAL_BALANCED
            angle in 45.1f..50f -> InterpretationCategory.STEP_BY_STEP
            else -> InterpretationCategory.METHODICAL
        }
    }
}
