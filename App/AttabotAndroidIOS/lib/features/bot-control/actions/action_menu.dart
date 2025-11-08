import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/features/navigation/services/navigation.dart';
import 'package:proyecto_tec/shared/interfaces/bluetooth/bluetooth_service_interface.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';
import 'package:proyecto_tec/features/bot-control/actions/cycle_dialog.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/info_dialog.dart';
import 'package:proyecto_tec/features/simulator/dialogs/simulator_bluetooth_dialog.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/pages/bot_control_page.dart'; // to find out if simplified mode is active


class ActionMenu extends StatefulWidget {
  const ActionMenu({super.key});

  @override
  State<ActionMenu> createState() => _ActionMenuState();
}

class _ActionMenuState extends State<ActionMenu> {
  String? selectedValue = ""; // Initial selected value
  int cycleCount = 1;
  late StreamSubscription scanSubscription;
  List<BluetoothDevice> devices = [];

  BluetoothServiceInterface btService =
      DependencyManager().getBluetoothService();
  NavigationService navService = DependencyManager().getNavigationService();

  void showEmptyHistorySnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aún no hay comandos'),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

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
    scanSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commandService = context.read<CommandService>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxW = constraints.maxWidth;
        final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        final double baseFactor = isLandscape ? 0.055 : 0.065; 
        final double iconSize = (maxW * baseFactor).clamp(28, 50);
        final double gap = (maxW * 0.010).clamp(6, 12);

        Widget playButton(String asset, VoidCallback onPressed) {
          return SizedBox(
            width: iconSize + 20,
            height: iconSize + 20,
            child: TextButton(
              style: TextButton.styleFrom(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(6),
                shape: const CircleBorder(
                  side: BorderSide(color: neutralWhite, width: 2.0),
                ),
                iconColor: neutralWhite,
              ),
              onPressed: onPressed,
              child: Image.asset(
                asset,
                color: neutralWhite,
                width: iconSize * 0.9,
                height: iconSize * 0.9,
              ),
            ),
          );
        }
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DefaultButtonFactory.getButton(
                color: secondaryGreen,
                iconSize: iconSize,
                buttonType: ButtonType.primaryIcon,
                onPressed: () {
                  if (!commandService.cycleActive) {
                    CycleDialog.show(context);
                  } else {
                    context.read<CommandService>().endCycle();
                    showInfoDialog(context, 'Se ha cerrado el ciclo');
                  }
                },
                icon: IconType.cycle,
              ),
              SizedBox(width: gap),
              DefaultButtonFactory.getButton(
                color: primaryYellow,
                iconSize: iconSize,
                buttonType: ButtonType.primaryIcon,
                onPressed: () {
                  if (!commandService.obstacleDetection) {
                    showInfoDialog(context, 'Se ha activado \nla detección \nde obstáculos');
                    context.read<CommandService>().activateObjectDetection();
                  } else {
                    showInfoDialog(context, 'Se ha desactivado \nla detección \nde obstáculos');
                    context.read<CommandService>().deactivateObjectDetection();
                  }
                },
                icon: IconType.obstacleDetection,
              ),
              SizedBox(width: gap),
              playButton('assets/button_icons/newplay.png', () async {
                if (!btService.isConnected) {
                  SimulatorBluetoothDialog.show(context);
                  return;
                }
                if (context.read<CommandService>().commandHistory.isEmpty) {
                  showEmptyHistorySnackBar(context);
                  return;
                }
                bool messageSent = await btService.sendStringToDevice("ATCOIEJECUATCOF");
                if (!messageSent) {
                  showMessageSnackBar("Error al ejecutar comandos");
                  return;
                }
                showMessageSnackBar("Comandos ejecutándose");
              }),
              SizedBox(width: gap),
              playButton('assets/button_icons/pause.png', () async {
                if (!btService.isConnected) {
                  SimulatorBluetoothDialog.show(context);
                  return;
                }
                bool messageSent = await btService.sendStringToDevice("ATCOIPARARATCOF");
                if (!messageSent) {
                  showMessageSnackBar("Error al detener comandos");
                  return;
                }
                showMessageSnackBar("Comandos detenidos");
              }),
              SizedBox(width: gap),
              DefaultButtonFactory.getButton(
                color: secondaryPurple,
                iconSize: iconSize,
                buttonType: ButtonType.primaryIcon,
                onPressed: () {
                  if (!commandService.pencilActive) {
                    showInfoDialog(context, 'Se ha activado \n el lápiz');
                    context.read<CommandService>().activateTool();
                  } else {
                    showInfoDialog(context, 'Se ha desactivado \n el lápiz');
                    context.read<CommandService>().deactivateTool();
                  }
                },
                icon: IconType.pencil,
              ),
              SizedBox(width: gap),
              DefaultButtonFactory.getButton(
                color: secondaryPink,
                iconSize: iconSize,
                buttonType: ButtonType.primaryIcon,
                onPressed: () async {
                  if (!btService.isConnected) {
                    SimulatorBluetoothDialog.show(context);
                    return;
                  }
                  if (context.read<CommandService>().commandHistory.isEmpty) {
                    showEmptyHistorySnackBar(context);
                    return;
                  }
                  String message = context.read<CommandService>().getCommandsBotString(context.watch<SimplifiedModeProvider>().simplifiedMode);
                  bool messageSent = await btService.sendStringToDevice(message);
                  if (!messageSent) {
                    showMessageSnackBar("Error al enviar comandos");
                    return;
                  }
                  showMessageSnackBar("Comandos enviados");
                },
                icon: IconType.cloud,
              ),
            ],
          ),
        );
      },
    );
  }
}

