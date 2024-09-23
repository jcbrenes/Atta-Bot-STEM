import 'package:flutter/material.dart';
import 'package:proyecto_tec/pages/history_page.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
// import provider and service commands
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';

class HistoryMenu extends StatelessWidget {
  const HistoryMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Consumer<CommandService>(
          builder: (context, commandService, child) {
            return Text(
              commandService.getLastCommand(),
                style: TextStyle(fontSize: 18, color: neutralWhite, fontWeight: FontWeight.w500),
            );
          },
        ),
        IconButton(
          color: neutralWhite,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryPage()),
            );
          },
          icon: const Icon(Icons.history),
        ),
      ]),
    );
  }
}
