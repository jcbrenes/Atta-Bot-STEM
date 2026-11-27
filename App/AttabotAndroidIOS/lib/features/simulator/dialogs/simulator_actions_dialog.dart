import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/enums/command_types.dart';
import 'package:proyecto_tec/features/commands/models/command.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

Future<List<Command>?> showSimulatorActionsDialog(BuildContext context) {
  // Keep edits local until applied so an active run is not changed mid-program.
  final commands = List<Command>.of(
    context.read<CommandService>().commandHistory,
  );
  return showDialog<List<Command>>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
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
          height: MediaQuery.sizeOf(context).height * 0.45,
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: commands.length * 2 + 1,
            itemBuilder: (context, index) {
              final commandIndex = index ~/ 2;
              if (index.isEven) {
                return TextButton.icon(
                  key: ValueKey('insert-wait-$commandIndex'),
                  style: TextButton.styleFrom(foregroundColor: neutralWhite),
                  onPressed: () => setDialogState(() {
                    commands.insert(
                      commandIndex,
                      Command(CommandType.wait, null),
                    );
                  }),
                  icon: const Icon(Icons.timer_outlined, size: 18),
                  label: const Text('+ Esperar 5 s'),
                );
              }
              final command = commands[commandIndex];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${commandIndex + 1}. ${command.toUiString()}',
                  style: const TextStyle(color: neutralWhite, fontSize: 13),
                ),
                trailing: command.action == CommandType.wait
                    ? IconButton(
                        tooltip: 'Quitar espera',
                        color: neutralWhite,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => setDialogState(() {
                          commands.removeAt(commandIndex);
                        }),
                      )
                    : null,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child:
                const Text('Cancelar', style: TextStyle(color: neutralWhite)),
          ),
          TextButton(
            onPressed: commands.isEmpty
                ? null
                : () => Navigator.of(dialogContext).pop(commands),
            child: const Text(
              "Aplicar y reiniciar",
              style: TextStyle(
                fontSize: 14,
                fontFamily: "Poppins",
                color: neutralWhite,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
