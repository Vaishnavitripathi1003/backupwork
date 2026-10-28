package com.daksh.daksh.atd

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

data class ScanHistoryRecord(
    val id: String = System.currentTimeMillis().toString(),
    val timestamp: String = SimpleDateFormat("MMM dd, yyyy • hh:mm a", Locale.getDefault()).format(Date()),
    val finalAngle: Float,
    val leftAngle: Float,
    val rightAngle: Float,
    val categoryLabel: String
)

class UserProfileRepository(context: Context) {

    private val prefs: SharedPreferences =
        context.getSharedPreferences("daksh_scan_history_prefs", Context.MODE_PRIVATE)

    fun getScanHistory(): List<ScanHistoryRecord> {
        val jsonString = prefs.getString("scan_history_json", null) ?: return emptyList()
        return try {
            val array = JSONArray(jsonString)
            val list = mutableListOf<ScanHistoryRecord>()
            for (i in 0 until array.length()) {
                val obj = array.getJSONObject(i)
                list.add(
                    ScanHistoryRecord(
                        id = obj.optString("id", i.toString()),
                        timestamp = obj.optString("timestamp", ""),
                        finalAngle = obj.optDouble("finalAngle", 40.1).toFloat(),
                        leftAngle = obj.optDouble("leftAngle", 38.8).toFloat(),
                        rightAngle = obj.optDouble("rightAngle", 41.4).toFloat(),
                        categoryLabel = obj.optString("categoryLabel", "Normal")
                    )
                )
            }
            list
        } catch (e: Exception) {
            emptyList()
        }
    }

    fun addScanRecord(record: ScanHistoryRecord) {
        val current = getScanHistory().toMutableList()
        current.add(0, record) // Insert at beginning
        saveScanHistory(current)
    }

    fun clearScanHistory() {
        prefs.edit().remove("scan_history_json").apply()
    }

    private fun saveScanHistory(list: List<ScanHistoryRecord>) {
        val array = JSONArray()
        for (rec in list) {
            val obj = JSONObject().apply {
                put("id", rec.id)
                put("timestamp", rec.timestamp)
                put("finalAngle", rec.finalAngle.toDouble())
                put("leftAngle", rec.leftAngle.toDouble())
                put("rightAngle", rec.rightAngle.toDouble())
                put("categoryLabel", rec.categoryLabel)
            }
            array.put(obj)
        }
        prefs.edit().putString("scan_history_json", array.toString()).apply()
    }
}
