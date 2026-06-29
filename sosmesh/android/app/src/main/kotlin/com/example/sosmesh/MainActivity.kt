package com.example.sosmesh

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "sosmesh/hotspot"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            if (call.method == "openHotspotSettings") {
                result.success(openHotspotSettings())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun openHotspotSettings(): Boolean {
        return try {
            val intent = Intent("android.settings.TETHER_SETTINGS")
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            true
        } catch (_: Exception) {
            try {
                val fallbackIntent = Intent(Settings.ACTION_WIRELESS_SETTINGS)
                fallbackIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(fallbackIntent)
                true
            } catch (_: Exception) {
                false
            }
        }
    }
}
