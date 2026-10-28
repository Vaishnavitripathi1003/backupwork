package com.daksh.daksh.atd

import android.content.Context
import android.content.SharedPreferences
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL

data class AppStatusInfo(
    val isDiscontinued: Boolean = false,
    val title: String = "App Discontinued",
    val message: String = "This version of DAKSH PalmATD has been discontinued. Please update to the latest release to continue.",
    val updateUrl: String = "https://play.google.com/store/apps",
    val supportEmail: String = "support@dakshpalmatd.com",
    val minSupportedVersionCode: Int = 1
)

class AppStatusManager(private val context: Context) {

    private val prefs: SharedPreferences =
        context.getSharedPreferences("daksh_app_status_prefs", Context.MODE_PRIVATE)

    // Default configuration API endpoint URL (developer can replace with their server/GitHub raw JSON URL)
    var customApiUrl: String
        get() = prefs.getString("custom_api_url", DEFAULT_API_URL) ?: DEFAULT_API_URL
        set(value) = prefs.edit().putString("custom_api_url", value).apply()

    private val _statusState = MutableStateFlow(loadCachedStatus())
    val statusState: StateFlow<AppStatusInfo> = _statusState

    private val _isChecking = MutableStateFlow(false)
    val isChecking: StateFlow<Boolean> = _isChecking

    init {
        // Load initial state
        _statusState.value = loadCachedStatus()
    }

    private fun loadCachedStatus(): AppStatusInfo {
        val isDiscontinued = prefs.getBoolean("is_discontinued", false)
        val title = prefs.getString("title", "App Discontinued") ?: "App Discontinued"
        val message = prefs.getString("message", "This version of DAKSH PalmATD is discontinued.")
            ?: "This version of DAKSH PalmATD is discontinued."
        val updateUrl = prefs.getString("update_url", "https://play.google.com/store/apps")
            ?: "https://play.google.com/store/apps"
        val supportEmail = prefs.getString("support_email", "support@dakshpalmatd.com")
            ?: "support@dakshpalmatd.com"
        val minVer = prefs.getInt("min_version_code", 1)

        return AppStatusInfo(
            isDiscontinued = isDiscontinued,
            title = title,
            message = message,
            updateUrl = updateUrl,
            supportEmail = supportEmail,
            minSupportedVersionCode = minVer
        )
    }

    private fun saveCachedStatus(status: AppStatusInfo) {
        prefs.edit()
            .putBoolean("is_discontinued", status.isDiscontinued)
            .putString("title", status.title)
            .putString("message", status.message)
            .putString("update_url", status.updateUrl)
            .putString("support_email", status.supportEmail)
            .putInt("min_version_code", status.minSupportedVersionCode)
            .apply()
        _statusState.value = status
    }

    /**
     * Checks the remote API to verify if the current APK version is discontinued.
     */
    suspend fun checkAppStatus(currentVersionCode: Int = 2): AppStatusInfo {
        return withContext(Dispatchers.IO) {
            _isChecking.value = true
            try {
                // If local test toggle for discontinue is ON, use local test response
                val localTestDiscontinued = prefs.getBoolean("local_test_discontinued", false)
                if (localTestDiscontinued) {
                    val testStatus = AppStatusInfo(
                        isDiscontinued = true,
                        title = "APK Discontinued (Test Mode)",
                        message = "This APK version has been flagged as discontinued via API check. Please update your DAKSH PalmATD app.",
                        updateUrl = "https://play.google.com/store/apps",
                        supportEmail = "support@dakshpalmatd.com"
                    )
                    saveCachedStatus(testStatus)
                    return@withContext testStatus
                }

                val url = URL(customApiUrl)
                val connection = url.openConnection() as HttpURLConnection
                connection.requestMethod = "GET"
                connection.connectTimeout = 5000
                connection.readTimeout = 5000

                if (connection.responseCode == 200) {
                    val reader = BufferedReader(InputStreamReader(connection.inputStream))
                    val response = StringBuilder()
                    var line: String?
                    while (reader.readLine().also { line = it } != null) {
                        response.append(line)
                    }
                    reader.close()

                    val json = JSONObject(response.toString())
                    val isDiscontinuedJson = json.optBoolean("is_discontinued", false)
                    val titleJson = json.optString("title", "App Discontinued")
                    val messageJson = json.optString(
                        "message",
                        "This version of DAKSH PalmATD is discontinued."
                    )
                    val updateUrlJson =
                        json.optString("update_url", "https://play.google.com/store/apps")
                    val supportEmailJson =
                        json.optString("support_email", "support@dakshpalmatd.com")
                    val minVerJson = json.optInt("min_supported_version_code", 1)

                    val isDiscontinued = isDiscontinuedJson || (currentVersionCode < minVerJson)

                    val newStatus = AppStatusInfo(
                        isDiscontinued = isDiscontinued,
                        title = titleJson,
                        message = messageJson,
                        updateUrl = updateUrlJson,
                        supportEmail = supportEmailJson,
                        minSupportedVersionCode = minVerJson
                    )
                    saveCachedStatus(newStatus)
                    newStatus
                } else {
                    // Endpoint unreachable or non-200; return current cached status
                    loadCachedStatus()
                }
            } catch (e: Exception) {
                // On network error or bad URL, retain cached state so offline usage is preserved
                loadCachedStatus()
            } finally {
                _isChecking.value = false
            }
        }
    }

    /**
     * Manually toggle discontinue test state for testing purposes in app profile settings.
     */
    fun setTestDiscontinuedState(discontinued: Boolean) {
        prefs.edit().putBoolean("local_test_discontinued", discontinued).apply()
        val current = loadCachedStatus()
        val updated = current.copy(
            isDiscontinued = discontinued,
            title = if (discontinued) "APK Discontinued (Test Mode)" else "App Active",
            message = if (discontinued) "This APK version has been discontinued via API policy." else "App is active."
        )
        saveCachedStatus(updated)
    }

    fun isTestDiscontinuedEnabled(): Boolean {
        return prefs.getBoolean("local_test_discontinued", false)
    }

    companion object {
        const val DEFAULT_API_URL = "https://raw.githubusercontent.com/example/palmatd/main/app_config.json"
    }
}
