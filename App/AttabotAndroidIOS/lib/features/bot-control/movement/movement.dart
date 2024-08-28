import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/bot-control/movement/distance_input.dart';

class Movement extends StatefulWidget {
  final String direction;
  final Function(String, int) onMove;

  const Movement({super.key, required this.direction, required this.onMove});

  @override
  State<Movement> createState() => _MovementState();
}

class _MovementState extends State<Movement> {

  int selectedDistance = 0;

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: Text(
        widget.direction == 'upward' ? 'Avanzar' : 'Retroceder',
        textAlign: TextAlign.center,
      ),
      backgroundColor: const Color(
          0xFFDDE6F7), // Establecer el color de fondo del AlertDialog
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(10.0), // Ajustar la curvatura de las esquinas
        side: const BorderSide(
            color: Colors.white, width: 5.0), // Agregar borde blanco
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),
          DistanceInput(
            onDistanceSelected: (value) {
              setState(() {
                selectedDistance = value;
              });
            },
          )
        ],
      ),
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
            print("$selectedDistance aceptado");
            widget.onMove(widget.direction, selectedDistance);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
