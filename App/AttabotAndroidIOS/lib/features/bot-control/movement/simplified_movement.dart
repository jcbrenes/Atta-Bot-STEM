import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class SimpleConfirmDialog extends StatelessWidget {
  final String movement; // "forward", "left", "backward", "right"
  final int? value;

  const SimpleConfirmDialog({
    super.key,
    required this.movement,
    this.value,
  });

  String _getTitle() {
    switch (movement) {
      case "forward":
        return "¿Avanzar ${value} cm?";
      case "backward":
        return "¿Retroceder ${value} cm?";
      case "left":
        return "¿Girar a la izquierda ${value}°?";
      case "right":
        return "¿Girar a la derecha ${value}°?";
      default:
        return "¿Ejecutar movimiento?";
    }
  }

  void _executeMovement(BuildContext context) {
    final commandService = context.read<CommandService>();

    switch (movement) {
      case "forward":
        commandService.moveForward(value ?? 10);
        break;
      case "backward":
        commandService.moveBackward(value ?? 10);
        break;
      case "left":
        commandService.rotateLeft(value ?? 90);
        break;
      case "right":
        commandService.rotateRight(value ?? 90);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      buttonPadding: const EdgeInsets.all(20.0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 20, 30, 10),
      contentPadding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
      title: Text(
        _getTitle(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 28,
          fontFamily: "Poppins",
          color: neutralWhite,
        ),
      ),
      backgroundColor: neutralDarkBlueAD,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: const BorderSide(color: neutralWhite, width: 4.0),
      ),
      content: const SizedBox(
        width: 500, 
      ),
      actions: [
        TextButton(
          child: const Text("Cancelar",
              style: TextStyle(
                  fontSize: 14, fontFamily: "Poppins", color: neutralWhite)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text("Aceptar",
              style: TextStyle(
                  fontSize: 14, fontFamily: "Poppins", color: neutralWhite)),
          onPressed: () {
            _executeMovement(context);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}