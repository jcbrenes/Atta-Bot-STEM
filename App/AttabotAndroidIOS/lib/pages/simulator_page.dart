import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/bot-control/actions/action_menu.dart';
import 'package:proyecto_tec/features/bot-control/actions/history_menu.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/simulator_actions_dialog.dart';
import 'package:proyecto_tec/features/bot-control/movement/movement_menu.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/features/navigation/services/navigation.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/shared/components/ui/simulator/grid_simulator.dart'; // Asegúrate de la ruta correcta

class SimulatorPage extends StatefulWidget {
  const SimulatorPage({super.key});

  @override
  State<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends State<SimulatorPage> {
  NavigationService navService = DependencyManager().getNavigationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
        actions: <Widget>[
          IconButton(
            icon: Image.asset(
              'assets/button_icons/question_mark.png',
              color: neutralWhite,
              height: 18,
              width: 18,
            ),
            color: neutralWhite,
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
      body: Container(
        color: neutralDarkBlue,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(height: 70),
            // Aquí se inserta el área de simulación
            SimulationArea(),
            SizedBox(height: 10),
            HistoryMenu(),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
