package com.nutrix.app

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "nutrix/permissions"
    private val CAMERA_PERMISSION_REQUEST_CODE = 100

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestCameraPermission" -> {
                    requestCameraPermission(result)
                }
                "checkCameraPermission" -> {
                    val status = checkCameraPermission()
                    result.success(status)
                }
                "openAppSettings" -> {
                    val opened = openAppSettings()
                    result.success(opened)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun checkCameraPermission(): String {
        return when {
            ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED -> "granted"
            ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.CAMERA) -> "denied"
            else -> {
                val sharedPrefs = getSharedPreferences("nutrix_prefs", MODE_PRIVATE)
                val hasRequestedBefore = sharedPrefs.getBoolean("camera_permission_requested", false)
                if (hasRequestedBefore) "permanentlyDenied" else "denied"
            }
        }
    }

    private fun requestCameraPermission(result: MethodChannel.Result) {
        val sharedPrefs = getSharedPreferences("nutrix_prefs", MODE_PRIVATE)
        sharedPrefs.edit().putBoolean("camera_permission_requested", true).apply()

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
            result.success("granted")
        } else {
            pendingResult = result
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CAMERA), CAMERA_PERMISSION_REQUEST_CODE)
        }
    }

    private fun openAppSettings(): Boolean {
        return try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.fromParts("package", packageName, null)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    private var pendingResult: MethodChannel.Result? = null

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == CAMERA_PERMISSION_REQUEST_CODE) {
            val result = pendingResult
            pendingResult = null
            
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                result?.success("granted")
            } else {
                val shouldShow = ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.CAMERA)
                result?.success(if (shouldShow) "denied" else "permanentlyDenied")
            }
        }
    }
}
