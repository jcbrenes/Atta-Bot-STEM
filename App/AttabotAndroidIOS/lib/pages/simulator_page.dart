import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/simulator/dialogs/simulator_actions_dialog.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/features/commands/models/command.dart';
import 'package:proyecto_tec/features/commands/enums/command_types.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/features/navigation/services/navigation.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/features/simulator/components/grid_simulator.dart';
import 'package:proyecto_tec/features/simulator/components/pause_button.dart';
import 'package:proyecto_tec/pages/bot_control_page.dart'; // to find out if simplified mode is active

class SimulatorPage extends StatefulWidget {
  const SimulatorPage({super.key});

  @override
  State<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends State<SimulatorPage> {
  NavigationService navService = DependencyManager().getNavigationService();
  String currentInstruction = '';
  bool isPaused = false;

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neutralDarkBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
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
                if (context.watch<CommandService>().cycleActive && context.watch<SimplifiedModeProvider>().simplifiedMode) {
                  instructions.add(Command(CommandType.endCycle, null).toUiString());
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
                      child: Row(
                        children: [
                          const Text(
                            'Simulador',
                            style: TextStyle(
                              color: neutralWhite,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const Spacer(),
                          PauseButton(
                            isPaused: isPaused,
                            onToggle: togglePause,
                          ),
                          IconButton(
                            icon: Image.asset(
                              'assets/button_icons/carpeta_vacia.png',
                              color: neutralWhite,
                              height: 18,
                              width: 18,
                            ),
                            onPressed: () {
                              showSimulatorActionsDialog(context);
                            },
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Cerrar',
                              style: TextStyle(
                                color: neutralWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: SimulationArea(
                        instructions: instructions,
                        paused: isPaused,
                        width: 300,
                        height: 300,
                        useImage: false,
                        botImagePath: 'assets/generic_atta_bot.png',
                        onInstructionChange: (instruction) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                currentInstruction = instruction;
                              });
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
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
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
