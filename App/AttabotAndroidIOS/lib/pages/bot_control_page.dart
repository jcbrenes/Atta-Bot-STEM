import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog.dart';
import 'package:proyecto_tec/features/bot-control/actions/action_menu.dart';
import 'package:proyecto_tec/features/bot-control/actions/text_menu.dart';
import 'package:proyecto_tec/features/bot-control/movement/movement_menu.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class BotControlPage extends StatefulWidget {
  const BotControlPage({super.key});
  @override
  State<BotControlPage> createState() => _BotControlPageState();
}

class _BotControlPageState extends State<BotControlPage> {
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
        child: const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MovementMenu(),
              SizedBox(height: 50),
              ActionMenu(),
              SizedBox(height: 20),
              TextMenu(),
            ]),
      ),
    );
  }
}
