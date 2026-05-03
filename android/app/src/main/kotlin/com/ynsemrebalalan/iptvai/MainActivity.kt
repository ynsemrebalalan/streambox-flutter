package com.ynsemrebalalan.iptvai

import android.app.PictureInPictureParams
import android.content.res.Configuration
import android.os.Build
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity Picture-in-Picture (PiP) destegi ile.
 *
 * Cagri akisi (player_screen.dart):
 *   - PiP butonu → MethodChannel "iptvai/pip" : "enter"
 *   - Kullanici Home tusuna basti → onUserLeaveHint → otomatik PiP (auto pref ON ise)
 *
 * PiP requirement:
 *   - Android 8.0+ (API 26) — manifest android:supportsPictureInPicture="true"
 *   - Activity uses configChanges (manifest) — system PiP'e gecerken activity recreate olmaz
 *   - resizeableActivity="true"
 *
 * UI tarafi: Flutter view'i PiP icinde gosterilir (media_kit Texture-based render
 * Android'de PiP penceresi icinde dogru calisir; ses devam eder).
 */
class MainActivity : FlutterActivity() {

    private var channel: MethodChannel? = null
    private var autoPipEnabled: Boolean = false
    private var isPlayerActive: Boolean = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "iptvai/pip")
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "isSupported" -> {
                    val supported = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                        packageManager.hasSystemFeature(
                            android.content.pm.PackageManager.FEATURE_PICTURE_IN_PICTURE
                        )
                    result.success(supported)
                }
                "enter" -> {
                    val ok = enterPipSafe()
                    result.success(ok)
                }
                "setAutoPip" -> {
                    autoPipEnabled = (call.arguments as? Boolean) ?: false
                    result.success(true)
                }
                "setPlayerActive" -> {
                    isPlayerActive = (call.arguments as? Boolean) ?: false
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * onUserLeaveHint — kullanici Home tusuna basinca tetiklenir (back tusunda DEGIL).
     * Player aktifse + auto PiP acik ise otomatik PiP'e gec.
     */
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (autoPipEnabled && isPlayerActive) {
            enterPipSafe()
        }
    }

    /**
     * PiP'e guvenle gir. Hata durumunda crash etmek yerine false don.
     */
    private fun enterPipSafe(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        return try {
            val params = PictureInPictureParams.Builder()
                .setAspectRatio(Rational(16, 9))
                .build()
            enterPictureInPictureMode(params)
            true
        } catch (e: IllegalStateException) {
            // Activity arka planda veya PiP zaten aktif
            false
        } catch (e: Exception) {
            false
        }
    }

    /**
     * PiP mode degisikligini Flutter'a bildir — UI controls gizlenir/gosterilir.
     */
    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        channel?.invokeMethod("pipModeChanged", isInPictureInPictureMode)
    }
}
