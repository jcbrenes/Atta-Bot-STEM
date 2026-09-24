import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AppInfo {
  final String versionName;
  final int versionCode;
  final bool deviceOwner;
  final bool kiosk;

  AppInfo(this.versionName, this.versionCode, this.deviceOwner, this.kiosk);
}

// Contenido de latest.json publicado junto al APK.
class UpdateManifest {
  final String versionName;
  final int versionCode;
  final Uri apkUrl;
  final String sha256;

  UpdateManifest(this.versionName, this.versionCode, this.apkUrl, this.sha256);
}

// Puente con MainActivity.kt: kiosko, versión e instalación verificada.
class AdminService {
  static const _channel = MethodChannel('atta/admin');
  static final _installStatus = StreamController<String>.broadcast();
  static bool _listening = false;

  AdminService() {
    if (_listening) return;
    _listening = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'installStatus') {
        _installStatus.add('${call.arguments['mensaje']}');
      }
    });
  }

  // Mensajes de la sesión de instalación (error o confirmación pendiente).
  Stream<String> get installStatus => _installStatus.stream;

  Future<AppInfo> info() async {
    final m = await _channel.invokeMapMethod<String, dynamic>('info') ?? {};
    return AppInfo('${m['versionName']}', (m['versionCode'] as num?)?.toInt() ?? 0,
        m['deviceOwner'] == true, m['kiosk'] == true);
  }

  Future<void> setKiosk(bool enabled) =>
      _channel.invokeMethod('setKiosk', {'enabled': enabled});

  HttpClient _client() => HttpClient()..connectionTimeout = const Duration(seconds: 8);

  Future<UpdateManifest> fetchManifest(String url) async {
    final uri = Uri.parse(url);
    if (uri.scheme != 'https') throw const FormatException('La dirección debe empezar con https://');
    final client = _client();
    try {
      final response = await (await client.getUrl(uri)).close().timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw HttpException('El servidor respondió ${response.statusCode}');
      }
      final json = jsonDecode(await response.transform(utf8.decoder).join()) as Map<String, dynamic>;
      final sha = '${json['sha256']}'.toLowerCase();
      final apk = uri.resolve('${json['apk']}');
      if (json['versionCode'] is! int || !RegExp(r'^[0-9a-f]{64}$').hasMatch(sha) || apk.scheme != 'https') {
        throw const FormatException('latest.json incompleto o inválido');
      }
      return UpdateManifest('${json['versionName']}', json['versionCode'] as int, apk, sha);
    } finally {
      client.close();
    }
  }

  // Descarga a la caché de la app; `progress` recibe 0..1 (o null si no se conoce el tamaño).
  Future<File> download(UpdateManifest m, void Function(double?) progress) async {
    final file = File('${(await getTemporaryDirectory()).path}/actualizacion.apk');
    final client = _client();
    try {
      final response = await (await client.getUrl(m.apkUrl)).close();
      if (response.statusCode != 200) {
        throw HttpException('Descarga fallida (${response.statusCode})');
      }
      final total = response.contentLength;
      var received = 0;
      final sink = file.openWrite();
      try {
        await for (final chunk in response) {
          sink.add(chunk);
          received += chunk.length;
          progress(total > 0 ? received / total : null);
        }
      } finally {
        await sink.close();
      }
      return file;
    } finally {
      client.close();
    }
  }

  // null si Android aceptó la instalación; si no, el motivo del rechazo.
  Future<String?> install(File apk, String sha256) =>
      _channel.invokeMethod<String>('installApk', {'path': apk.path, 'sha256': sha256});
}
