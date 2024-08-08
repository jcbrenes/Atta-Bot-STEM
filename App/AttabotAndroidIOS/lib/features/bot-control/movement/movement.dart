import 'package:flutter/material.dart';

class Movement extends StatelessWidget {
  const Movement({super.key, required this.direction});
  
  final String direction;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        direction == 'upward' ? 'Avanzar' : 'Retroceder', textAlign: TextAlign.center,),
      backgroundColor: const Color(
          0xFFDDE6F7), // Establecer el color de fondo del AlertDialog
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(10.0), // Ajustar la curvatura de las esquinas
        side: const BorderSide(
            color: Colors.white, width: 5.0), // Agregar borde blanco
      ),
      content: const Placeholder(),
      actions: [
        TextButton(
          child: const Text("Cancelar"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Aceptar"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    ;
  }
}
