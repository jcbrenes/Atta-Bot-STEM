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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        

        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        DefaultButtonFactory.getButton(
          color: secondaryGreen,
          iconSize: MediaQuery.of(context).size.width * 0.06,
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

        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        DefaultButtonFactory.getButton(
          color: primaryYellow,
          iconSize: MediaQuery.of(context).size.width * 0.06,
          buttonType: ButtonType.primaryIcon,
          onPressed: () {
            if (!commandService.obstacleDetection) {
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

        // THIS IS THE PLAY BUTTON
        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        TextButton(
          style: TextButton.styleFrom(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            shape: const CircleBorder(
              side: BorderSide(color: neutralWhite, width: 3.0),
            ),
            iconColor: neutralWhite,
          ),
          onPressed: () async {
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
            
          },
          child: Image.asset(
            'assets/button_icons/newplay.png',
            color: neutralWhite,
            width: MediaQuery.of(context).size.width > 600 ? 60 : 40,
            height: MediaQuery.of(context).size.width > 600 ? 60 : 40,
            alignment: Alignment.center,
          ),
        ),

        // THIS IS THE PAUSE BUTTON
        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        TextButton(
          style: TextButton.styleFrom(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            shape: const CircleBorder(
              side: BorderSide(color: neutralWhite, width: 3.0),
            ),
            iconColor: neutralWhite,
          ),
          onPressed: () async {
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
          },
          child: Image.asset(
            'assets/button_icons/pause.png',
            color: neutralWhite,
            width: MediaQuery.of(context).size.width > 600 ? 60 : 40,
            height: MediaQuery.of(context).size.width > 600 ? 60 : 40,
            alignment: Alignment.center,
          ),
        ),


        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        DefaultButtonFactory.getButton(
          color: secondaryPurple,
          iconSize: MediaQuery.of(context).size.width * 0.06,
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

        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        DefaultButtonFactory.getButton(
          color: secondaryPink,
          iconSize: MediaQuery.of(context).size.width * 0.06,
          buttonType: ButtonType.primaryIcon,
          onPressed: () async{
            if (!btService.isConnected) {
              SimulatorBluetoothDialog.show(context);
              //navService.goToBluetoothDevicesPage(context);
              return;
            }
            if (context.read<CommandService>().commandHistory.isEmpty) {
              showEmptyHistorySnackBar(context);
              return;
            }
            String message =
                context.read<CommandService>().getCommandsBotString(context.watch<SimplifiedModeProvider>().simplifiedMode); // pass simplified mode status to know if we need to add endCycle
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
    );
  }
}

