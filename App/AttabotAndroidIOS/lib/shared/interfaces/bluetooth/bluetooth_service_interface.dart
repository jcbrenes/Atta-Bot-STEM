import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BluetoothServiceInterface {
  Stream<List<BluetoothDevice>> get devices$;
  bool get isConnected;
  BluetoothDevice? get connectedDevice;
  Future<bool> initBluetooth();
  Future<void> startDeviceScan();
  Future<void> connectToDevice(BluetoothDevice device);
  Future<void> sendStringToDevice(String message);
  Future<void> disconnectDevice(BluetoothDevice device);
}
