package com.br.jornadakids.flutter_jornadakids

import android.accessibilityservice.AccessibilityService
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.accessibility.AccessibilityEvent
import android.content.Intent
import org.json.JSONObject

class AppBlockerService : AccessibilityService() {

    private val handler = Handler(Looper.getMainLooper())
    private var currentForegroundPackage: String? = null
    private var sessionStartMs: Long = 0L
    private var usageAtSessionStartMs: Long = 0L

    private val periodicCheck = object : Runnable {
        override fun run() {
            try {
                currentForegroundPackage?.let { pkg ->
                    if (isOverLimit(pkg)) {
                        showBlockedScreen()
                    }
                }
            } catch (_: Exception) {
                // evita crash do serviço caso algo falhe na verificação
            } finally {
                handler.postDelayed(this, 3_000) // checa a cada 3s
            }
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        // Inicia verificação periódica para bloquear durante o uso
        handler.post(periodicCheck)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString() ?: return
            // Reinicia sessão quando trocar o app em primeiro plano
            if (currentForegroundPackage != packageName) {
                currentForegroundPackage = packageName
                sessionStartMs = System.currentTimeMillis()
                usageAtSessionStartMs = safeGetUsage(packageName)
            }

            // Checa imediatamente quando muda a janela/atividade
            if (isOverLimit(packageName)) {
                showBlockedScreen()
            }
        }
    }

    override fun onInterrupt() {
        // Chamado quando o serviço é interrompido
    }

    private fun showBlockedScreen() {
        val intent = Intent(this, BlockedActivity::class.java)
        // passa o pacote atual para que a tela possa exibir o nome do app
        currentForegroundPackage?.let { intent.putExtra("packageName", it) }
        intent.addFlags(
            Intent.FLAG_ACTIVITY_NEW_TASK or
            Intent.FLAG_ACTIVITY_CLEAR_TOP or
            Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
        )
        startActivity(intent)
    }

    private fun isOverLimit(packageName: String): Boolean {
        val limits = readAppLimitsMinutes()
        val limitMinutes = limits[packageName] ?: return false
        val usageMs = estimatedUsageMs(packageName)
        val limitMs = limitMinutes * 60_000L
        return usageMs >= limitMs
    }

    private fun readAppLimitsMinutes(): Map<String, Long> {
        // Chave usada pelo plugin shared_preferences do Flutter
        val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        val json = flutterPrefs.getString("flutter.app_limits", null) ?: return emptyMap()
        return try {
            val obj = JSONObject(json)
            val map = mutableMapOf<String, Long>()
            val keys = obj.keys()
            while (keys.hasNext()) {
                val key = keys.next()
                val value = obj.optLong(key, obj.optInt(key, 0).toLong())
                if (value > 0) map[key] = value
            }
            map
        } catch (_: Exception) {
            emptyMap()
        }
    }

    private fun getUsageForLast24h(packageName: String): Long {
        val usm = getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
        val end = System.currentTimeMillis()
        val start = end - 24L * 60L * 60L * 1000L // últimas 24h, para alinhar com o Flutter

        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val map = usm.queryAndAggregateUsageStats(start, end)
                val stats: UsageStats? = map[packageName]
                stats?.totalTimeInForeground ?: 0L
            } else {
                var total = 0L
                val list = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, start, end)
                for (us in list) {
                    if (us.packageName == packageName) {
                        total += us.totalTimeInForeground
                    }
                }
                total
            }
        } catch (_: Exception) {
            0L
        }
    }

    private fun estimatedUsageMs(packageName: String): Long {
        val reported = safeGetUsage(packageName)
        return if (packageName == currentForegroundPackage && sessionStartMs > 0L) {
            val elapsed = System.currentTimeMillis() - sessionStartMs
            // base (quando entrou) + tempo decorrido
            val estimate = usageAtSessionStartMs + elapsed
            maxOf(reported, estimate)
        } else {
            reported
        }
    }

    private fun safeGetUsage(packageName: String): Long = try {
        getUsageForLast24h(packageName)
    } catch (_: Exception) {
        0L
    }
}
