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
  String selectedBot = 'Bot 1'; // Add this line for storing selected value
  final List<String> bots = ['Bot 1', 'Bot 2', 'Bot 3']; // Add available bots

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
                child: const Flex(
                  direction: Axis.horizontal,
                  children: [
                    Text(
                      "atta-bot13",
                      style: const TextStyle(
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
                        Icon(
                          Icons.arrow_drop_down,
                          color: neutralWhite,
                          size: 30,
                        ),
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
