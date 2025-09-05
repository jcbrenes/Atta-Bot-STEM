import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';

class DefaultMovementDialog extends StatefulWidget {
  final int initialDistance;
  final int initialAngle;
  final Function(int, int) onSetDefaults;

  const DefaultMovementDialog({
    super.key,
    required this.initialDistance,
    required this.initialAngle,
    required this.onSetDefaults,
  });

  @override
  State<DefaultMovementDialog> createState() => _DefaultMovementDialogState();
}

class _DefaultMovementDialogState extends State<DefaultMovementDialog> {
  late int distance;
  late int angle;

  @override
  void initState() {
    super.initState();
    distance = widget.initialDistance;
    angle = widget.initialAngle;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      buttonPadding: const EdgeInsets.all(20.0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 20, 30, 10),
      contentPadding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
      title: const Text(
        "Configurar valores por defecto",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 24,
          fontFamily: "Poppins",
          color: neutralWhite,
        ),
      ),
      backgroundColor: neutralDarkBlueAD,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: const BorderSide(color: neutralWhite, width: 4.0),
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // distance
            const Text(
              "Centímetros",
              style: TextStyle(
                fontSize: 18,
                fontFamily: "Poppins",
                color: neutralWhite,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DefaultButtonFactory.getButton(
                  color: secondaryIconBlue,
                  buttonType: ButtonType.secondaryIcon,
                  onPressed: () {
                    setState(() {
                      if (distance > 1) distance--;
                    });
                  },
                  icon: IconType.remove,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "$distance",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: neutralWhite,
                    ),
                  ),
                ),
                DefaultButtonFactory.getButton(
                  color: secondaryIconBlue,
                  buttonType: ButtonType.secondaryIcon,
                  onPressed: () {
                    setState(() {
                      if (distance < 999) distance++;
                    });
                  },
                  icon: IconType.add,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // angle
            const Text(
              "Grados",
              style: TextStyle(
                fontSize: 18,
                fontFamily: "Poppins",
                color: neutralWhite,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DefaultButtonFactory.getButton(
                  color: secondaryIconOrange,
                  buttonType: ButtonType.secondaryIcon,
                  onPressed: () {
                    setState(() {
                      if (angle > 1) angle--;
                    });
                  },
                  icon: IconType.remove,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "$angle°",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: neutralWhite,
                    ),
                  ),
                ),
                DefaultButtonFactory.getButton(
                  color: secondaryIconOrange,
                  buttonType: ButtonType.secondaryIcon,
                  onPressed: () {
                    setState(() {
                      if (angle < 359) angle++;
                    });
                  },
                  icon: IconType.add,
                ),
              ],
            ),
          ],
        ),
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
            widget.onSetDefaults(distance, angle);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}