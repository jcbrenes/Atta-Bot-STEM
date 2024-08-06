import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/file-management/services/file_management_service.dart';
import 'package:proyecto_tec/features/instruction-history/services/history_service.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/text/button_factory.dart';

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

  final TextEditingController fileNameController = TextEditingController();

  final List<PopupMenuEntry> menuItems = const [
    PopupMenuItem(
      value: 1,
      child: Text('Guardar Instrucciones',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
    ),
    PopupMenuItem(
      value: 2,
      child: Text('Cargar Instrucciones',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
    ),
    PopupMenuItem(
      value: 3,
      child: Text('Borrar Instrucciones',
          style: TextStyle(
              color: Colors.red,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold)),
    )
  ];

  void saveNewFile() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Guardar Instrucciones'),
              content: Column(
                children: [
                  const Text('Ingresa el nombre del archivo:'),
                  TextField(
                    controller: fileNameController,
                  )
                ],
              ),
              actions: [
                TextButtonFactory.getButton(
                  type: TextButtonType.outline,
                  text: "Cancelar",
                  handleButtonPress: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButtonFactory.getButton(
                  type: TextButtonType.filled,
                  text: "Guardar",
                  disabled: fileNameController.text.isEmpty,
                  handleButtonPress: () async {
                    final fileName = fileNameController.text;
                    final fileData =
                        context.watch<HistoryService>().historyValue;
                    try {
                      await fmService.saveNewFile(fileName, fileData);
                    } catch (e) {
                      overWriteFile();
                    }
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }

  void overWriteFile() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Sobrescribir Instrucciones'),
              content:
                  const Text("El archivo ya existe, ¿deseas sobrescribirlo?"),
              actions: [
                TextButtonFactory.getButton(
                  type: TextButtonType.outline,
                  text: "Cancelar",
                  handleButtonPress: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButtonFactory.getButton(
                  type: TextButtonType.filled,
                  text: "Aceptar",
                  handleButtonPress: () async {
                    final fileName = fileNameController.text;
                    final fileData =
                        context.watch<HistoryService>().historyValue;
                    try {
                      await fmService.overwriteFile(fileName, fileData);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('Error al sobrescribir archivo')));
                    }
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }

  Future<void> loadFile() async {
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
              title: const Text('Cargar Instrucciones'),
              content: Column(children: [
                const Text('Selecciona el archivo que deseas cargar:'),
                const SizedBox(height: 10),
                fileNames.isEmpty
                    ? const Text('No hay archivos guardados')
                    : ListView.builder(
                        itemCount: fileNames.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(fileNames[index]),
                            onTap: () async {
                              final fileData =
                                  await fmService.loadFile(fileNames[index]);
                              if (!mounted) return;
                              context
                                  .watch<HistoryService>()
                                  .loadInstructionSet(fileData);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      )
              ]),
            ));
  }

  void clearInstructionHistory() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Borrar Instrucciones'),
            content: const Text(
                '¿Estás seguro de que deseas borrar todas las instrucciones?'),
            actions: [
              TextButtonFactory.getButton(
                type: TextButtonType.outline,
                text: "Cancelar",
                handleButtonPress: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButtonFactory.getButton(
                  type: TextButtonType.filled,
                  text: "Borrar",
                  textColor: Colors.red,
                  handleButtonPress: () {
                    context.watch<HistoryService>().clearHistory();
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () async {
        final value = await showMenu(
          context: this.context,
          position: RelativeRect.fromLTRB(
            MediaQuery.of(this.context).size.width,
            kToolbarHeight,
            0.0,
            0.0,
          ),
          items: menuItems,
          elevation: 8.0,
        );

        switch (value) {
          case 1:
            saveNewFile();
            break;
          case 2:
            loadFile();
            break;
          case 3:
            clearInstructionHistory();
            break;
          default:
            break;
        }
      },
    );
  }
}
