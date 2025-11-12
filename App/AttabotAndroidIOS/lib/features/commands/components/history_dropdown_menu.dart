import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/models/command.dart';
import 'package:proyecto_tec/features/file-management/services/file_management_service.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog_for_simplified.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/default_movement_dialog.dart';
import 'package:proyecto_tec/pages/bot_control_page.dart'; // SimplifiedModeProvider

class InstructionHistoryDropdown extends StatefulWidget {
  const InstructionHistoryDropdown({
    super.key,
  });

  @override
  State<InstructionHistoryDropdown> createState() =>
      _InstructionHistoryDropdownState();
}

class _InstructionHistoryDropdownState
    extends State<InstructionHistoryDropdown> {
  final FileManagementService fmService = FileManagementService();

  final GlobalKey<FormState> _fileNameKey = GlobalKey<FormState>();
  final TextEditingController fileNameController = TextEditingController();

  List<PopupMenuEntry> get menuItems => [
        PopupMenuItem(
          value: 1,
          child: Text('¿Cómo funciono?', style: titleTextStyle),
        ),
        PopupMenuItem(
          value: 2,
          child: Text('Cargar Instrucciones', style: titleTextStyle),
        ),
        PopupMenuItem(
          value: 3,
          child: Text('Guardar Instrucciones', style: titleTextStyle),
        ),
        PopupMenuItem(
          value: 4,
          child: Text('Borrar Instrucciones', style: titleTextStyle),
        ),
        PopupMenuItem(
          value: 5,
          child: Text('Definir parámetros', style: titleTextStyle),
        ),
      ];

  TextStyle get contentTextStyle => const TextStyle(
        fontFamily: 'Poppins',
        color: neutralWhite,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );
  TextStyle get titleTextStyle => const TextStyle(
        fontFamily: 'Poppins',
        color: neutralWhite,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      );

  TextStyle get subtitleTextStyle => const TextStyle(
        fontFamily: 'Poppins',
        color: neutralWhite,
        fontSize: 8,
        fontWeight: FontWeight.w500,
      );

  

  Future<void> openSaveFileDialog() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Guardar Instrucciones', style: titleTextStyle),
              backgroundColor: neutralDarkBlueAD,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
                side: const BorderSide(color: neutralWhite, width: 4.0),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Utilice únicamente letras, números y guión bajo.',
                          style: subtitleTextStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '* No se aceptan caracteres especiales, ni espacios.',
                          style: subtitleTextStyle,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
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
                  child: Text("Cancelar", style: contentTextStyle),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Guardar", style: contentTextStyle),
                  onPressed: () async {
                    final name = fileNameController.text.trim();
                    final reg = RegExp(r'^[A-Za-z0-9_]+$');
                    if (name.isEmpty || !reg.hasMatch(name)) {
                      Navigator.of(context).pop();
                      await openInvalidFileNameDialog();
                      return;
                    }

                    final fileData = context
                        .read<CommandService>()
                        .commandHistory
                        .map((Command e) => e.toBotString())
                        .toList();
                    try {
                      await fmService.saveNewFile(name, fileData);
                      Navigator.of(context).pop();
                      await openSaveSuccessDialog(name);
                      fileNameController.clear();
                    } catch (error) {
                      if (!mounted) return;
                      switch (error) {
                        case FileManagementErrors.fileAlreadyExists:
                          Navigator.of(context).pop();
                          await openOverwiteFileDialog();
                          break;
                        case FileManagementErrors.saveDataEmpty:
                          showSnackBar('No hay instrucciones para guardar');
                          break;
                        default:
                          showSnackBar('Error al guardar archivo');
                          break;
                      }
                    }
                  },
                ),
              ],
            ));
  }

  Future<void> openInvalidFileNameDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Guardar Instrucciones', style: titleTextStyle),
        backgroundColor: neutralDarkBlueAD,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: const BorderSide(color: neutralWhite, width: 4.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('El nombre de archivo es inválido.', style: contentTextStyle),
            const SizedBox(height: 12),
            Text('Utilice únicamente letras, números y guión bajo.', style: subtitleTextStyle),
            const SizedBox(height: 4),
            Text('* No se aceptan caracteres especiales, ni espacios.', style: subtitleTextStyle),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Reintentar', style: contentTextStyle),
            onPressed: () async {
              Navigator.of(context).pop();
              await openSaveFileDialog();
            },
          ),
        ],
      ),
    );
  }

  Future<void> openSaveSuccessDialog(String fileName) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Guardar Instrucciones', style: titleTextStyle),
        backgroundColor: neutralDarkBlueAD,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: const BorderSide(color: neutralWhite, width: 4.0),
        ),
        content: Text('El archivo “$fileName” ha sido guardado exitosamente.', style: contentTextStyle),
        actions: [
          TextButton(
            child: Text('Continuar', style: contentTextStyle),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> openOverwiteFileDialog() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Sobrescribir Instrucciones', style: titleTextStyle),
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
                  child: Text("Cancelar", style: contentTextStyle),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Guardar", style: contentTextStyle),
                  onPressed: () {
                    onOverwriteFile();
                    Navigator.of(context).pop();
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
    if (!mounted) return;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: Text('Cargar Instrucciones', style: titleTextStyle),
            backgroundColor: neutralDarkBlueAD,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
              side: const BorderSide(color: neutralWhite, width: 4.0),
            ),
            content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: fileNames.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title:
                              Text(fileNames[index], style: contentTextStyle),
                          onTap: () {
                            onLoadFile(fileNames[index]);
                            Navigator.of(context).pop();
                          },
                        );
                      }),
                ))));
  }

  Future<void> openClearInstructionsDialog() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Borrar Instrucciones', style: titleTextStyle),
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
                child: Text("Cancelar", style: contentTextStyle),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Borrar", style: contentTextStyle),
                onPressed: () {
                  onClearInstructions();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void onSaveFile() async {
    if (!_fileNameKey.currentState!.validate()) return;
    final fileName = fileNameController.text;
    final fileData = context
        .read<CommandService>()
        .commandHistory
        .map((Command element) => element.toBotString())
        .toList();

    try {
      await fmService.saveNewFile(fileName, fileData);
    } catch (error) {
      switch (error) {
        case FileManagementErrors.fileAlreadyExists:
          await openOverwiteFileDialog();
          break;
        case FileManagementErrors.saveDataEmpty:
          showSnackBar('No hay instrucciones para guardar');
          break;
        default:
          showSnackBar('Error al guardar archivo');
          break;
      }
    }
    fileNameController.clear();
  }

  void onOverwriteFile() async {
    final fileName = fileNameController.text;
    final fileData = context
        .read<CommandService>()
        .commandHistory
        .map((Command element) => element.toBotString())
        .toList();
    try {
      await fmService.overwriteFile(fileName, fileData);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: neutralDarkBlueAD,
          content: Text(
            'Error al sobrescribir archivo',
            style: contentTextStyle,
          )));
    }
  }

  void onLoadFile(String fileName) async {
    final fileData = await fmService.loadFile(fileName);
    if (!mounted) return;
    context.read<CommandService>().loadCommands(fileData);
  }

  void onClearInstructions() {
    context.read<CommandService>().clearCommands();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: neutralWhite,
      icon: const Icon(Icons.menu_outlined),
      onPressed: () async {
        final value = await showMenu(
          context: this.context,
          position: RelativeRect.fromLTRB(
            MediaQuery.of(this.context).size.width,
            kToolbarHeight + 20,
            45,
            0.0,
          ),
          items: menuItems,
          elevation: 8.0,
          color: neutralDarkBlueAD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(
              color: neutralWhite,
              width: 4,
            ),
          ),
        );

        if (!mounted) return;

        switch (value) {
          case 1:
            final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
            final simplified = context.read<SimplifiedModeProvider>().simplifiedMode;
            if (simplified) {
              HelpDialogForSimplifiedMode.show(context, useRootNavigator: !isLandscape);
            } else {
              HelpDialog.show(context, useRootNavigator: !isLandscape);
            }
            break;
          case 2:
            openLoadFileDialog();
            break;
          case 3:
            openSaveFileDialog();
            break;
          case 4:
            openClearInstructionsDialog();
            break;
          case 5:
            final sp = context.read<SimplifiedModeProvider>();
            if (!sp.simplifiedMode) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: neutralDarkBlueAD,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Activa el modo simplificado para definir parámetros',
                          style: TextStyle(
                            color: neutralDarkBlueAD,
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: neutralGray,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: neutralWhite, width: 2),
                  ),
                  elevation: 6,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              );
              break;
            }

            final int initDistance = sp.defaultDistance;
            final int initAngle = sp.defaultAngle;
            final int initCycle = sp.defaultCycle;

            showDialog(
              context: context,
              builder: (ctx) => DefaultMovementDialog(
                initialDistance: initDistance,
                initialAngle: initAngle,
                initialCycle: initCycle,
                onSetDefaults: (newDistance, newAngle, newCycle) {
                  sp.setDefaults(newDistance, newAngle, newCycle);
                },
              ),
            );
            break;
          default:
            break;
        }
      },
    );
  }
}
