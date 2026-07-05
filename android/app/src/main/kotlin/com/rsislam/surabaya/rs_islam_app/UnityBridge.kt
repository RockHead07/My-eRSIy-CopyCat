package com.rsislam.surabaya.rs_islam_app

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodChannel

/**
 * Bridge for Unity (UaaL) -> Flutter events (T4.5). While the AR activity is in
 * the foreground, MainActivity (which owns the FlutterEngine) is backgrounded, so
 * Unity C# can't reach the MethodChannel directly. It calls this static holder
 * instead; we hop to the platform thread and invoke the channel. MainActivity sets
 * `channel` in configureFlutterEngine.
 */
object UnityBridge {
    @JvmStatic
    var channel: MethodChannel? = null

    private val main = Handler(Looper.getMainLooper())

    /** Called from Unity C# via AndroidJavaClass(...).CallStatic("send", event, payload). */
    @JvmStatic
    fun send(event: String, payload: String) {
        main.post { channel?.invokeMethod(event, payload) }
    }
}
