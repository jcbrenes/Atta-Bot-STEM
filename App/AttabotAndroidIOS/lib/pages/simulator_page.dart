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

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  @override
  Widget build(BuildContext context) {
    final simplifiedProvider = Provider.of<SimplifiedModeProvider>(context);

    return Scaffold(
      backgroundColor: neutralDarkBlue,
      appBar: AppBar(
        title: const Text('Atta-bot Educativo'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: neutralWhite,
          fontSize: 18.0,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
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
                                    color: Colors.white.withOpacity(0.10),
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
