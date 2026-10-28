package com.daksh.daksh

import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.OnBackPressedCallback
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import com.daksh.daksh.model.EnhancedImageResult
import com.daksh.daksh.model.ScanMode
import com.daksh.daksh.model.ScanStep
import com.daksh.daksh.ui.screens.ScanStepScreen
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.Executors

class ScanActivity : ComponentActivity() {

    companion object {
        const val EXTRA_MODE = "mode"            // "group" | "individual"
        const val EXTRA_STEPS = "steps"          // optional ArrayList<String> of ScanStep names
        const val EXTRA_RESULTS_JSON = "results" // String (JSON array)

        fun stepsFor(mode: ScanMode): List<ScanStep> =
            if (mode == ScanMode.GROUP_MODE) {
                listOf(
                    ScanStep.LEFT_THUMB_GROUP,
                    ScanStep.LEFT_FOUR_FINGERS_GROUP,
                    ScanStep.RIGHT_THUMB_GROUP,
                    ScanStep.RIGHT_FOUR_FINGERS_GROUP
                )
            }
            else {
                listOf(
                    ScanStep.RIGHT_THUMB_IND,
                    ScanStep.RIGHT_INDEX_IND,
                    ScanStep.RIGHT_MIDDLE_IND,
                    ScanStep.RIGHT_RING_IND,
                    ScanStep.RIGHT_LITTLE_IND,
                    ScanStep.LEFT_THUMB_IND,
                    ScanStep.LEFT_INDEX_IND,
                    ScanStep.LEFT_MIDDLE_IND,
                    ScanStep.LEFT_RING_IND,
                    ScanStep.LEFT_LITTLE_IND
                )
            }

        fun parseMode(raw: String?): ScanMode =
            if (raw == "individual") ScanMode.INDIVIDUAL_MODE else ScanMode.GROUP_MODE
    }

    // Single thread so "save result" tasks and the final "finish" task run in order.
    private val io = Executors.newSingleThreadExecutor()

    // Keyed by step so re-scanning a finger replaces the earlier result.
    private val collected = LinkedHashMap<String, JSONObject>()
    private var finishing = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Stay awake + max brightness for scanning.
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        window.attributes = window.attributes.apply {
            screenBrightness = 1.0f
        }

        val initialMode = parseMode(intent?.getStringExtra(EXTRA_MODE))
        val requestedRaw = intent?.getStringArrayListExtra(EXTRA_STEPS)
        val requestedList: List<ScanStep>? = requestedRaw?.mapNotNull { name ->
            ScanStep.entries.firstOrNull { it.name == name }
        }
        val initialSteps: List<ScanStep> = if (requestedList != null && requestedList.size > 0) requestedList else stepsFor(initialMode)

        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() = finishWithResults()
        })

        setContent {
            MaterialTheme {
                Surface(modifier = Modifier.fillMaxSize(), color = Color(0xFF0A0E17)) {
                    var mode by remember { mutableStateOf(initialMode) }
                    var steps by remember { mutableStateOf(initialSteps) }
                    var index by remember { mutableStateOf(0) }

                    ScanStepScreen(
                        currentStepIndex = index.coerceIn(0, steps.size - 1),
                        steps = steps,
                        selectedMode = mode,
                        onModeChanged = { newMode ->
                            mode = newMode
                            steps = stepsFor(newMode)
                            index = 0
                        },
                        onStepSelected = { index = it },
                        onCloseClicked = { finishWithResults() },
                        onResultGenerated = { result ->
                            handleResult(result) {
                                if (index < steps.size - 1) index++ else finishWithResults()
                            }
                        },
                        onNextStepRequested = {
                            index = if (index < steps.size - 1) index + 1 else 0
                        }
                    )
                }
            }
        }
    }

    private fun handleResult(result: EnhancedImageResult, onSaved: () -> Unit) {
        io.execute {
            try {
                val json = ScanResultStore.save(this, result)
                synchronized(collected) { collected[result.step.name] = json }
                runOnUiThread(onSaved)
            } catch (e: Exception) {
                android.util.Log.e("ScanActivity", "Saving scan result failed", e)
                // Never advance to the next finger if saving this one failed.
                runOnUiThread {
                    android.widget.Toast.makeText(
                        this, "Fingerprint was not saved. Please retry this finger.",
                        android.widget.Toast.LENGTH_LONG
                    ).show()
                }
            }
        }
    }


    private fun finishWithResults() {
        if (finishing) return
        finishing = true
        io.execute {
            val array = JSONArray()
            synchronized(collected) { collected.values.forEach { array.put(it) } }
            runOnUiThread {
                setResult(RESULT_OK, Intent().putExtra(EXTRA_RESULTS_JSON, array.toString()))
                finish()
            }
        }
    }

    override fun onDestroy() {
        io.shutdown()
        super.onDestroy()
    }
}
