import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/models/command.dart';
import 'package:proyecto_tec/features/file-management/services/file_management_service.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

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

  final List<PopupMenuEntry> menuItems = const [
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
  ];

  TextStyle get contentTextStyle => const TextStyle(
        fontFamily: 'Poppins',
        color: neutralWhite,
        fontSize: 14,
      );
  TextStyle get titleTextStyle => const TextStyle(
        fontFamily: 'Poppins',
        color: neutralWhite,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );

  Future<void> openSaveFileDialog() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
                          value!.isEmpty ? 'Campo requerido' : null,
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
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text("Guardar",
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Poppins",
                          color: neutralWhite)),
                  onPressed: () {
                    onSaveFile();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  Future<void> openOverwiteFileDialog() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text("Guardar",
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Poppins",
                          color: neutralWhite)),
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
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Borrar",
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Poppins",
                        color: neutralWhite)),
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

        switch (value) {
          case 1:
            openSaveFileDialog();
            break;
          case 2:
            openLoadFileDialog();
            break;
          case 3:
            openClearInstructionsDialog();
            break;
          default:
            break;
        }
      },
    );
  }
}
