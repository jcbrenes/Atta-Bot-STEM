import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/features/bot-control/actions/cycle_input.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';

class CycleDialog extends StatefulWidget {
  const CycleDialog({super.key});

  @override
  State<CycleDialog> createState() => _CycleDialogState();

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CycleDialog();
      },
    );
  }
}

class _CycleDialogState extends State<CycleDialog> {
  int cycleCount = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      buttonPadding: const EdgeInsets.all(20.0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 20, 30, 10),
      contentPadding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
      title: const Text("Repetir ciclo",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 26,
            fontFamily: "Poppins",
            color: neutralWhite,
          )),
      backgroundColor: neutralDarkBlueAD,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: const BorderSide(color: neutralWhite, width: 4.0),
      ),
      content: CycleInput(
        onCycleSelected: (value) {
          setState(() {
            cycleCount = value;
          });
        },
      ),
      actions: [
        TextButton(
          child: const Text("Aceptar",
              style: TextStyle(
                  fontSize: 14, fontFamily: "Poppins", color: neutralWhite)),
          onPressed: () {
            context.read<CommandService>().initCycle(cycleCount);
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Cancelar",
              style: TextStyle(
                  fontSize: 14, fontFamily: "Poppins", color: neutralWhite)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
