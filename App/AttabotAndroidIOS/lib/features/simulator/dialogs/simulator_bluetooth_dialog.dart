import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';

class SimulatorBluetoothDialog {
  static void show(BuildContext context) {
    final navService = DependencyManager().getNavigationService();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '¿Que prefieres?',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: neutralWhite,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Poppins'),
          ),
          backgroundColor: neutralDarkBlueAD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: Colors.white, width: 4.0),
          ),
          actions: [
            TextButton(
              onPressed: () {
                navService.goToBluetoothDevicesPage(context);
              },
              child: const Text(
                'Ir a bluetooth',
                style: TextStyle(
                    color: neutralWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Poppins'),
              ),
            ),
            TextButton(
              onPressed: () {
                navService.goToSimulatorPage(context);
                ;
              },
              child: const Text(
                'Simular',
                style: TextStyle(
                    color: neutralWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Poppins'),
              ),
            ),
          ],
        );
      },
    );
  }
}
