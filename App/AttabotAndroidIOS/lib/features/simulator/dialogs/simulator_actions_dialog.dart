import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/shared/components/ui/list/list_instructions.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

void showSimulatorActionsDialog(BuildContext context) {
  // Se obtiene la lista de instrucciones desde el CommandService.
  final commandService = Provider.of<CommandService>(context, listen: false);
  final List<String> instructions =
      commandService.commandHistory.map((cmd) => cmd.toUiString()).toList();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        buttonPadding: const EdgeInsets.all(20.0),
        actionsPadding: const EdgeInsets.fromLTRB(20, 20, 30, 10),
        contentPadding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
        title: const Text(
          "Historial de Instrucciones",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
          height: 200,
          width: double.maxFinite,
          child: InstructionsList(instructions: instructions),
        ),
        actions: [
          TextButton(
            child: const Text(
              "Continuar",
              style: TextStyle(
                fontSize: 14,
                fontFamily: "Poppins",
                color: neutralWhite,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
