import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:proyecto_tec/config/app_config.dart';
import 'package:proyecto_tec/shared/interfaces/bluetooth/bluetooth_service_interface.dart';

//TODO: Add permissions for bluetooth in ios
//https://pub.dev/packages/flutter_blue_plus#getting-started
class FlutterBluePlusService implements BluetoothServiceInterface {
  static final FlutterBluePlusService _instance =
      FlutterBluePlusService._internal();

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? writableCharacteristic;

  factory FlutterBluePlusService() {
    return _instance;
  }

  FlutterBluePlusService._internal();

  @override
  Stream<List<BluetoothDevice>> get devices$ => FlutterBluePlus.scanResults
      .map((event) => event.map((e) => e.device).toList());

  @override
  bool get isConnected => _connectedDevice != null;

  @override
  BluetoothDevice? get connectedDevice => _connectedDevice!;

  @override
  Future<bool> initBluetooth() async {
    if (await FlutterBluePlus.isSupported == false) {
      return false;
    }

    var subscription = FlutterBluePlus.adapterState
        .listen((BluetoothAdapterState state) async {
      if (state == BluetoothAdapterState.on) {
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
    await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
        withKeywords: AppConfig.bluetoothDeviceNameKeywords);
  }

  @override
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      // Connect to the device
      await device.connect();
      print('Connected to device: ${device.platformName}');
      _connectedDevice = device;

      // Discover services and characteristics
      List<BluetoothService> services = await device.discoverServices();

      // Find a writable characteristic
      for (BluetoothService service in services) {
        if(service.uuid.toString() == AppConfig.bluetoothServiceUUID){
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            if (characteristic.uuid.toString() == AppConfig.bluetoothCharacteristicUUID) {
              writableCharacteristic = characteristic;
              print('Found writable characteristic: ${characteristic.uuid}');
              break;
            }
          }
        }
        if (writableCharacteristic != null) break;
      }

      if (writableCharacteristic == null) {
        print('No writable characteristic found!');
      }
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  @override
  Future<void> sendStringToDevice(String message) async {
    if (writableCharacteristic == null) {
      print(
          'No writable characteristic available. Please connect to the device first.');
      return;
    }

    try {
      await writableCharacteristic?.write(utf8.encode(message));
      print('Sent message: $message');
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Future<void> disconnectDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      _connectedDevice = null;
      print('Disconnected from device: ${device.name}');
    } catch (e) {
      print('Error disconnecting from device: $e');
    }
  }
}
