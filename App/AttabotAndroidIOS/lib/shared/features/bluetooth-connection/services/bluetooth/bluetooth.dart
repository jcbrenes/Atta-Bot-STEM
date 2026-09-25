import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();
  int _connectionGeneration = 0;

  factory FlutterBluePlusService() {
    return _instance;
  }

  FlutterBluePlusService._internal();

  @override
  Stream<List<BluetoothDevice>> get devices$ => FlutterBluePlus.scanResults
      .map((event) => event.map((e) => e.device).toList());

  @override
  Stream<bool> get connectionStatus$ => _connectionStatusController.stream;

  @override
  bool get isConnected =>
      _connectedDevice != null && writableCharacteristic != null;

  @override
  BluetoothDevice? get connectedDevice => _connectedDevice;

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
  Future<bool> connectToDevice(BluetoothDevice device) async {
    await _clearConnection(disconnectDevice: true);
    final int connectionGeneration = ++_connectionGeneration;

    try {
      await device.connect();
      print('Connected to device: ${device.platformName}');
      _connectedDevice = device;

      _connectionSubscription = device.connectionState.listen((state) async {
        print('Connection state changed: $state');
        if (state == BluetoothConnectionState.disconnected &&
            _connectionGeneration == connectionGeneration &&
            _connectedDevice == device) {
          await _clearConnection();
          print('Device disconnected unexpectedly');
        }
      });

      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        if (service.uuid.toString() == AppConfig.bluetoothServiceUUID) {
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            if (characteristic.uuid.toString() ==
                AppConfig.bluetoothCharacteristicUUID) {
              writableCharacteristic = characteristic;
              print('Found writable characteristic: ${characteristic.uuid}');
              break;
            }
          }
        }
        if (writableCharacteristic != null) break;
      }

      if (_connectionGeneration != connectionGeneration ||
          _connectedDevice != device ||
          writableCharacteristic == null) {
        print('No writable characteristic found!');
        await _clearConnection(disconnectDevice: true);
        return false;
      }
      _connectionStatusController.add(true);
      return true;
    } catch (e) {
      print('Error connecting to device: $e');
      await _clearConnection(disconnectDevice: true);
      return false;
    }
  }

  @override
  Future<bool> sendStringToDevice(String message) async {
    if (writableCharacteristic == null) {
      debugPrint('No writable characteristic found!');
      return false;
    }

    try {
      await writableCharacteristic?.write(utf8.encode(message));
      debugPrint('Sent message: $message');
      return true;
    } catch (e) {
      debugPrint('Error sending message: $e');
      await _clearConnection(disconnectDevice: true);
      return false;
    }
  }

  @override
  Future<void> disconnectDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      await _clearConnection();
      print('Disconnected from device: ${device.name}');
    } catch (e) {
      print('Error disconnecting from device: $e');
      await _clearConnection();
    }
  }

  Future<void> _clearConnection({bool disconnectDevice = false}) async {
    final BluetoothDevice? device = _connectedDevice;
    _connectionGeneration++;
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _connectedDevice = null;
    writableCharacteristic = null;
    _connectionStatusController.add(false);

    if (disconnectDevice && device != null) {
      try {
        await device.disconnect();
      } catch (_) {
        // The native connection may already be gone.
      }
    }
  }
}
