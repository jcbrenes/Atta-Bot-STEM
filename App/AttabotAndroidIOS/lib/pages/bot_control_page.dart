import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog.dart';
import 'package:proyecto_tec/features/bot-control/actions/action_menu.dart';
import 'package:proyecto_tec/features/bot-control/history/history_menu.dart';
import 'package:proyecto_tec/features/bot-control/movement/movement_menu.dart';

class BotControlPage extends StatefulWidget {
  const BotControlPage({super.key});

  @override
  State<BotControlPage> createState() => _BotControlPageState();
}

class _BotControlPageState extends State<BotControlPage> {

    final List<String> _history = [];

  void _addAction(String action) {
    setState(() {
      _history.add(action);
      print('Action: $action');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atta-Bot STEM'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.question_mark),
            onPressed: () {
              HelpDialog.show(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        MovementMenu(onAction: _addAction),
        const SizedBox(height: 75),
        HistoryMenu(),
        ActionMenu(),
      ]),
    );
  }
}