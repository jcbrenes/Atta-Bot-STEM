package com.example.proyecto_tec

import android.app.ActivityManager
import android.app.admin.DevicePolicyManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    companion object {
        var kioskEnabled = true
        private var adminChannel: MethodChannel? = null

        fun reportInstallStatus(estado: String, mensaje: String) {
            Handler(Looper.getMainLooper()).post {
                adminChannel?.invokeMethod("installStatus", mapOf("estado" to estado, "mensaje" to mensaje))
            }
        }
    }

    private val exitReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            setKiosk(false)
        }
    }

    // Batería de la tableta: en kiosko la barra de estado queda vacía, así que la app muestra el porcentaje.
    private val batteryReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) = sendBattery(intent)
    }

    private fun sendBattery(intent: Intent?) {
        val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, 100) ?: 100
        val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        if (level < 0 || scale <= 0) return
        adminChannel?.invokeMethod("battery", mapOf(
            "percent" to level * 100 / scale,
            "charging" to (status == BatteryManager.BATTERY_STATUS_CHARGING ||
                status == BatteryManager.BATTERY_STATUS_FULL),
            // Fuera del kiosko Android ya muestra la batería en la barra.
            "kiosk" to kioskEnabled,
        ))
    }

    private fun dpm() = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
    private fun admin() = ComponentName(this, DeviceAdminReceiver::class.java)
    private fun lockTaskState() = (getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager).lockTaskModeState

    private fun setKiosk(enabled: Boolean) {
        kioskEnabled = enabled
        if (dpm().isDeviceOwnerApp(packageName)) {
            dpm().setLockTaskPackages(admin(), if (enabled) arrayOf(packageName) else arrayOf())
        }
        if (enabled && lockTaskState() == ActivityManager.LOCK_TASK_MODE_NONE) startLockTask()
        if (!enabled && lockTaskState() != ActivityManager.LOCK_TASK_MODE_NONE) stopLockTask()
        sendBattery(registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED)))
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        adminChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "atta/admin").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "info" -> {
                        val info = packageManager.getPackageInfo(packageName, 0)
                        result.success(mapOf(
                            "versionName" to info.versionName,
                            "versionCode" to info.longVersionCode,
                            "deviceOwner" to dpm().isDeviceOwnerApp(packageName),
                            "kiosk" to (lockTaskState() != ActivityManager.LOCK_TASK_MODE_NONE),
                        ))
                    }
                    "battery" -> {
                        sendBattery(registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED)))
                        result.success(null)
                    }
                    "setKiosk" -> {
                        setKiosk(call.argument<Boolean>("enabled") == true)
                        result.success(null)
                    }
                    "installApk" -> {
                        val path = call.argument<String>("path") ?: ""
                        val sha = call.argument<String>("sha256") ?: ""
                        // Copia y verificación fuera del hilo de la interfaz.
                        Thread {
                            val error = try {
                                UpdateInstaller.install(applicationContext, path, sha)
                            } catch (e: Exception) {
                                e.message ?: e.toString()
                            }
                            Handler(Looper.getMainLooper()).post { result.success(error) }
                        }.start()
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        registerReceiver(
            exitReceiver,
            IntentFilter("com.example.proyecto_tec.EXIT_KIOSK"),
            Context.RECEIVER_EXPORTED
        )
        if (kioskEnabled) setKiosk(true)
        // Es un aviso persistente: al registrarlo llega de inmediato el estado actual.
        registerReceiver(batteryReceiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
    }

    override fun onPause() {
        super.onPause()
        unregisterReceiver(exitReceiver)
        unregisterReceiver(batteryReceiver)
    }
}
