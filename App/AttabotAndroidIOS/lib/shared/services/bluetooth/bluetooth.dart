// import 'dart:async';
import 'dart:async';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:proyecto_tec/shared/interfaces/bluetooth/bluetooth_service_interface.dart';

class FlutterBluePlusService implements BluetoothServiceInterface {
  static final FlutterBluePlusService _instance =
      FlutterBluePlusService._internal();

  @override
  Stream<List<BluetoothDevice>> get devices$ => FlutterBluePlus.scanResults.map((event) => event.map((e) => e.device).toList());

  factory FlutterBluePlusService() {
    return _instance;
  }

  FlutterBluePlusService._internal();

  @override
  Future<bool> initBluetooth() async {
    if (await FlutterBluePlus.isSupported == false) {
      return false;
    }

    var subscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        startDeviceScan();
      } else {
        // show an error to the user, etc
      }
    });

    if (Platform.isAndroid) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (e) {
        return false;
      }
    }

    subscription.cancel();
    return true;
  }

  @override
  Future<void> startDeviceScan() async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    await FlutterBluePlus.stopScan();
  
  }

 @override
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      print('Connected to device: ${device.platformName}');
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

}
