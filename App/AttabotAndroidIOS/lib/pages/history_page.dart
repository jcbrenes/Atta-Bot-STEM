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
  // Constantes de UI para la página
  final Text pageTitle = const Text(
    'Instrucciones',
    textAlign: TextAlign.left,
    style: TextStyle(
      fontWeight: FontWeight.w700,
      color: neutralWhite,
      fontSize: 18,
    ),
  );

  final BoxDecoration bodyDecoration = BoxDecoration(
    color: neutralDarkBlue,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white,
      width: 3,
    ),
  );

  // Mapeo de instrucciones a colores para visualización
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

  // Mapeo para control de sangría en instrucciones anidadas
  final Map<String, double> paddingInstructions = {
    'Ciclo abierto': 20,
    'Ciclo cerrado': -20,
  };

  double tilePadding = 10;

  // Determina el color de la instrucción según su tipo
  Color processInstruction(String instruction) {
    final instructionParts = instruction.split(' ');
    return movementInstructions[instructionParts.first] ??
        stateInstructions[instructionParts.first] ??
        Colors.white;
  }

  // Calcula la sangría para instrucciones anidadas
  double processPadding(String instruction) {
    final shortInstruction = instruction.split(' ').take(2).join(' ');
    final preSum = tilePadding;

    if (paddingInstructions[shortInstruction] != null && tilePadding < 30) {
      tilePadding += paddingInstructions[shortInstruction]!;
    }

    if (tilePadding < 0) tilePadding = 10;

    if (shortInstruction == 'Ciclo cerrado') {
      tilePadding = 10;
      return tilePadding;
    }

    return preSum;
  }

  // Configura el botón de eliminar para instrucciones que lo permiten
  Widget? setTrailing(String instruction, int index) {
    // No mostrar botón de eliminar en instrucciones de cierre
    if (instruction == 'Ciclo cerrado' ||
        instruction == "Detección finalizada" ||
        instruction == "Lápiz desactivado") {
      return null;
    }

    return SizedBox(
      height: 20,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.delete,
          color: Colors.grey[400],
        ),
        onPressed: () => _showDeleteDialog(index),
      ),
    );
  }

  // Muestra diálogo de confirmación para eliminar instrucción
  void _showDeleteDialog(int index) {
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
  }

  // Verifica si un movimiento de reordenamiento es válido
  bool isValidMove(int oldIndex, int newIndex) {
    final commandService = context.read<CommandService>();
    final commands = commandService.commandHistory;
    final movingCommand = commands[oldIndex].toUiString();

    // Maneja instrucciones de cierre (no pueden moverse antes de su apertura)
    if (movingCommand.contains('Ciclo cerrado') ||
        movingCommand.contains('Detección finalizada') ||
        movingCommand.contains('Lápiz desactivado')) {
      final String openingCommand = _getOpeningCommand(movingCommand);

      // Busca la instrucción de apertura correspondiente
      int openingIndex = -1;
      for (int i = oldIndex - 1; i >= 0; i--) {
        if (commands[i].toUiString().contains(openingCommand)) {
          openingIndex = i;
          break;
        }
      }

      // No permitir mover después de su apertura
      if (openingIndex != -1 && newIndex <= openingIndex) {
        return false;
      }
    }
    // Maneja instrucciones de apertura (no pueden moverse después de su cierre)
    else if (movingCommand.contains('Ciclo abierto') ||
        movingCommand.contains('Detección iniciada') ||
        movingCommand.contains('Lápiz activado')) {
      final String closingCommand = _getClosingCommand(movingCommand);

      // Busca la instrucción de cierre correspondiente
      int closingIndex = -1;
      for (int i = oldIndex + 1; i < commands.length; i++) {
        if (commands[i].toUiString().contains(closingCommand)) {
          closingIndex = i;
          break;
        }
      }

      // No permitir mover antes de su cierre
      if (closingIndex != -1 && newIndex >= closingIndex) {
        return false;
      }
    }

    return true;
  }

  // Obtiene el comando de apertura correspondiente a un cierre
  String _getOpeningCommand(String closingCommand) {
    if (closingCommand.contains('Ciclo cerrado')) {
      return 'Ciclo abierto';
    } else if (closingCommand.contains('Detección finalizada')) {
      return 'Detección iniciada';
    } else {
      return 'Lápiz activado';
    }
  }

  // Obtiene el comando de cierre correspondiente a una apertura
  String _getClosingCommand(String openingCommand) {
    if (openingCommand.contains('Ciclo abierto')) {
      return 'Ciclo cerrado';
    } else if (openingCommand.contains('Detección iniciada')) {
      return 'Detección finalizada';
    } else {
      return 'Lápiz desactivado';
    }
  }

  // Decorador personalizado para elementos durante reordenamiento
  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(
          elevation: 8.0 * animation.value,
          borderRadius: BorderRadius.circular(15),
          color: Colors.transparent,
          shadowColor: Colors.black.withOpacity(0.6),
          child: Opacity(
            opacity: 0.85,
            child: child,
          ),
        );
      },
      child: child,
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
            builder: (context, historial, _) {
              return Column(
                children: [
                  // Encabezado con título y menú desplegable
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
                  // Lista reordenable de instrucciones
                  Expanded(
                    child: RawScrollbar(
                      trackVisibility: true,
                      thumbVisibility: true,
                      controller: ScrollController(),
                      interactive: true,
                      radius: const Radius.circular(10),
                      thumbColor: neutralWhite,
                      trackColor: neutralWhite.withOpacity(0.2),
                      trackRadius: const Radius.circular(10),
                      padding: const EdgeInsets.only(right: 20),
                      child: ReorderableListView(
                        proxyDecorator: _proxyDecorator,
                        buildDefaultDragHandles: false,
                        onReorder: (oldIndex, newIndex) {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }

                          final commandService = context.read<CommandService>();

                          if (isValidMove(oldIndex, newIndex)) {
                            setState(() {
                              commandService.reorderCommand(oldIndex, newIndex);
                            });
                            tilePadding = 10;
                          } else {
                            // Mensaje de error si el movimiento no es válido
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                duration: Durations.extralong4,
                                content:
                                    Center(child: Text('Movimiento no válido')),
                              ),
                            );
                          }
                        },
                        children: List.generate(
                          historial.commandHistory.length,
                          (index) {
                            final command = historial.commandHistory[index];
                            final commandString = command.toUiString();

                            return InstructionTile(
                              key: ValueKey('instruction_$index'),
                              color: processInstruction(commandString),
                              tilePadding: processPadding(commandString),
                              title: commandString,
                              trailing: setTrailing(commandString, index),
                              index: index,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
