import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BluetoothServiceInterface {
  Stream<List<BluetoothDevice>> get devices$;
  Stream<bool> get connectionStatus$;
  bool get isConnected;
  BluetoothDevice? get connectedDevice;
  Future<bool> initBluetooth();
  Future<void> startDeviceScan();
  Future<bool> connectToDevice(BluetoothDevice device);
  Future<bool> sendStringToDevice(String message);
  Future<void> disconnectDevice(BluetoothDevice device);
}
