import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/simulator_actions_dialog.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/features/navigation/services/navigation.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/simulator/grid_simulator.dart';

class SimulatorPage extends StatefulWidget {
  const SimulatorPage({super.key});

  @override
  State<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends State<SimulatorPage> {
  NavigationService navService = DependencyManager().getNavigationService();
  String currentInstruction = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neutralDarkBlue,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: const Text('Simulador'),
        titleTextStyle: const TextStyle(
          color: neutralWhite,
          fontSize: 20.0,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
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
            onPressed: () {
              Navigator.of(context).pop();
            },
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
      body: SafeArea(
        child: Center(
          child: Builder(
            builder: (context) {
              final instructions = context
                  .read<CommandService>()
                  .commandHistory
                  .map((cmd) => cmd.toUiString())
                  .toList();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  SimulationArea(
                    instructions: instructions,
                    useImage:
                        true, // 🔁 cámbialo a false si quieres el triángulo
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
                  const SizedBox(height: 24),
                  Padding(
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
                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
