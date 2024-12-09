import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/bot-control/movement/distance_input.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
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
      buttonPadding: const EdgeInsets.all(20.0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 20, 30, 10),
      contentPadding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
      title: Text(widget.direction == 'forward' ? 'Avanzar' : 'Retroceder',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 24,
            fontFamily: "Poppins",
            color: neutralWhite,
          )),
      backgroundColor: neutralDarkBlueAD,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: const BorderSide(color: neutralWhite, width: 4.0),
      ),
      content: DistanceInput(
        onSetDistance: _setDistance,
      ),
      actions: [
        TextButton(
          child: const Text("Cancelar",
              style: TextStyle(
                  fontSize: 14, fontFamily: "Poppins", color: neutralWhite)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Aceptar",
              style: TextStyle(
                  fontSize: 14, fontFamily: "Poppins", color: neutralWhite)),
          onPressed: () {
            if (widget.direction == 'forward' && distance > 0) {
              context.read<CommandService>().moveForward(distance);
            } else if (widget.direction == 'backward' && distance > 0) {
              context.read<CommandService>().moveBackward(distance);
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
