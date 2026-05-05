import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';

class HistoryMenu extends StatefulWidget {
  final double topPadding;

  const HistoryMenu({
    super.key,
    this.topPadding = 0,
  });

  @override
  State<HistoryMenu> createState() => _HistoryMenuState();
}

class _HistoryMenuState extends State<HistoryMenu> {
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
      padding: EdgeInsets.only(top: widget.topPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Consumer<CommandService>(
        builder: (context, commandService, child) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commandService.getLastCommand(),
                    style: const TextStyle(
                      shadows: [
                        Shadow(color: neutralGray, offset: Offset(0, -6))
                      ],
                      fontSize: 16,
                      color: Colors.transparent,
                      fontWeight: FontWeight.w500,
                      decorationColor: neutralGray,
                      decorationThickness: 3,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
