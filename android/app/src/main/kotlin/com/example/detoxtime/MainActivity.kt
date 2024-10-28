package com.example.pandatime

import android.app.Application
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.os.PowerManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.pandatime/screen"
    private lateinit var powerManager: PowerManager // PowerManager to check screen state

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize PowerManager
        powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager

        // Initialize MethodChannel to communicate with Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "onAppResumed") {
                MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("onAppResumed", null)
            } else {
                result.notImplemented()
            }
        }

        // Register BroadcastReceiver to listen to screen state changes
        val screenReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                when (intent.action) {
                    Intent.ACTION_SCREEN_OFF -> {
                        // Screen was locked, notify Dart immediately
                        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("onScreenOff", null)
                    }
                    Intent.ACTION_USER_PRESENT -> {
                        // Screen was unlocked, notify Dart immediately
                        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("onScreenOn", null)
                    }
                }
            }
        }

        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_USER_PRESENT)
        }
        registerReceiver(screenReceiver, filter)

        // Register the ActivityLifecycleCallbacks to track when app goes to background or foreground
        application.registerActivityLifecycleCallbacks(object : Application.ActivityLifecycleCallbacks {
            override fun onActivityPaused(activity: android.app.Activity) {
                // Called when the activity is about to go into the background
                if (activity === this@MainActivity) {
                    // Check if the screen is off using PowerManager
                    if (powerManager.isInteractive) {
                        // Screen is on, so the app pause is due to switching/minimizing
                        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("onAppPaused", null)
                    } else {
                        // Screen is off, likely due to screen lock
                        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("onScreenOff", null)
                    }
                }
            }

            override fun onActivityResumed(activity: android.app.Activity) {
                // Called when the activity comes to the foreground
                if (activity === this@MainActivity) {
                    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("onAppResumed", null)
                }
            }

            // Other lifecycle callbacks can remain empty if not used
            override fun onActivityCreated(activity: android.app.Activity, savedInstanceState: Bundle?) {}
            override fun onActivityStarted(activity: android.app.Activity) {}
            override fun onActivityStopped(activity: android.app.Activity) {}
            override fun onActivitySaveInstanceState(activity: android.app.Activity, outState: Bundle) {}
            override fun onActivityDestroyed(activity: android.app.Activity) {}
        })
    }
}
