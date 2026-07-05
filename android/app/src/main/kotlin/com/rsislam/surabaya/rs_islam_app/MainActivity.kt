package com.rsislam.surabaya.rs_islam_app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // Locked contract with the Dart side (darsi_navigation_screen.dart).
    private val channelName = "darsi/unity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        // Let Unity -> Flutter events (arSessionClosed, localizationSuccess, ...) flow back
        // through this same channel while the AR activity is foreground (T4.5).
        UnityBridge.channel = channel
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "launchAr" -> {
                    // Full payload JSON (mode/poiId/poiName/floor/building/connectionId).
                    // Passed as an intent extra; Unity's UaaLEntryPoint reads it on start
                    // (decoupled — avoids the UnitySendMessage timing race on a cold launch).
                    val payload = call.arguments as? String ?: "{}"
                    startActivity(
                        Intent(this, DarsiUnityActivity::class.java)
                            .putExtra("darsiPayload", payload)
                    )
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
