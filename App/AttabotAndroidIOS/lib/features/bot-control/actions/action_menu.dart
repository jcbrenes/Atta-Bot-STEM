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
// import provider and service commands
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';

class ActionMenu extends StatefulWidget {
  const ActionMenu({super.key});

  @override
  State<ActionMenu> createState() => _ActionMenuState();
}

class _ActionMenuState extends State<ActionMenu> {
  String? selectedValue = ""; // Initial selected value
  bool obstacleDetection = false;
  bool pencilActive = false;
  bool clawActive = false;
  bool initCycle = false;
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DefaultButtonFactory.getButton(
          color: secondaryGreen,
          buttonType: ButtonType.primaryIcon,
          onPressed: () {
            initCycle = !initCycle;
            if (initCycle) {
              CycleDialog.show(context);
            } else {
              context.read<CommandService>().endCycle();
              showInfoDialog(context, 'Se ha cerrado el ciclo');
            }
          },
          icon: IconType.cycle,
        ),
        SizedBox(width: 16),
        DefaultButtonFactory.getButton(
          color: primaryYellow,
          buttonType: ButtonType.primaryIcon,
          onPressed: () {
            obstacleDetection = !obstacleDetection;
            if (obstacleDetection) {
              showInfoDialog(
                  context, 'Se ha activado \nla detección \nde obstáculos');
              context.read<CommandService>().activateObjectDetection();
            } else {
              showInfoDialog(
                  context, 'Se ha desactivado \nla detección \nde obstáculos');
              context.read<CommandService>().deactivateObjectDetection();
            }
          },
          icon: IconType.obstacleDetection,
        ),
        SizedBox(width: 16),
        TextButton(
          style: TextButton.styleFrom(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            shape: CircleBorder(
              side: BorderSide(color: neutralWhite, width: 4.0),
            ),
            iconColor: neutralWhite,
          ),
          onPressed: () async {
            if (!btService.isConnected) {
              navService.goToBluetoothDevicesPage(context);
              return;
            }
            if (context.read<CommandService>().commandHistory.isEmpty) {
              showEmptyHistorySnackBar(context);
              return;
            }

            // Send commands to the bot using the bluetooth service
            String message =
                context.read<CommandService>().getCommandsBotString();
            bool messageSent = await btService.sendStringToDevice(message);
            if (!messageSent) {
              showMessageSnackBar("Error al enviar comandos");
            }
            showMessageSnackBar("Comandos enviados");
          },
          child: Image.asset(
            'assets/button_icons/play.png',
            color: neutralWhite,
            width: 27,
            height: 26,
            alignment: Alignment(1, 0),
          ),
        ),
        SizedBox(width: 16),
        DefaultButtonFactory.getButton(
          color: secondaryPink,
          buttonType: ButtonType.primaryIcon,
          onPressed: () {
            pencilActive = !pencilActive;
            if (pencilActive) {
              showInfoDialog(context, 'Se ha activado \n el lápiz');
              context.read<CommandService>().activateTool();
            } else {
              showInfoDialog(context, 'Se ha desactivado \n el lápiz');
              context.read<CommandService>().deactivateTool();
            }
          },
          icon: IconType.pencil,
        ),
        SizedBox(width: 16),
        DefaultButtonFactory.getButton(
          color: secondaryPurple,
          buttonType: ButtonType.primaryIcon,
          onPressed: () {
            clawActive = !clawActive;
            if (clawActive) {
              showInfoDialog(context, 'Se ha activado \n _____');
            } else {
              showInfoDialog(context, 'Se ha desactivado \n _____');
            }
          },
          icon: IconType.claw,
        ),
      ],
    );
  }
}
