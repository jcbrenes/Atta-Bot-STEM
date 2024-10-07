import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BluetoothServiceInterface {
  Stream<List<BluetoothDevice>> get devices$;
  Future<bool> initBluetooth();
  Future<void> startDeviceScan();
  Future<void> connectToDevice(BluetoothDevice device);
}
