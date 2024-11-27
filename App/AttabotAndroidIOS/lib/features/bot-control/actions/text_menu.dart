import 'package:flutter/material.dart';
import 'package:proyecto_tec/pages/history_page.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
// import provider and service commands
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';

class TextMenu extends StatefulWidget {
  const TextMenu({super.key});

  @override
  State<TextMenu> createState() => _TextMenuState();
}

class _TextMenuState extends State<TextMenu> {
    String? selectedValue = "Atta-bot 1"; // Initial selected value
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
                style: TextStyle(fontSize: 14, color: neutralWhite, fontWeight: FontWeight.w500),
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
        DropdownButton<String>(
          dropdownColor: neutralDarkBlue,
          iconEnabledColor: neutralWhite,
          value: selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue;
            });
          },
          style: const TextStyle(color: neutralWhite),
          underline: Container(
            color: neutralWhite,
            height: 1,
          ),
          items: <String>['Atta-bot 1', 'Atta-bot 2', 'Atta-bot 3']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value,
                  style: const TextStyle(
                    color: neutralWhite,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  )),
            );
          }).toList(),
        ),
      ]),
    );
  }
}
