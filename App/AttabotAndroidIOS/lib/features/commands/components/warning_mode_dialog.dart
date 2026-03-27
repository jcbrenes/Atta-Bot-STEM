import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class WarningModeDialog {
  static Future<bool> show(BuildContext context,
      {bool useRootNavigator = true}) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: useRootNavigator,
      builder: (ctx) => AlertDialog(
        buttonPadding: const EdgeInsets.all(20.0),
        actionsPadding: const EdgeInsets.fromLTRB(20, 20, 30, 10),
        contentPadding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
        backgroundColor: neutralDarkBlueAD,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: const BorderSide(color: neutralWhite, width: 4.0),
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/surprised face.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Al cambiar los parámetros o el modo,\nse borrarán las instrucciones\nsi aún no las ha guardado.\n¿Desea continuar?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    color: neutralWhite,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: neutralWhite,
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text(
              'Continuar',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: neutralWhite,
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }
}
