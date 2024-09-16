import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/bot-control/movement/distance_input.dart';

class Movement extends StatefulWidget {
  final String direction;
  final Function(String) onAddInstruction;

  const Movement({super.key, required this.direction, required this.onAddInstruction});

  @override
  State<Movement> createState() => _MovementState();
}

class _MovementState extends State<Movement> {

  int selectedDistance = 0;

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      buttonPadding: EdgeInsets.all(0.0),
      actionsPadding: EdgeInsets.all(0.0),
      contentPadding: EdgeInsets.all(0.0),
      title: Text(
        widget.direction == 'forward' ? 'Avanzar' : 'Retroceder',
        textAlign: TextAlign.center,
      ),
      backgroundColor: const Color(
          0xFFDDE6F7),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(10.0),
        side: const BorderSide(
            color: Colors.white, width: 5.0),
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
            widget.onAddInstruction(""widget.directionselectedDistance);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
