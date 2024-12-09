import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
// import provider and service commands
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';

class HistoryMenu extends StatefulWidget {
  const HistoryMenu({super.key});

  @override
  State<HistoryMenu> createState() => _HistoryMenuState();
}

class _HistoryMenuState extends State<HistoryMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Consumer<CommandService>(
        builder: (context, commandService, child) {
          return Text(
            commandService.getLastCommand(),
              style: const TextStyle(fontSize: 18, color: neutralWhite, fontWeight: FontWeight.w500),
          );
        },
      ),
    );
  }
}
