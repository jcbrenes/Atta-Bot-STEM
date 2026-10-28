import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BluetoothServiceInterface {
  Stream<List<BluetoothDevice>> get devices$;
  Stream<bool> get connectionStatus$;
  bool get isConnected;
  BluetoothDevice? get connectedDevice;
  // Notifican a la UI apenas cambia la conexión (incluye desconexiones del robot).
  ValueListenable<BluetoothDevice?> get connectedDeviceListenable;
  ValueListenable<BluetoothDevice?> get connectingDeviceListenable;
  Future<bool> initBluetooth();
  Future<void> startDeviceScan();
  Future<bool> connectToDevice(BluetoothDevice device);
  Future<bool> sendStringToDevice(String message);
  Future<void> disconnectDevice(BluetoothDevice device);
}
