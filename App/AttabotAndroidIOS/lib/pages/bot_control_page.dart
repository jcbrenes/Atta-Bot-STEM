import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/bot-control/actions/action_menu.dart';
import 'package:proyecto_tec/features/bot-control/actions/history_menu.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog.dart';
import 'package:proyecto_tec/features/bot-control/movement/movement_menu.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/features/navigation/services/navigation.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class BotControlPage extends StatefulWidget {
  const BotControlPage({super.key});
  @override
  State<BotControlPage> createState() => _BotControlPageState();
}

class _BotControlPageState extends State<BotControlPage> {
  NavigationService navService = DependencyManager().getNavigationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Atta-Bot Educativo'),
        titleTextStyle: const TextStyle(
            color: neutralWhite,
            fontSize: 20.0,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.bluetooth),
            color: neutralWhite,
            onPressed: () {
              navService.goToBluetoothDevicesPage(context);
            },
          ),
          IconButton(
            icon: Image.asset(
              'assets/button_icons/question_mark.png',
              color: neutralWhite,
              height: 18,
              width: 18,
            ),
            color: neutralWhite,
            onPressed: () {
              HelpDialog.show(context);
            },
          ),
        ],
      ),
      body: Container(
        color: neutralDarkBlue,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(0),
        child: const Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height:70),
                Spacer(),
                MovementMenu(),
                Expanded(child: SizedBox(height: 10)),
                ActionMenu(),
                Expanded(child: SizedBox(height: 15)),
                HistoryMenu(),
                Spacer()
              ]),
        ),
      ),
    );
  }
}
