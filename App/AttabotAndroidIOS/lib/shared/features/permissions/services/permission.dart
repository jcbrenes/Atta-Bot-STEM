import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();

  factory PermissionService() {
    return _instance;
  }

  PermissionService._internal();

  Future<void> requestPermissions() async {
    
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    debugPrint(statuses.toString());
  }
}
