import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/features/file-management/services/file_management_service.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class SaveInstructionsDialog {
  static Future<void> showMenuForContext(BuildContext context) async {
    final FileManagementService fmService = FileManagementService();

    final TextStyle contentTextStyle = const TextStyle(
      fontFamily: 'Poppins',
      color: neutralWhite,
      fontSize: 14,
    );
    final TextStyle titleTextStyle = const TextStyle(
      fontFamily: 'Poppins',
      color: neutralWhite,
      fontSize: 28,
      fontWeight: FontWeight.w500,
    );

    final GlobalKey<FormState> fileNameKey = GlobalKey<FormState>();
    final TextEditingController fileNameController = TextEditingController();

    Future<void> showSnackBar(String message) async {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Future<void> openOverwriteFileDialog(String fileName) async {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            'Sobrescribir Instrucciones',
            style: contentTextStyle,
          ),
          backgroundColor: neutralDarkBlueAD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
            side: const BorderSide(color: neutralWhite, width: 4.0),
          ),
          content: Text(
            'El archivo ya existe, ¿deseas sobrescribirlo?',
            style: contentTextStyle,
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: neutralWhite,
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text(
                'Guardar',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: neutralWhite,
                ),
              ),
              onPressed: () async {
                final fileData = context
                    .read<CommandService>()
                    .commandHistory
                    .map((e) => e.toBotString())
                    .toList();
                try {
                  await fmService.overwriteFile(fileName, fileData);
                  if (!context.mounted) return;
                  Navigator.of(ctx).pop();
                  await showSnackBar('Archivo sobrescrito');
                } catch (_) {
                  if (!context.mounted) return;
                  Navigator.of(ctx).pop();
                  await showSnackBar('Error al sobrescribir archivo');
                }
              },
            ),
          ],
        ),
      );
    }

    Future<void> openSaveFileDialog() async {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            'Guardar Instrucciones',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: neutralWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: neutralDarkBlueAD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
            side: const BorderSide(color: neutralWhite, width: 4.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: fileNameKey,
                child: TextFormField(
                  controller: fileNameController,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: neutralWhite),
                    ),
                    label: Text('Nombre del archivo', style: contentTextStyle),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: neutralWhite,
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text(
                'Guardar',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: neutralWhite,
                ),
              ),
              onPressed: () async {
                if (!fileNameKey.currentState!.validate()) return;
                final fileName = fileNameController.text;
                final fileData = context
                    .read<CommandService>()
                    .commandHistory
                    .map((e) => e.toBotString())
                    .toList();
                try {
                  await fmService.saveNewFile(fileName, fileData);
                  if (!context.mounted) return;
                  Navigator.of(ctx).pop();
                  fileNameController.clear();
                  await showSnackBar('Archivo guardado');
                } catch (error) {
                  if (!context.mounted) return;
                  switch (error) {
                    case FileManagementErrors.fileAlreadyExists:
                      Navigator.of(ctx).pop();
                      await openOverwriteFileDialog(fileNameController.text);
                      break;
                    case FileManagementErrors.saveDataEmpty:
                      Navigator.of(ctx).pop();
                      await showSnackBar('No hay instrucciones para guardar');
                      break;
                    default:
                      Navigator.of(ctx).pop();
                      await showSnackBar('Error al guardar archivo');
                      break;
                  }
                }
              },
            ),
          ],
        ),
      );
    }

    Future<void> openClearInstructionsDialog() async {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            'Borrar Instrucciones',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: neutralWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: neutralDarkBlueAD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
            side: const BorderSide(color: neutralWhite, width: 4.0),
          ),
          content: Text(
            '¿Estás seguro de que deseas borrar todas las instrucciones?',
            style: contentTextStyle,
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: neutralWhite,
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text(
                'Borrar',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: neutralWhite,
                ),
              ),
              onPressed: () {
                context.read<CommandService>().clearCommands();
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    }

    // new confirmation dialog for unsaved changes
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        buttonPadding: const EdgeInsets.all(20.0),
        actionsPadding: const EdgeInsets.fromLTRB(20, 20, 30, 10),
        contentPadding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
        backgroundColor: neutralDarkBlueAD,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: const BorderSide(color: neutralWhite, width: 4.0),
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/surprised face.png',
                width: 96,
                height: 96,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              const Text(
                'Las instrucciones no han sido guardadas,\n¿desea borrarlas?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  fontFamily: "Poppins",
                  color: neutralWhite,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Guardar',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: neutralWhite,
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await openSaveFileDialog();
            },
          ),
          TextButton(
            child: const Text(
              'Borrar',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: neutralWhite,
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await openClearInstructionsDialog();
            },
          ),
        ],
      ),
    );
  }
}
