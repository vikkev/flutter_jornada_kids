package com.br.jornadakids.flutter_jornadakids

import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app_blocker_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setBlockedApps" -> {
                    val apps = call.argument<List<String>>("apps")
                    saveBlockedApps(apps ?: listOf())
                    result.success(true)
                }
                "isAccessibilityPermissionGranted" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                "requestAccessibilityPermission" -> {
                    openAccessibilitySettings()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun saveBlockedApps(apps: List<String>) {
        val prefs = getSharedPreferences("app_blocker_prefs", MODE_PRIVATE)
        prefs.edit().putStringSet("blocked_apps", apps.toSet()).apply()
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        val expectedComponent = ComponentName(this, AppBlockerService::class.java).flattenToString()
        val splitter = TextUtils.SimpleStringSplitter(':')
        splitter.setString(enabledServices)

        for (service in splitter) {
            if (service.equals(expectedComponent, ignoreCase = true)) {
                return true
            }
        }
        return false
    }

    private fun openAccessibilitySettings() {
        val componentName = ComponentName(this, AppBlockerService::class.java).flattenToString()

        val detailIntent = Intent(ACTION_ACCESSIBILITY_DETAILS_SETTINGS).apply {
            data = Uri.parse("package:$packageName")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            putExtra(EXTRA_ACCESSIBILITY_COMPONENT_NAME, componentName)
        }

        try {
            startActivity(detailIntent)
        } catch (_: ActivityNotFoundException) {
            val settingsIntent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                putExtra(EXTRA_ACCESSIBILITY_COMPONENT_NAME, componentName)
            }
            try {
                startActivity(settingsIntent)
            } catch (_: ActivityNotFoundException) {
                startActivity(Intent(Settings.ACTION_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            }
        }
    }

    companion object {
        private const val EXTRA_ACCESSIBILITY_COMPONENT_NAME =
            "android.provider.extra.ACCESSIBILITY_COMPONENT_NAME"
        private const val ACTION_ACCESSIBILITY_DETAILS_SETTINGS =
            "android.settings.ACCESSIBILITY_DETAILS_SETTINGS"
    }
}
