package com.shiplink.app

import android.os.Build
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.common.ConnectionResult
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.ship_link/google_play_services"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPlayServices" -> {
                    val manufacturer = Build.MANUFACTURER.lowercase()
                    // Huawei/Honor devices block Google Maps rendering even when Play Services is installed
                    val blocked = manufacturer.contains("huawei") || manufacturer.contains("honor")
                    if (blocked) {
                        result.success(false)
                    } else {
                        val availability = GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(this)
                        result.success(availability == ConnectionResult.SUCCESS)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
