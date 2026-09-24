import 'dart:async';

import 'package:flutter/material.dart';
import 'package:proyecto_tec/config/app_config.dart';
import 'package:proyecto_tec/features/admin/services/admin_service.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

// Pide el PIN y, si es correcto, abre el menú de administración.
Future<void> openAdminMenu(BuildContext context) async {
  final controller = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: neutralDarkBlueAD,
      title: const Text('Administración', style: TextStyle(color: neutralWhite)),
      content: TextField(
        controller: controller,
        autofocus: true,
        obscureText: true,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: neutralWhite),
        decoration: const InputDecoration(
          labelText: 'PIN',
          labelStyle: TextStyle(color: neutralLightBlue),
        ),
        onSubmitted: (_) => Navigator.pop(context, controller.text == AppConfig.adminPin),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text == AppConfig.adminPin),
          child: const Text('Entrar'),
        ),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPage()));
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _service = AdminService();
  final _url = TextEditingController(text: AppConfig.updateManifestUrl);
  StreamSubscription<String>? _statusSub;
  AppInfo? _info;
  UpdateManifest? _available;
  String _status = '';
  double? _progress;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _statusSub = _service.installStatus.listen((m) => setState(() {
          _status = m;
          _busy = false;
        }));
    _refresh();
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _url.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final info = await _service.info();
    if (mounted) setState(() => _info = info);
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _status = '';
      _progress = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _status = 'Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _check() => _run(() async {
        final m = await _service.fetchManifest(_url.text.trim());
        final current = _info?.versionCode ?? 0;
        setState(() {
          _available = m.versionCode > current ? m : null;
          _status = m.versionCode > current
              ? 'Disponible: ${m.versionName} (${m.versionCode})'
              : 'Ya tiene la última versión (${m.versionName})';
        });
      });

  Future<void> _update() => _run(() async {
        final m = _available!;
        final apk = await _service.download(m, (p) {
          if (mounted) setState(() => _progress = p);
        });
        setState(() => _status = 'Verificando e instalando…');
        final error = await _service.install(apk, m.sha256);
        // Si Android acepta, cerrará la app y la abrirá con la versión nueva.
        setState(() => _status = error ?? 'Instalando ${m.versionName}; la app se reiniciará.');
      });

  Future<void> _toggleKiosk() => _run(() async {
        await _service.setKiosk(!(_info?.kiosk ?? true));
        await Future.delayed(const Duration(milliseconds: 300));
        await _refresh();
      });

  @override
  Widget build(BuildContext context) {
    const text = TextStyle(color: neutralWhite, fontSize: 18, fontFamily: 'Poppins');
    final info = _info;
    return Scaffold(
      backgroundColor: neutralDarkBlue,
      appBar: AppBar(
        backgroundColor: neutralDarkBlue,
        foregroundColor: neutralWhite,
        title: const Text('Administración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            info == null
                ? 'Cargando…'
                : 'Versión instalada: ${info.versionName} (${info.versionCode})\n'
                    'Device Owner: ${info.deviceOwner ? 'sí' : 'no'} · '
                    'Kiosko: ${info.kiosk ? 'activo' : 'inactivo'}',
            style: text,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _url,
            style: const TextStyle(color: neutralWhite),
            decoration: const InputDecoration(
              labelText: 'Dirección de latest.json',
              labelStyle: TextStyle(color: neutralLightBlue),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(spacing: 12, runSpacing: 12, children: [
            ElevatedButton(onPressed: _busy ? null : _check, child: const Text('Buscar actualización')),
            ElevatedButton(
              onPressed: _busy || _available == null ? null : _update,
              child: Text(_available == null ? 'Actualizar' : 'Actualizar a ${_available!.versionName}'),
            ),
            OutlinedButton(
              onPressed: _busy || info == null ? null : _toggleKiosk,
              child: Text(info?.kiosk == true ? 'Salir del modo kiosko' : 'Activar modo kiosko',
                  style: const TextStyle(color: neutralWhite)),
            ),
          ]),
          const SizedBox(height: 24),
          if (_busy) LinearProgressIndicator(value: _progress),
          const SizedBox(height: 12),
          Text(_status, style: text),
        ],
      ),
    );
  }
}
