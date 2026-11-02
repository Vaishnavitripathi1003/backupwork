package com.daksh.daksh

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.os.Handler
import android.os.Looper
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import com.daksh.daksh.model.ScanStep
import com.daksh.daksh.processing.FingerprintProcessor
import com.daksh.daksh.atd.AtdScanActivity
import com.daksh.daksh.ui.screens.BiometricScanActivity
import com.daksh.daksh.ui.screens.GroupBiometricScanActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterFragmentActivity() {

    companion object {
        const val CHANNEL = "com.example.fingerprintworkdemo/native"
        const val SCANNER_CHANNEL = "com.daksh.app/scanner"
    }

    private val worker = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    private var pendingPermission: MethodChannel.Result? = null
    private var pendingScan: MethodChannel.Result? = null

    private val permissionLauncher = registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            pendingPermission?.success(granted)
            pendingPermission = null
        }

    private val scanLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { activityResult ->
            val status = activityResult.data?.getStringExtra("STATUS")
            val json = activityResult.data?.getStringExtra(ScanActivity.EXTRA_RESULTS_JSON) ?: "[]"
            pendingScan?.success(status ?: json)
            pendingScan = null
        }
    private val scanLauncher1 = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { activityResult ->
        val status = activityResult.data?.getStringExtra("STATUSATD") ?: activityResult.data?.getStringExtra("STATUSATD")
        val finalResult = status ?: if (activityResult.resultCode == RESULT_OK) "SUCCESS" else "CANCELLED"
        pendingScan?.success(finalResult)
        pendingScan = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Channel 1: Native Fingerprint Work Demo Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    "hasCameraPermission" -> result.success(hasCameraPermission())

                    "requestCameraPermission" -> {
                        if (hasCameraPermission()) {
                            result.success(true)
                        } else if (pendingPermission != null) {
                            result.error("BUSY", "A permission request is already in progress", null)
                        } else {
                            pendingPermission = result
                            permissionLauncher.launch(Manifest.permission.CAMERA)
                        }
                    }

                    "getScanSteps" -> {
                        val mode = ScanActivity.parseMode(call.argument<String>("mode"))
                        val steps = ScanActivity.stepsFor(mode).map { step ->
                            ScanResultStore.stepToJson(step).let { json ->
                                mapOf(
                                    "name" to json.getString("name"),
                                    "handSide" to json.getString("handSide"),
                                    "fingerName" to json.getString("fingerName"),
                                    "title" to json.getString("title"),
                                    "description" to json.getString("description"),
                                    "fingerCount" to json.getInt("fingerCount")
                                )
                            }
                        }
                        result.success(steps)
                    }

                    "startScan" -> {
                        if (!hasCameraPermission()) {
                            result.error("PERMISSION_DENIED", "Camera permission not granted", null)
                            return@setMethodCallHandler
                        }
                        if (pendingScan != null) {
                            result.error("BUSY", "A scan is already in progress", null)
                            return@setMethodCallHandler
                        }
                        val intent = Intent(this, ScanActivity::class.java).apply {
                            putExtra(ScanActivity.EXTRA_MODE, call.argument<String>("mode") ?: "group")
                            //////////todo manage local start
                            putExtra("USER_DATA_ID", call.argument<String>("userDataId") ?: "")
                            /////todo manage local end
                            call.argument<List<String>>("steps")?.let {
                                putStringArrayListExtra(ScanActivity.EXTRA_STEPS, ArrayList(it))
                            }
                        }
                        pendingScan = result
                        scanLauncher.launch(intent)
                    }

                    "classifyImage" -> {
                        val path = call.argument<String>("path")
                        val stepName = call.argument<String>("step")
                        val step = ScanStep.entries.firstOrNull { it.name == stepName }
                        if (path == null || step == null) {
                            result.error("BAD_ARGS", "path and a valid step are required", null)
                            return@setMethodCallHandler
                        }
                        worker.execute {
                            try {
                                val bitmap = BitmapFactory.decodeFile(path)
                                    ?: throw IllegalArgumentException("Could not decode image at $path")
                                val processed =
                                    FingerprintProcessor.processAndEnhanceImage(applicationContext, bitmap, step)
                                val json = ScanResultStore.save(applicationContext, processed)
                                mainHandler.post { result.success(json.toString()) }
                            } catch (e: Exception) {
                                mainHandler.post { result.error("CLASSIFY_FAILED", e.message, null) }
                            }
                        }
                    }

                    "clearScanCache" -> result.success(ScanResultStore.clear(applicationContext))

                    else -> result.notImplemented()
                }
            }

        // Channel 2: Direct Finger Scanner & Server Uploader Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCANNER_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openBiometricScanner" -> {
                        if (!hasCameraPermission()) {
                            result.error("PERMISSION_DENIED", "Camera permission not granted", null)
                            return@setMethodCallHandler
                        }
                        if (pendingScan != null) {
                            result.error("BUSY", "A scan is already in progress", null)
                            return@setMethodCallHandler
                        }
                        val token = call.argument<String>("userToken") ?: ""
                        val userDataId = call.argument<String>("userDataId") ?: ""

                        val intent = Intent(this, BiometricScanActivity::class.java).apply {
                            putExtra("USER_TOKEN", token)
                            putExtra("USER_DATA_ID", userDataId)
                        }
                        pendingScan = result
                        scanLauncher.launch(intent)
                    }
                    "openGroupBiometricScanner" -> {
                        if (!hasCameraPermission()) {
                            result.error("PERMISSION_DENIED", "Camera permission not granted", null)
                            return@setMethodCallHandler
                        }
                        if (pendingScan != null) {
                            result.error("BUSY", "A scan is already in progress", null)
                            return@setMethodCallHandler
                        }
                        val token = call.argument<String>("userToken") ?: ""
                        val userDataId = call.argument<String>("userDataId") ?: ""

                        val intent = Intent(this, GroupBiometricScanActivity::class.java).apply {
                            putExtra("USER_TOKEN", token)
                            putExtra("USER_DATA_ID", userDataId)
                        }
                        pendingScan = result
                        scanLauncher.launch(intent)
                    }
                    "openAtdScanner" -> {
                        if (pendingScan != null) {
                            result.error("BUSY", "A scan is already in progress", null)
                            return@setMethodCallHandler
                        }
                        val token = call.argument<String>("userToken") ?: ""
                        val userDataId = call.argument<String>("userDataId") ?: ""

                        val intent = Intent(this, AtdScanActivity::class.java).apply {
                            putExtra("USER_TOKEN", token)
                            putExtra("USER_DATA_ID", userDataId)
                        }
                        pendingScan = result
                        scanLauncher1.launch(intent)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasCameraPermission(): Boolean =
        ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) ==
                PackageManager.PERMISSION_GRANTED

    override fun onDestroy() {
        worker.shutdown()
        super.onDestroy()
    }
}