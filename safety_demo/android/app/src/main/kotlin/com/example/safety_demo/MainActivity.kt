package com.example.safety_demo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.KeyEvent

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.safety_demo/panic_channel"
    private var volumePressCount = 0
    private var lastVolumePressTime = 0L
    private val VOLUME_PRESS_THRESHOLD = 3 // Number of presses to trigger panic
    private val VOLUME_PRESS_TIMEOUT = 2000L // 2 seconds window for presses
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                if (call.method == "someNativeCall") {
                    val data = call.argument<String>("data")
                    Log.d("MainActivity", "Received call from Flutter: someNativeCall with data: $data")
                    result.success("Native side processed: $data")
                } else {
                    result.notImplemented()
                }
            }
        }

        // For demo/testing: Simulate panic trigger after 5 seconds
        // Remove this in production or make it optional
        Handler(Looper.getMainLooper()).postDelayed({
            Log.d("MainActivity", "Demo: Simulating panicTriggered call to Flutter...")
            triggerPanic()
        }, 5000)
    }

    // Override key down to detect volume button presses
    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN || keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            val currentTime = System.currentTimeMillis()
            
            // Reset counter if too much time has passed
            if (currentTime - lastVolumePressTime > VOLUME_PRESS_TIMEOUT) {
                volumePressCount = 0
            }
            
            volumePressCount++
            lastVolumePressTime = currentTime
            
            Log.d("MainActivity", "Volume button pressed. Count: $volumePressCount")
            
            // Trigger panic if threshold reached
            if (volumePressCount >= VOLUME_PRESS_THRESHOLD) {
                Log.d("MainActivity", "Panic threshold reached! Triggering panic...")
                triggerPanic()
                volumePressCount = 0 // Reset counter
                return true // Consume the event
            }
        }
        
        return super.onKeyDown(keyCode, event)
    }

    private fun triggerPanic() {
        methodChannel?.invokeMethod("panicTriggered", null, object : MethodChannel.Result {
            override fun success(res: Any?) {
                Log.d("MainActivity", "Flutter responded to panicTriggered: $res")
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                Log.e("MainActivity", "Error invoking panicTriggered on Flutter: $errorMessage ($errorCode)")
            }

            override fun notImplemented() {
                Log.w("MainActivity", "panicTriggered method not implemented on Flutter side.")
            }
        })
    }
}
