import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/pages/bot_control_page.dart';
import 'package:proyecto_tec/features/simulator/dialogs/simulator_actions_dialog.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/features/commands/models/command.dart';
import 'package:proyecto_tec/features/commands/enums/command_types.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/features/navigation/services/navigation.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/features/simulator/components/grid_simulator.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog_for_simplified.dart';

class SimulatorPage extends StatefulWidget {
  const SimulatorPage({super.key});

  @override
  State<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends State<SimulatorPage> {
  List<String> availableFiles = [
    'instrucciones1.dat',
    'instrucciones2.dat',
    'instrucciones3.dat',
  ];

  String selectedFile = 'instrucciones1.dat';
  NavigationService navService = DependencyManager().getNavigationService();
  String currentInstruction = '';
  bool isPaused = false;
  bool isExecutingInstructions = false;
  bool isExecutingCycleInstruction = false;
  int stopSignal = 0;
  int restartSignal = 0;

  void togglePause() {
    if (!isExecutingInstructions && !isPaused) return;

    setState(() {
      isPaused = !isPaused;
    });
  }

  void stopSimulation() {
    setState(() {
      stopSignal++;
      isPaused = false;
      isExecutingInstructions = false;
      isExecutingCycleInstruction = false;
      currentInstruction = '';
    });
  }

  void restartSimulation() {
    setState(() {
      restartSignal++;
      isPaused = false;
      isExecutingInstructions = true;
      currentInstruction = '';
    });
  }

  Widget _buildSimulationControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isEnabled
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isEnabled
              ? Colors.white.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        icon: Icon(
          icon,
          color:
              isEnabled ? neutralWhite : neutralWhite.withValues(alpha: 0.45),
          size: 20,
        ),
      ),
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
        title: const Text('Atta-Bot Educativo'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: neutralWhite,
          fontSize: 18.0,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          Builder(
            builder: (context) {
              final bool isTabletPortrait =
                  !isLandscape && MediaQuery.of(context).size.width >= 600;
              final double questionIconSize = isTabletPortrait ? 24.0 : 16.0;
              return IconButton(
                splashRadius: isTabletPortrait ? 30 : null,
                padding:
                    EdgeInsets.symmetric(horizontal: isTabletPortrait ? 14 : 8),
                icon: Image.asset(
                  'assets/button_icons/question_mark.png',
                  color: neutralWhite,
                  height: questionIconSize,
                  width: questionIconSize,
                ),
                color: neutralWhite,
                onPressed: () {
                  if (simplifiedProvider.simplifiedMode) {
                    HelpDialogForSimplifiedMode.show(context);
                  } else {
                    HelpDialog.show(context);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: neutralDarkBlue,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Builder(
              builder: (context) {
                final instructions = context
                    .read<CommandService>()
                    .commandHistory
                    .map((cmd) => cmd.toUiString())
                    .toList();

                if (context.watch<CommandService>().cycleActive &&
                    context.watch<SimplifiedModeProvider>().simplifiedMode) {
                  instructions
                      .add(Command(CommandType.endCycle, null).toUiString());
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // -------------------- TÍTULO & DROPDOWN ----------------------
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Simulación',
                            style: TextStyle(
                              color: neutralWhite,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: const Text(
                              'Escala del simulador: 1 cuadro = 20 x 20 cm',
                              style: TextStyle(
                                color: neutralWhite,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text(
                                'Visualizando:',
                                style: TextStyle(
                                  color: neutralWhite,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 32,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedFile,
                                      isExpanded: true,
                                      iconSize: 14,
                                      iconEnabledColor: neutralWhite,
                                      dropdownColor: neutralDarkBlue,
                                      style: const TextStyle(
                                        color: neutralWhite,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                      ),
                                      items: availableFiles.map((file) {
                                        return DropdownMenuItem(
                                          value: file,
                                          child: Text(
                                            file,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() => selectedFile = value);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Image.asset(
                                  'assets/button_icons/add.png',
                                  height: 20,
                                  width: 20,
                                  color: neutralWhite,
                                ),
                                onPressed: () {
                                  showSimulatorActionsDialog(context);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (isExecutingCycleInstruction
                                              ? Colors.green
                                              : Colors.red)
                                          .withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isExecutingCycleInstruction
                                            ? Colors.green
                                            : Colors.red,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      isExecutingCycleInstruction
                                          ? 'Ciclo abierto'
                                          : 'Ciclo cerrado',
                                      style: TextStyle(
                                        color: isExecutingCycleInstruction
                                            ? Colors.greenAccent
                                            : const Color(0xFFFF8A80),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildSimulationControlButton(
                                icon: Icons.stop_rounded,
                                tooltip: 'Detener',
                                onPressed: isExecutingInstructions || isPaused
                                    ? stopSimulation
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              _buildSimulationControlButton(
                                icon: isPaused
                                    ? Icons.play_arrow_rounded
                                    : Icons.pause_rounded,
                                tooltip: isPaused ? 'Reanudar' : 'Pausar',
                                onPressed: isExecutingInstructions || isPaused
                                    ? togglePause
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              _buildSimulationControlButton(
                                icon: Icons.restart_alt_rounded,
                                tooltip: 'Reiniciar',
                                onPressed: restartSimulation,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ---------------------- GRID SIMULATOR ------------------------
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: SimulationArea(
                            instructions: instructions,
                            paused: isPaused,
                            width: double.infinity,
                            height: double.infinity,
                            useImage: true,
                            botImagePath: 'assets/atta_bot.png',
                            onInstructionChange: (instruction) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() {
                                    currentInstruction = instruction;
                                  });
                                }
                              });
                            },
                            onExecutionStateChanged: (isExecuting) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() {
                                    isExecutingInstructions = isExecuting;
                                    if (!isExecuting) {
                                      isPaused = false;
                                      isExecutingCycleInstruction = false;
                                    }
                                  });
                                }
                              });
                            },
                            onCycleExecutionStateChanged: (isExecutingCycle) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() {
                                    isExecutingCycleInstruction =
                                        isExecutingCycle;
                                  });
                                }
                              });
                            },
                            stopSignal: stopSignal,
                            restartSignal: restartSignal,
                          ),
                        ),
                      ),
                    ),

                    // --------------------- TEXTO DE INSTRUCCIÓN ----------------------
                    const SizedBox(height: 12),

                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          currentInstruction,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
