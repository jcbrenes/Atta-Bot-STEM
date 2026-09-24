package com.example.proyecto_tec

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageInstaller
import android.content.pm.PackageManager
import android.os.Build
import java.io.File
import java.security.MessageDigest

// Actualización de la propia app desde un APK descargado.
// Como Device Owner, Android instala sin pedir confirmación; si no lo es,
// se muestra el diálogo normal del sistema.
object UpdateInstaller {
    // Devuelve null si inició la instalación, o el motivo del rechazo.
    fun install(context: Context, path: String, expectedSha256: String): String? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) return "Se requiere Android 9 o superior"
        val file = File(path)
        if (!file.isFile) return "No se encontró el archivo descargado"
        if (!sha256(file).equals(expectedSha256, ignoreCase = true)) return "El archivo no coincide con el sha256 publicado"

        val pm = context.packageManager
        val nuevo = pm.getPackageArchiveInfo(path, PackageManager.GET_SIGNING_CERTIFICATES)
            ?: return "El archivo no es un APK válido"
        if (nuevo.packageName != context.packageName) return "El APK es de otra aplicación (${nuevo.packageName})"
        val actual = pm.getPackageInfo(context.packageName, PackageManager.GET_SIGNING_CERTIFICATES)
        if (nuevo.longVersionCode <= actual.longVersionCode)
            return "La versión ${nuevo.versionName} no es más nueva que la instalada"
        // Otra firma haría fallar la instalación o, peor, obligaría a desinstalar y perder Device Owner.
        if (firmas(nuevo).isEmpty() || firmas(nuevo) != firmas(actual)) return "El APK está firmado con otra clave"

        val installer = pm.packageInstaller
        val params = PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL).apply {
            setAppPackageName(context.packageName)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S)
                setRequireUserAction(PackageInstaller.SessionParams.USER_ACTION_NOT_REQUIRED)
        }
        val id = installer.createSession(params)
        installer.openSession(id).use { session ->
            session.openWrite("base.apk", 0, file.length()).use { out ->
                file.inputStream().use { it.copyTo(out) }
                session.fsync(out)
            }
            val flags = PendingIntent.FLAG_UPDATE_CURRENT or
                (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0)
            val intent = Intent(context, InstallResultReceiver::class.java)
            session.commit(PendingIntent.getBroadcast(context, id, intent, flags).intentSender)
        }
        return null
    }

    private fun firmas(info: PackageInfo): Set<String> =
        info.signingInfo?.apkContentsSigners?.map { it.toCharsString() }?.toSet() ?: emptySet()

    private fun sha256(file: File): String {
        val digest = MessageDigest.getInstance("SHA-256")
        file.inputStream().use { input ->
            val buffer = ByteArray(64 * 1024)
            while (true) {
                val n = input.read(buffer)
                if (n < 0) break
                digest.update(buffer, 0, n)
            }
        }
        return digest.digest().joinToString("") { "%02x".format(it) }
    }
}

// Resultado de la sesión de instalación: se reenvía a Flutter.
class InstallResultReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val status = intent.getIntExtra(PackageInstaller.EXTRA_STATUS, PackageInstaller.STATUS_FAILURE)
        if (status == PackageInstaller.STATUS_PENDING_USER_ACTION) {
            @Suppress("DEPRECATION")
            val confirm = intent.getParcelableExtra<Intent>(Intent.EXTRA_INTENT) ?: return
            context.startActivity(confirm.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            MainActivity.reportInstallStatus("confirmar", "Toque Actualizar en el diálogo del sistema")
            return
        }
        if (status != PackageInstaller.STATUS_SUCCESS) {
            val msg = intent.getStringExtra(PackageInstaller.EXTRA_STATUS_MESSAGE) ?: "código $status"
            MainActivity.reportInstallStatus("error", msg)
        }
        // En éxito Android cierra esta versión; PackageReplacedReceiver abre la nueva.
    }
}

// Tras actualizarse, volver a abrir la app (y con ella el modo kiosko).
class PackageReplacedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_MY_PACKAGE_REPLACED) return
        context.startActivity(Intent(context, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
    }
}
