import 'package:flutter/material.dart';
import 'package:proyecto_tec/pages/bluetooth_devices_page.dart';
import 'package:proyecto_tec/pages/simulator_page.dart';

class NavigationService {
  void goToBluetoothDevicesPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const BluetoothDevicesPage()),
    );
  }

  void goToSimulatorPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SimulatorPage()),
    );
  }

  void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}
