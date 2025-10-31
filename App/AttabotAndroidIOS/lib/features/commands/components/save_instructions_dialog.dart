import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/features/file-management/services/file_management_service.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class SaveInstructionsDialog {
  static Future<void> showMenuForContext(BuildContext context) async {
    final FileManagementService fmService = FileManagementService();

    const TextStyle contentTextStyle = TextStyle(
      fontFamily: 'Poppins',
      color: neutralWhite,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
    const TextStyle titleTextStyle = TextStyle(
      fontFamily: 'Poppins',
      color: neutralWhite,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    );
    const TextStyle subtitleTextStyle = TextStyle(
      fontFamily: 'Poppins',
      color: neutralWhite,
      fontSize: 8,
      fontWeight: FontWeight.w500,
    );

    Future<void> Function()? reopenSaveDialog;

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
          title: const Text('Sobrescribir Instrucciones', style: titleTextStyle),
          backgroundColor: neutralDarkBlueAD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
            side: const BorderSide(color: neutralWhite, width: 4.0),
          ),
          content: const Text('El archivo ya existe, ¿deseas sobrescribirlo?', style: contentTextStyle),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: contentTextStyle),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text('Guardar', style: contentTextStyle),
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

    Future<void> openInvalidFileNameDialog() async {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Guardar Instrucciones', style: titleTextStyle),
          backgroundColor: neutralDarkBlueAD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
            side: const BorderSide(color: neutralWhite, width: 4.0),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('El nombre de archivo es inválido.', style: contentTextStyle),
              SizedBox(height: 12),
              Text('Utilice únicamente letras, números y guión bajo.', style: subtitleTextStyle),
              SizedBox(height: 4),
              Text('* No se aceptan caracteres especiales, ni espacios.', style: subtitleTextStyle),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Reintentar', style: contentTextStyle),
              onPressed: () async {
                Navigator.of(ctx).pop();
                if (reopenSaveDialog != null) {
                  await Future.delayed(const Duration(milliseconds: 50));
                  await reopenSaveDialog.call();
                }
              },
            ),
          ],
        ),
      );
    }

    Future<void> openSaveSuccessDialog(String fileName) async {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Guardar Instrucciones', style: titleTextStyle),
          backgroundColor: neutralDarkBlueAD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
            side: const BorderSide(color: neutralWhite, width: 4.0),
          ),
          content: Text('El archivo “$fileName” ha sido guardado exitosamente.', style: contentTextStyle),
          actions: [
            TextButton(
              child: const Text('Continuar', style: contentTextStyle),
              onPressed: () => Navigator.of(ctx).pop(),
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
          title: const Text('Guardar Instrucciones', style: titleTextStyle),
          backgroundColor: neutralDarkBlueAD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
            side: const BorderSide(color: neutralWhite, width: 4.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Utilice únicamente letras, números y guión bajo.', style: subtitleTextStyle),
                    SizedBox(height: 4),
                    Text('* No se aceptan caracteres especiales, ni espacios.', style: subtitleTextStyle),
                    SizedBox(height: 16),
                  ],
                ),
              ),
              Form(
                key: fileNameKey,
                child: TextFormField(
                  controller: fileNameController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: neutralWhite),
                    ),
                    hintText: '*Ingresese el nombre para el archivo',
                    hintStyle: contentTextStyle,
                  ),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return 'Campo requerido';
                    final reg = RegExp(r'^[A-Za-z0-9_]+$');
                    if (!reg.hasMatch(v)) return '';
                    return null;
                  },
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: contentTextStyle),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text('Guardar', style: contentTextStyle),
              onPressed: () async {
                final fileName = fileNameController.text.trim();
                final reg = RegExp(r'^[A-Za-z0-9_]+$');
                if (fileName.isEmpty || !reg.hasMatch(fileName)) {
                  Navigator.of(ctx).pop();
                  await openInvalidFileNameDialog();
                  return;
                }
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
                  await openSaveSuccessDialog(fileName);
                } catch (error) {
                  if (!context.mounted) return;
                  switch (error) {
                    case FileManagementErrors.fileAlreadyExists:
                      Navigator.of(ctx).pop();
                      await openOverwriteFileDialog(fileName);
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

    reopenSaveDialog = openSaveFileDialog;

    Future<void> openClearInstructionsDialog() async {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Borrar Instrucciones', style: titleTextStyle),
          backgroundColor: neutralDarkBlueAD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
            side: const BorderSide(color: neutralWhite, width: 4.0),
          ),
          content: const Text('¿Estás seguro de que deseas borrar todas las instrucciones?', style: contentTextStyle),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: contentTextStyle),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text('Borrar', style: contentTextStyle),
              onPressed: () {
                context.read<CommandService>().clearCommands();
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    }

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
