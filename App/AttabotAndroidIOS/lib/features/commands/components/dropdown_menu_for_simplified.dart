import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/features/file-management/services/file_management_service.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class HistoryDropdownHelper {
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
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    final GlobalKey<FormState> _fileNameKey = GlobalKey<FormState>();
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
                  "El archivo ya existe, ¿deseas sobrescribirlo?",
                  style: contentTextStyle,
                ),
                actions: [
                  TextButton(
                    child: const Text("Cancelar",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Poppins",
                            color: neutralWhite)),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  ),
                  TextButton(
                    child: const Text("Guardar",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Poppins",
                            color: neutralWhite)),
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
              ));
    }

    Future<void> openSaveFileDialog() async {
      if (!context.mounted) return;
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text(
                  'Guardar Instrucciones',
                  style: titleTextStyle,
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
                      key: _fileNameKey,
                      child: TextFormField(
                        controller: fileNameController,
                        decoration: InputDecoration(
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: neutralWhite,
                              ),
                            ),
                            label: Text(
                              "Nombre del archivo",
                              style: contentTextStyle,
                            )),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Campo requerido' : null,
                      ),
                    )
                  ],
                ),
                actions: [
                  TextButton(
                    child: const Text("Cancelar",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Poppins",
                            color: neutralWhite)),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  ),
                  TextButton(
                    child: const Text("Guardar",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Poppins",
                            color: neutralWhite)),
                    onPressed: () async {
                      if (!_fileNameKey.currentState!.validate()) return;
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
              ));
    }

    Future<void> openLoadFileDialog() async {
      List<String> fileNames;
      try {
        fileNames = await fmService.getSavedFilesList();
      } catch (e) {
        fileNames = [];
      }
      if (!context.mounted) return;
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text(
                  'Cargar Instrucciones',
                  style: titleTextStyle,
                ),
                backgroundColor: neutralDarkBlueAD,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  side: const BorderSide(color: neutralWhite, width: 4.0),
                ),
                content: SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: fileNames.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(fileNames[index], style: contentTextStyle),
                            onTap: () async {
                              final fileData = await fmService.loadFile(fileNames[index]);
                              if (!context.mounted) return;
                              context.read<CommandService>().loadCommands(fileData);
                              Navigator.of(ctx).pop();
                              await showSnackBar('Instrucciones cargadas');
                            },
                          );
                        })),
              ));
    }

    Future<void> openClearInstructionsDialog() async {
      if (!context.mounted) return;
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text(
                  'Borrar Instrucciones',
                  style: titleTextStyle,
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
                    child: const Text("Cancelar",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Poppins",
                            color: neutralWhite)),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  ),
                  TextButton(
                    child: const Text("Borrar",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Poppins",
                            color: neutralWhite)),
                    onPressed: () {
                      context.read<CommandService>().clearCommands();
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ));
    }

    final value = await showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width,
        kToolbarHeight + 20,
        45,
        0.0,
      ),
      items: const [
        PopupMenuItem(
          value: 1,
          child: Text('Guardar Instrucciones',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: neutralWhite)),
        ),
        PopupMenuItem(
          value: 2,
          child: Text('Cargar Instrucciones',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: neutralWhite)),
        ),
        PopupMenuItem(
          value: 3,
          child: Text('Borrar Instrucciones',
              style: TextStyle(
                  color: neutralWhite,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold)),
        )
      ],
      elevation: 8,
      color: neutralDarkBlueAD,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(
          color: neutralWhite,
          width: 4,
        ),
      ),
    );

    switch (value) {
      case 1:
        await openSaveFileDialog();
        break;
      case 2:
        await openLoadFileDialog();
        break;
      case 3:
        await openClearInstructionsDialog();
        break;
      default:
        break;
    }
  }
}
