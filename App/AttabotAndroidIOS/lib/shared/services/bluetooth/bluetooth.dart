// import 'dart:async';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:proyecto_tec/shared/interfaces/bluetooth/bluetooth_service_interface.dart';

class FlutterBluePlusService implements BluetoothServiceInterface {
  static final FlutterBluePlusService _instance =
      FlutterBluePlusService._internal();

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
      } else {
        // show an error to the user, etc
      }
    });

    if (Platform.isAndroid) {
      try{
        await FlutterBluePlus.turnOn();
      }
      catch(e){
        return false;
      }
    }

    subscription.cancel();
    return true;
  }
}
