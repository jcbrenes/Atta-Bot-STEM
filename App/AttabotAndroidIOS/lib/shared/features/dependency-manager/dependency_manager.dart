import 'package:proyecto_tec/shared/interfaces/bluetooth/bluetooth_service_interface.dart';
import 'package:proyecto_tec/shared/features/bluetooth-connection/services/bluetooth/bluetooth.dart';
import 'package:proyecto_tec/shared/features/navigation/services/navigation.dart';
import 'package:proyecto_tec/shared/features/permissions/services/permission.dart';

class DependencyManager {
  
  static final DependencyManager _instance = DependencyManager._internal();
  
  factory DependencyManager() {
    return _instance;
  }
  
  DependencyManager._internal();
  
  BluetoothServiceInterface getBluetoothService() {
    return FlutterBluePlusService();
  }

  PermissionService getPermissionService() {
    return PermissionService();
  }

  NavigationService getNavigationService() {
    return NavigationService();
  }
}