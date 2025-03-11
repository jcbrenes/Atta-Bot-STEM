import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/components/instruction_tile.dart';
import 'package:proyecto_tec/features/commands/components/history_dropdown_menu.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/text/button_factory.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final Text pageTitle = const Text(
    'Instrucciones',
    textAlign: TextAlign.left,
    style: TextStyle(
      fontWeight: FontWeight.w700,
      color: neutralWhite,
      fontSize: 18,
    ),
  );

  final Map<String, Color> appbarColors = {
    'foreground': neutralWhite,
    'background': Colors.transparent,
  };

  final BoxDecoration bodyDecoration = BoxDecoration(
    color: neutralDarkBlue,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white,
      width: 3,
    ),
  );

  final Map<String, Color> stateInstructions = {
    'Ciclo': secondaryGreen,
    'Detección': primaryYellow,
    'Lápiz': secondaryPurple,
  };

  final Map<String, Color> movementInstructions = {
    'Avanzar': primaryBlue,
    'Retroceder': primaryBlue,
    'Girar': primaryOrange,
  };

  final Map<String, double> paddingInstructions = {
    'Ciclo abierto': 20,
    'Ciclo cerrado': -20,
    'Detección iniciada': 20,
    'Detección finalizada': -20,
    'Lápiz activado': 20,
    'Lápiz desactivado': -20,
  };

  double tilePadding = 10;

  AnimatedBuilder reorderingAnimation(child, index, animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(
          elevation: 0,
          color: Colors.transparent,
          child: child,
        );
      },
      child: child,
    );
  }

  Color processInstruction(String instruction) {
    List<String> instructionParts;
    instructionParts = instruction.split(' ');

    Color? color = movementInstructions[instructionParts.first];
    if (color != null) return color;
    return stateInstructions[instructionParts.first] ?? Colors.white;
  }

  double processPadding(String instruction) {
    double preSum;
    String shortInstructions = instruction.split(' ').take(2).join(' ');
    if (paddingInstructions[shortInstructions] != null) {
      preSum = tilePadding;
      tilePadding += paddingInstructions[shortInstructions]!;
      if (paddingInstructions[shortInstructions]! < 0) {
        return tilePadding;
      }
      return preSum;
    }
    return tilePadding;
  }

  Widget? setTrailing(String instruction, index) {
    if (instruction.contains('Fin del ciclo')) return null;

    return Container(
      height: 20,
      child: IconButton(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          icon: Icon(
            Icons.delete,
            color: Colors.grey[400],
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirmación'),
                  content: const Text(
                      '¿Estás seguro de que quieres eliminar este elemento?'),
                  actions: <Widget>[
                    TextButtonFactory.getButton(
                        type: TextButtonType.text,
                        text: "Cancelar",
                        handleButtonPress: () => Navigator.of(context).pop()),
                    TextButtonFactory.getButton(
                      type: TextButtonType.warning,
                      text: "Eliminar",
                      handleButtonPress: () {
                        context.read<CommandService>().removeCommand(index);
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              },
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neutralDarkBlue,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
        child: Container(
          decoration: bodyDecoration,
          child: Consumer<CommandService>(
            builder: (context, historial, child) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        pageTitle,
                        const Spacer(),
                        InstructionHistoryDropdown(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: RawScrollbar(
                        thumbVisibility: true,
                        thumbColor: neutralWhite,
                        radius: const Radius.circular(6),
                        thickness: 7,
                        trackVisibility: true,
                        trackColor: neutralWhite.withOpacity(.3),
                        trackRadius: const Radius.circular(6),
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: ListView.builder(
                          itemCount: historial.commandHistory.length,
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          itemBuilder: (context, index) {
                            return InstructionTile(
                              key: ValueKey(historial.commandHistory[index]),
                              color: processInstruction(
                                historial.commandHistory[index].toUiString(),
                              ),
                              tilePadding: processPadding((historial
                                  .commandHistory[index]
                                  .toUiString())),
                              title:
                                  historial.commandHistory[index].toUiString(),
                              trailing: setTrailing(
                                historial.commandHistory[index].toUiString(),
                                index,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
