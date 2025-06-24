import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/bot-control/actions/cycle_input.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class CycleDialog extends StatefulWidget {
  const CycleDialog({super.key});

  @override
  State<CycleDialog> createState() => _CycleDialogState();

  // Método estático para mostrar el diálogo de ciclos desde cualquier parte de la app
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const CycleDialog(),
    );
  }
}

class _CycleDialogState extends State<CycleDialog> {
  int cycleCount = 1; // Valor predeterminado para el contador de ciclos

  @override
  Widget build(BuildContext context) {
    // Estilo común para los textos de los botones
    const textStyle =
        TextStyle(fontSize: 14, fontFamily: "Poppins", color: neutralWhite);

    return AlertDialog(
      buttonPadding: const EdgeInsets.all(20.0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 20, 30, 10),
      contentPadding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
      title: const Text(
        "Repetir ciclo",
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
      // Widget personalizado para seleccionar el número de ciclos
      content: CycleInput(
        onCycleSelected: (value) {
          setState(() {
            cycleCount = value;
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancelar", style: textStyle),
        ),
        TextButton(
          onPressed: () {
            // Iniciar ciclo y cerrar el diálogo
            context.read<CommandService>().initCycle(cycleCount);
            Navigator.of(context).pop();
          },
          child: const Text("Aceptar", style: textStyle),
        ),
      ],
    );
  }
}
