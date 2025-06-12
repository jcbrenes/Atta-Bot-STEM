import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/bot-control/actions/cycle_dialog.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/info_dialog.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/features/simulator/dialogs/simulator_bluetooth_dialog.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/features/navigation/services/navigation.dart';
import 'package:proyecto_tec/shared/interfaces/bluetooth/bluetooth_service_interface.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class ActionMenu extends StatefulWidget {
  const ActionMenu({super.key});

  @override
  State<ActionMenu> createState() => _ActionMenuState();
}

class _ActionMenuState extends State<ActionMenu> {
  String selectedValue = ""; // Valor seleccionado inicial
  late StreamSubscription scanSubscription;
  List<BluetoothDevice> devices = [];

  // Servicios inicializados como final para mejor rendimiento
  final BluetoothServiceInterface btService =
      DependencyManager().getBluetoothService();
  final NavigationService navService =
      DependencyManager().getNavigationService();

  // Método unificado para mostrar mensajes
  void showSnackBar(String message, {int seconds = 3}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: seconds),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Suscripción a cambios en dispositivos Bluetooth
    scanSubscription = btService.devices$.listen((event) {
      debugPrint("Devices: $event");
      setState(() {
        devices = event;
        if (devices.isNotEmpty) {
          selectedValue = devices.first.remoteId.toString();
        }
      });
    });
  }

  @override
  void dispose() {
    // Cancelar suscripción al destruir el widget
    scanSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commandService = context.read<CommandService>();
    final iconSize = MediaQuery.of(context).size.width * 0.06;
    final playButtonSize =
        MediaQuery.of(context).size.width > 600 ? 60.0 : 40.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildToolButton(context, commandService, iconSize),
        const SizedBox(width: 15),
        _buildDetectionButton(context, commandService, iconSize),
        const SizedBox(width: 15),
        _buildCycleButton(context, commandService, iconSize),
        const SizedBox(width: 15),
        _buildPlayButton(context, playButtonSize),
      ],
    );
  }

  // Botón para activar/desactivar el lápiz
  Widget _buildToolButton(
      BuildContext context, CommandService commandService, double iconSize) {
    return DefaultButtonFactory.getButton(
      color: secondaryPurple,
      iconSize: iconSize,
      buttonType: ButtonType.primaryIcon,
      onPressed: () {
        final message = !commandService.pencilActive
            ? 'Se ha activado \n el lápiz'
            : 'Se ha desactivado \n el lápiz';

        showInfoDialog(context, message);

        if (!commandService.pencilActive) {
          commandService.activateTool();
        } else {
          commandService.deactivateTool();
        }
      },
      icon: IconType.pencil,
    );
  }

  // Botón para activar/desactivar la detección de obstáculos
  Widget _buildDetectionButton(
      BuildContext context, CommandService commandService, double iconSize) {
    return DefaultButtonFactory.getButton(
      color: primaryYellow,
      iconSize: iconSize,
      buttonType: ButtonType.primaryIcon,
      onPressed: () {
        final message = !commandService.obstacleDetection
            ? 'Se ha activado \nla detección \nde obstáculos'
            : 'Se ha desactivado \nla detección \nde obstáculos';

        showInfoDialog(context, message);

        if (!commandService.obstacleDetection) {
          commandService.activateObjectDetection();
        } else {
          commandService.deactivateObjectDetection();
        }
      },
      icon: IconType.obstacleDetection,
    );
  }

  // Botón para activar/cerrar ciclos
  Widget _buildCycleButton(
      BuildContext context, CommandService commandService, double iconSize) {
    return DefaultButtonFactory.getButton(
      color: secondaryGreen,
      iconSize: iconSize,
      buttonType: ButtonType.primaryIcon,
      onPressed: () {
        if (!commandService.cycleActive) {
          CycleDialog.show(context);
        } else {
          commandService.endCycle();
          showInfoDialog(context, 'Se ha cerrado el ciclo');
        }
      },
      icon: IconType.cycle,
    );
  }

  // Botón principal para enviar comandos al robot
  Widget _buildPlayButton(BuildContext context, double size) {
    return TextButton(
      style: TextButton.styleFrom(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(22),
        shape: const CircleBorder(
          side: BorderSide(color: neutralWhite, width: 5.0),
        ),
        iconColor: neutralWhite,
      ),
      onPressed: () async {
        // Verificar conexión Bluetooth
        if (!btService.isConnected) {
          SimulatorBluetoothDialog.show(context);
          return;
        }

        // Verificar que existan comandos para enviar
        final commandService = context.read<CommandService>();
        if (commandService.commandHistory.isEmpty) {
          showSnackBar('Aún no hay comandos');
          return;
        }

        // Enviar comandos al dispositivo
        final message = commandService.getCommandsBotString();
        final messageSent = await btService.sendStringToDevice(message);

        showSnackBar(
            messageSent ? "Comandos enviados" : "Error al enviar comandos");
      },
      child: Image.asset(
        'assets/button_icons/play.png',
        color: neutralWhite,
        width: size,
        height: size,
        alignment: const Alignment(0, 3),
      ),
    );
  }
}
