import 'package:proyecto_tec/shared/interfaces/bluetooth/bluetooth_service_interface.dart';
import 'package:proyecto_tec/shared/services/bluetooth/bluetooth.dart';

class DependencyManager {
  
  static final DependencyManager _instance = DependencyManager._internal();
  
  factory DependencyManager() {
    return _instance;
  }
  
  DependencyManager._internal();
  
  BluetoothServiceInterface getBluetoothService() {
    return FlutterBluePlusService();
  }
}