import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/bot-control/movement/distance_input.dart';
// import provider and service commands
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';

class Movement extends StatefulWidget {
  final String direction;

  const Movement({
    super.key,
    required this.direction,
  });

  @override
  State<Movement> createState() => _MovementState();
}

class _MovementState extends State<Movement> {
  int distance = 0;

  void _setDistance(int newDistance) {
    setState(() {
      distance = newDistance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      buttonPadding: const EdgeInsets.all(0.0),
      actionsPadding: const EdgeInsets.all(0.0),
      contentPadding: const EdgeInsets.all(0.0),
      title: Text(
        widget.direction == 'forward' ? 'Avanzar' : 'Retroceder',
        textAlign: TextAlign.center,
      ),
      backgroundColor: const Color(0xFFDDE6F7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(color: Colors.white, width: 5.0),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),
          DistanceInput(
            onSetDistance: _setDistance,
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
            if (widget.direction == 'forward') {
              context.read<CommandService>().moveForward(distance);
            } else {
              context.read<CommandService>().moveBackward(distance);
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
