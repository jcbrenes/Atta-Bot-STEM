import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog_for_simplified.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/components/instruction_tile.dart';
import 'package:proyecto_tec/features/commands/components/history_dropdown_menu.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/switch_button.dart';
import 'package:proyecto_tec/pages/bot_control_page.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/default_movement_dialog.dart';
import 'package:proyecto_tec/features/commands/components/save_instructions_dialog.dart';

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
          }),
    );
  }

  bool isValidMove(int oldIndex, int newIndex) {
    final commandService = context.read<CommandService>();
    final commands = commandService.commandHistory;
    final movingCommand = commands[oldIndex].toUiString();

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
          shadowColor: Colors.black.withOpacity(0.6),
          child: Opacity(opacity: 0.85, child: child),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final simplifiedProvider = Provider.of<SimplifiedModeProvider>(context);
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      backgroundColor: neutralDarkBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: isLandscape ? 0 : 120,
        automaticallyImplyLeading: false,
        actions: isLandscape
            ? []
            : [
                IconButton(
                  icon: Image.asset(
                    'assets/button_icons/question_mark.png',
                    color: neutralWhite,
                    height: 16,
                    width: 16,
                  ),
                  onPressed: () {
                    if (simplifiedProvider.simplifiedMode) {
                      HelpDialogForSimplifiedMode.show(context);
                    } else {
                      HelpDialog.show(context);
                    }
                  },
                ),
                const SizedBox(width: 8),
              ],
        flexibleSpace: isLandscape
            ? null
            : SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Atta-Bot Educativo',
                      style: TextStyle(
                        color: neutralWhite,
                        fontSize: 18.0,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (ctx, constraints) {
                        final double w = MediaQuery.of(ctx).size.width;
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: (w * 0.8).clamp(300.0, 540.0),
                            minWidth: 260,
                          ),
                          child: ModeSwitch(
                            isSimplified: simplifiedProvider.simplifiedMode,
                            onChanged: (bool value) async {
                              if (value == simplifiedProvider.simplifiedMode){
                                return;
                              }
                              if (value) {
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return DefaultMovementDialog(
                                      initialDistance:
                                          simplifiedProvider.defaultDistance,
                                      initialAngle:
                                          simplifiedProvider.defaultAngle,
                                      initialCycle:
                                          simplifiedProvider.defaultCycle,
                                      onSetDefaults:
                                          (newDistance, newAngle, newCycle) {
                                        simplifiedProvider.setDefaults(
                                          newDistance,
                                          newAngle,
                                          newCycle,
                                        );
                                      },
                                    );
                                  },
                                );
                              } else {
                                await SaveInstructionsDialog.showMenuForContext(
                                    context);
                              }
                              simplifiedProvider.setSimplifiedMode(value);
                            },
                            height: 32,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
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
                    child: RawScrollbar(
                      trackVisibility: true,
                      thumbVisibility: true,
                      controller: ScrollController(),
                      interactive: true,
                      radius: const Radius.circular(10),
                      thumbColor: neutralWhite,
                      trackColor: neutralWhite.withOpacity(0.2),
                      trackRadius: const Radius.circular(10),
                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: historial.commandHistory.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/surprised face.png',
                                    width: 90,
                                    height: 90,
                                    //color: Colors.white.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Aún no se han agregado instrucciones...',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.3),
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ReorderableListView(
                              proxyDecorator: _proxyDecorator,
                              buildDefaultDragHandles: false,
                              onReorder: (oldIndex, newIndex) {
                                if (oldIndex < newIndex) newIndex -= 1;
                                final commandService =
                                    context.read<CommandService>();
                                if (isValidMove(oldIndex, newIndex)) {
                                  setState(() {
                                    commandService.reorderCommand(
                                        oldIndex, newIndex);
                                  });
                                  tilePadding = 10;
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      duration: Durations.extralong4,
                                      content: Center(
                                          child: Text('Movimiento no válido')),
                                    ),
                                  );
                                }
                              },
                              children: List.generate(
                                historial.commandHistory.length,
                                (index) => InstructionTile(
                                  key: ValueKey('instruction_$index'),
                                  color: processInstruction(historial
                                      .commandHistory[index]
                                      .toUiString()),
                                  tilePadding: processPadding(historial
                                      .commandHistory[index]
                                      .toUiString()),
                                  title: historial.commandHistory[index]
                                      .toUiString(),
                                  trailing: setTrailing(
                                      historial.commandHistory[index]
                                          .toUiString(),
                                      index),
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
      ),
    );
  }
}
