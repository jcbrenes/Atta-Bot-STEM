import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog_for_simplified.dart';
import 'package:proyecto_tec/features/bot-control/movement/movement.dart';
import 'package:proyecto_tec/features/bot-control/movement/rotation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/components/instruction_tile.dart';
import 'package:proyecto_tec/features/commands/components/history_dropdown_menu.dart';
import 'package:proyecto_tec/features/commands/enums/command_types.dart';
import 'package:proyecto_tec/features/commands/models/command.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class HistoryPage extends StatefulWidget {
  final bool embedded;

  const HistoryPage({
    super.key,
    this.embedded = false,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ScrollController _historyScrollController = ScrollController();

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
  };

  double tilePadding = 10;

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
    final parts = instruction.split(' ');
    return movementInstructions[parts.first] ??
        stateInstructions[parts.first] ??
        Colors.white;
  }

  double processPadding(String instruction) {
    String shortInstruction = instruction.split(' ').take(2).join(' ');
    double preSum = tilePadding;
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

  Widget? setTrailing(String instruction, int index) {
    if (instruction == 'Ciclo cerrado' ||
        instruction == "Detección finalizada" ||
        instruction == "Lápiz desactivado") {
      return null;
    }

    return SizedBox(
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
                title: Text('Eliminar Instrucción', style: titleTextStyle),
                backgroundColor: neutralDarkBlueAD,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  side: const BorderSide(color: neutralWhite, width: 4.0),
                ),
                content: Text(
                  '¿Estás seguro de que quieres eliminar esta instrucción?',
                  style: contentTextStyle,
                ),
                actions: [
                  TextButton(
                    child: Text('Cancelar', style: contentTextStyle),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: Text('Eliminar', style: contentTextStyle),
                    onPressed: () {
                      context.read<CommandService>().removeCommand(index);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  bool isValidMove(int oldIndex, int newIndex) {
    final commandService = context.read<CommandService>();
    final commands = commandService.commandHistory;
    final movingCommand = commands[oldIndex].toUiString();

    // In simplified mode, we want to prevent moving commands outside of their cycle block
    if (commandService.simplifiedMode) {
      // search for the nearest cycle block surrounding the old index
      int cycleStartIndex = commands.indexWhere(
        (c) => c.toUiString().contains('Ciclo abierto'),
      );
      int cycleEndIndex = commands.lastIndexWhere(
        (c) => c.toUiString().contains('Ciclo cerrado'),
      );

      if (cycleStartIndex != -1 && cycleEndIndex != -1) {
        if (movingCommand.contains('Ciclo abierto') ||
            movingCommand.contains('Ciclo cerrado')) {
          return false;
        }

        // don't allow moving commands outside of the cycle block
        if (newIndex <= cycleStartIndex || newIndex >= cycleEndIndex) {
          return false;
        }
      }
    }

    if (movingCommand.contains('Ciclo cerrado') ||
        movingCommand.contains('Detección finalizada') ||
        movingCommand.contains('Lápiz desactivado')) {
      String openingCommand;
      if (movingCommand.contains('Ciclo cerrado')) {
        openingCommand = 'Ciclo abierto';
      } else if (movingCommand.contains('Detección finalizada')) {
        openingCommand = 'Detección iniciada';
      } else {
        openingCommand = 'Lápiz activado';
      }

      int openingIndex = -1;
      for (int i = oldIndex - 1; i >= 0; i--) {
        if (commands[i].toUiString().contains(openingCommand)) {
          openingIndex = i;
          break;
        }
      }

      if (openingIndex != -1 && newIndex <= openingIndex) return false;
    } else if (movingCommand.contains('Ciclo abierto') ||
        movingCommand.contains('Detección iniciada') ||
        movingCommand.contains('Lápiz activado')) {
      String closingCommand;
      if (movingCommand.contains('Ciclo abierto')) {
        closingCommand = 'Ciclo cerrado';
      } else if (movingCommand.contains('Detección iniciada')) {
        closingCommand = 'Detección finalizada';
      } else {
        closingCommand = 'Lápiz desactivado';
      }

      int closingIndex = -1;
      for (int i = oldIndex + 1; i < commands.length; i++) {
        if (commands[i].toUiString().contains(closingCommand)) {
          closingIndex = i;
          break;
        }
      }
      if (closingIndex != -1 && newIndex >= closingIndex) return false;
    }
    return true;
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(
          elevation: 8.0 * animation.value,
          borderRadius: BorderRadius.circular(15),
          color: Colors.transparent,
          shadowColor: Colors.black.withValues(alpha: 0.6),
          child: Opacity(opacity: 0.85, child: child),
        );
      },
      child: child,
    );
  }

  bool _isEditableCommand(Command command) {
    return command.action == CommandType.moveForward ||
        command.action == CommandType.moveBackward ||
        command.action == CommandType.rotateLeft ||
        command.action == CommandType.rotateRight;
  }

  void _editCommand(int index, Command command) {
    if (!_isEditableCommand(command)) return;

    if (command.action == CommandType.moveForward ||
        command.action == CommandType.moveBackward) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return Movement(
            direction: command.action == CommandType.moveForward
                ? 'forward'
                : 'backward',
            initialDistance: command.value?.toInt() ?? 0,
            onConfirm: (value) {
              context
                  .read<CommandService>()
                  .updateCommand(index, Command(command.action, value));
            },
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Rotation(
          direction:
              command.action == CommandType.rotateRight ? 'right' : 'left',
          initialAngle: command.value?.toInt() ?? 0,
          onConfirm: (value) {
            context
                .read<CommandService>()
                .updateCommand(index, Command(command.action, value));
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _historyScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool simplifiedMode = context.watch<CommandService>().simplifiedMode;
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTabletPortrait = !isLandscape && screenWidth >= 600;
    Widget pageBody = SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Container(
          width: double.infinity,
          decoration: bodyDecoration,
          child: Column(
            children: [
              Expanded(
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
                              const InstructionHistoryDropdown(),
                            ],
                          ),
                        ),
                        Expanded(
                          child: historial.commandHistory.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/surprised face.png',
                                        width: 90,
                                        height: 90,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Aún no se han agregado instrucciones...',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.3),
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : RawScrollbar(
                                  trackVisibility: true,
                                  thumbVisibility: true,
                                  controller: _historyScrollController,
                                  interactive: true,
                                  thickness: 16.0,
                                  radius: const Radius.circular(10),
                                  thumbColor: neutralWhite,
                                  trackColor:
                                      neutralWhite.withValues(alpha: 0.2),
                                  trackRadius: const Radius.circular(10),
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    0,
                                    20,
                                    0,
                                  ),
                                  child: ReorderableListView(
                                    scrollController: _historyScrollController,
                                    proxyDecorator: _proxyDecorator,
                                    buildDefaultDragHandles: false,
                                    onReorder: (oldIndex, newIndex) {
                                      if (oldIndex < newIndex) {
                                        newIndex -= 1;
                                      }
                                      final commandService =
                                          context.read<CommandService>();
                                      if (isValidMove(oldIndex, newIndex)) {
                                        setState(() {
                                          commandService.reorderCommand(
                                            oldIndex,
                                            newIndex,
                                          );
                                        });
                                        tilePadding = 10;
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            duration: Durations.extralong4,
                                            content: Center(
                                              child: Text(
                                                'Movimiento no válido',
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    children: List.generate(
                                      historial.commandHistory.length,
                                      (index) => InstructionTile(
                                        key: ValueKey('instruction_$index'),
                                        color: processInstruction(
                                          historial.commandHistory[index]
                                              .toUiString(),
                                        ),
                                        tilePadding: processPadding(
                                          historial.commandHistory[index]
                                              .toUiString(),
                                        ),
                                        title: historial.commandHistory[index]
                                            .toUiString(),
                                        trailing: setTrailing(
                                          historial.commandHistory[index]
                                              .toUiString(),
                                          index,
                                        ),
                                        onTap: !simplifiedMode &&
                                                _isEditableCommand(
                                                  historial
                                                      .commandHistory[index],
                                                )
                                            ? () => _editCommand(
                                                  index,
                                                  historial
                                                      .commandHistory[index],
                                                )
                                            : null,
                                        index: index,
                                      ),
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
            ],
          ),
        ),
      ),
    );

    if (widget.embedded) {
      return pageBody;
    }

    return Scaffold(
      backgroundColor: neutralDarkBlue,
      appBar: AppBar(
        title: const Text('Atta-Bot Educativo'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: neutralWhite,
          fontSize: 18.0,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: isLandscape
            ? []
            : [
                IconButton(
                  splashRadius: isTabletPortrait ? 30 : null,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTabletPortrait ? 14 : 8,
                  ),
                  icon: Image.asset(
                    'assets/button_icons/question_mark.png',
                    color: neutralWhite,
                    height: isTabletPortrait ? 24 : 16,
                    width: isTabletPortrait ? 24 : 16,
                  ),
                  onPressed: () {
                    if (simplifiedMode) {
                      HelpDialogForSimplifiedMode.show(context);
                    } else {
                      HelpDialog.show(context);
                    }
                  },
                ),
              ],
      ),
      body: pageBody,
    );
  }
}
