import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/config/app_config.dart';
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

  final GlobalKey<FormState> _fileNameKey = GlobalKey<FormState>();
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

  Future<void> openSaveFileDialog() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Guardar Instrucciones'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: _fileNameKey,
                    child: TextFormField(
                      controller: fileNameController,
                      decoration: const InputDecoration(
                          border: AppConfig.textFormFieldBorder,
                          label: Text("Nombre del archivo")),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                  )
                ],
              ),
              actions: [
                TextButtonFactory.getButton(
                  type: TextButtonType.outline,
                  text: "Cancelar",
                  handleButtonPress: () => Navigator.of(context).pop(),
                ),
                TextButtonFactory.getButton(
                    type: TextButtonType.filled,
                    text: "Guardar",
                    handleButtonPress: onSaveFile)
              ],
            ));
  }

  Future<void> openOverwiteFileDialog() async {
    await showDialog(
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
                  handleButtonPress: onOverwriteFile,
                )
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
            title: const Text('Cargar Instrucciones'),
            content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: fileNames.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(fileNames[index]),
                          onTap: () => onLoadFile(fileNames[index]),
                        );
                      }),
                ))));
  }

  Future<void> openClearInstructionsDialog() async {
    await showDialog(
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
                  type: TextButtonType.warning,
                  text: "Borrar",
                  handleButtonPress: onClearInstructions)
            ],
          );
        });
  }

  void onSaveFile() async {
    if (!_fileNameKey.currentState!.validate()) return;
    final fileName = fileNameController.text;
    final fileData = context.read<HistoryService>().historyValue;

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
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void onOverwriteFile() async {
    final fileName = fileNameController.text;
    final fileData = context.read<HistoryService>().historyValue;
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
  }

  void onLoadFile(String fileName) async {
    final fileData = await fmService.loadFile(fileName);
    if (!mounted) return;
    context.read<HistoryService>().loadInstructionSet(fileData);
    Navigator.of(context).pop();
  }

  void onClearInstructions() async {
    context.read<HistoryService>().clearHistory();
    Navigator.of(context).pop();
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
