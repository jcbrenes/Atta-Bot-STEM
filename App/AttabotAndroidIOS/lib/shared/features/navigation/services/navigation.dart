import 'package:flutter/material.dart';
import 'package:proyecto_tec/pages/bluetooth_devices_page.dart';

class NavigationService {
  
  void goToBluetoothDevicesPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const BluetoothDevicesPage()),
    );
  }

  void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}
