package com.kilocal.app

import android.content.Intent
import android.provider.AlarmClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "kilocal/system_timer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startTimer" -> {
                        val seconds = call.argument<Int>("seconds") ?: 0
                        val label = call.argument<String>("label") ?: "KiloCal"
                        startSystemTimer(seconds, label, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /** Opens the system Clock app with a pre-filled timer. */
    private fun startSystemTimer(
        seconds: Int,
        label: String,
        result: MethodChannel.Result,
    ) {
        val intent = Intent(AlarmClock.ACTION_SET_TIMER).apply {
            putExtra(AlarmClock.EXTRA_LENGTH, seconds)
            putExtra(AlarmClock.EXTRA_MESSAGE, label)
            putExtra(AlarmClock.EXTRA_SKIP_UI, false)
        }
        if (intent.resolveActivity(packageManager) != null) {
            startActivity(intent)
            result.success(true)
        } else {
            // No Clock app handles the intent; the caller falls back to the pill.
            result.success(false)
        }
    }
}
