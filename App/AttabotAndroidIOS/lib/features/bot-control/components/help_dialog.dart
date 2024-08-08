import 'package:flutter/material.dart';

class HelpDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '¿Cómo funciono?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(
              0xFFDDE6F7), // Establecer el color de fondo del AlertDialog
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                10.0), // Ajustar la curvatura de las esquinas
            side: const BorderSide(
                color: Colors.white, width: 5.0), // Agregar borde blanco
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.arrow_upward),
                title: RichText(
                  text: const TextSpan(
                    text: 'Avanzar ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF152A51)),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'una cantidad de centímetros indicada',
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF152A51)),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.arrow_downward),
                title: RichText(
                  text: const TextSpan(
                    text: 'Retroceder ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF152A51)),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'una cantidad de centímetros indicada',
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF152A51)),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.rotate_right),
                title: RichText(
                  text: const TextSpan(
                    text: 'Girar a la derecha ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF152A51)),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'una cantidad de grados indicada',
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF152A51)),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.rotate_left),
                title: RichText(
                  text: const TextSpan(
                    text: 'Girar a la izquierda ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF152A51)),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'una cantidad de grados indicada',
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF152A51)),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.remove_red_eye),
                title: RichText(
                  text: const TextSpan(
                    text: 'Activar detección de obstáculos ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF152A51)),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'hasta deseleccionar',
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF152A51)),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.autorenew),
                title: RichText(
                  text: const TextSpan(
                    text: 'Iniciar un ciclo, ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF152A51)),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'una cantidad de veces',
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF152A51)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
