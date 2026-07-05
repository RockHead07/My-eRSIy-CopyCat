package com.rsislam.surabaya.rs_islam_app

import android.view.KeyEvent
import com.unity3d.player.UnityPlayer
import com.unity3d.player.UnityPlayerGameActivity

/**
 * The AR activity we launch (T4.5). Two hard constraints shape how we leave AR:
 *  1. Do NOT destroy Unity — Unity-as-a-Library can't be unloaded/reloaded in one process
 *     (JNI_OnUnload crashes natively and kills the app). So no finish()/destroy.
 *  2. This activity runs in its OWN task (singleTask + default affinity, separate from
 *     MainActivity's affinity=""). So the way back to the Flutter host is moveTaskToBack():
 *     it backgrounds the Unity task and reveals MainActivity's task underneath, intact on
 *     the Navigasi Indoor page — with Unity still loaded/paused for a fast re-entry.
 */
class DarsiUnityActivity : UnityPlayerGameActivity() {

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() = leaveAr()

    override fun onKeyUp(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            leaveAr()
            return true
        }
        return super.onKeyUp(keyCode, event)
    }

    private fun leaveAr() {
        // Unity is still loaded, so UnitySendMessage works: emit arSessionClosed (with
        // arrived/poiId) so the WebView resumes. Then background this task -> host reappears.
        UnityPlayer.UnitySendMessage("UaaLEntryPoint", "CloseArSession", "")
        moveTaskToBack(true)
    }
}
