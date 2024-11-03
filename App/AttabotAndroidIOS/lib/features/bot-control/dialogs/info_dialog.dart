import 'package:flutter/material.dart';
import 'package:proyecto_tec/screens/ventanaInicio.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

void showInfoDialog(BuildContext context, String message) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          buttonPadding: const EdgeInsets.all(20.0),
          actionsPadding: const EdgeInsets.fromLTRB(20, 20, 30, 10),
          contentPadding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
          title: Text(" "),
          backgroundColor: neutralDarkBlueAD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
            side: const BorderSide(color: neutralWhite, width: 4.0),
          ),
          content: SizedBox(
            height: 100,
            width: double.maxFinite,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  textAlign: TextAlign.center,
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                      fontSize: 24,
                      fontFamily: "Poppins",
                      color: neutralWhite),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Continuar",
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: "Poppins",
                      color: neutralWhite)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}
