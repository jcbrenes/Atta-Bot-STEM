import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/features/navigation/services/navigation.dart';
import 'package:proyecto_tec/shared/interfaces/bluetooth/bluetooth_service_interface.dart';
// import provider and service commands
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';

class HistoryMenu extends StatefulWidget {
  const HistoryMenu({super.key});

  @override
  State<HistoryMenu> createState() => _HistoryMenuState();
}

class _HistoryMenuState extends State<HistoryMenu> {
  String selectedBot = 'Bot 1'; // Add this line for storing selected value
  final List<String> bots = ['Bot 1', 'Bot 2', 'Bot 3']; // Add available bots

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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Consumer<CommandService>(
        builder: (context, commandService, child) {
          return Row(
            children: [
              Spacer(),
              Text(
                commandService.getLastCommand(),
                style: const TextStyle(
                    shadows: [
                      Shadow(color: neutralWhite, offset: Offset(0, -6))
                    ],
                    fontSize: 14,
                    color: Colors.transparent,
                    fontWeight: FontWeight.w500,
                    decorationColor: neutralWhite,
                    decorationThickness: 3,
                    decoration: TextDecoration.underline),
              ),
              Spacer(),
              Container(
                child: Row(
                  children: [
                    const Text(
                      "atta-bot13",
                      style: TextStyle(
                          shadows: [
                            Shadow(color: neutralWhite, offset: Offset(0, -6))
                          ],
                          fontSize: 14,
                          color: Colors.transparent,
                          fontWeight: FontWeight.w500,
                          decorationColor: neutralWhite,
                          decoration: TextDecoration.underline),
                    ),
                    Column(
                      children: [
                        Container(
                            padding: EdgeInsets.all(0),
                            margin: EdgeInsets.all(0),
                            child: GestureDetector(
                                onTap: () async {
                                  if (!btService.isConnected) {
                                    navService
                                        .goToBluetoothDevicesPage(context);
                                    return;
                                  }
                                  if (context
                                      .read<CommandService>()
                                      .commandHistory
                                      .isEmpty) {
                                    showEmptyHistorySnackBar(context);
                                    return;
                                  }
                                  String message = context
                                      .read<CommandService>()
                                      .getCommandsBotString();
                                  bool messageSent = await btService
                                      .sendStringToDevice(message);
                                  if (!messageSent) {
                                    showMessageSnackBar(
                                        "Error al enviar comandos");
                                  }
                                  showMessageSnackBar("Comandos enviados");
                                },
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  size: 30,
                                  color: neutralWhite,
                                ))),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Spacer(),
            ],
          );
        },
      ),
    );
  }
}
