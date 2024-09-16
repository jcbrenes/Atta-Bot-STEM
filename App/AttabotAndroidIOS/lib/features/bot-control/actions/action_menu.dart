import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/bot-control/actions/cycle_input.dart';

class ActionMenu extends StatefulWidget {
  const ActionMenu({super.key});

  @override
  State<ActionMenu> createState() => _ActionMenuState();
}

class _ActionMenuState extends State<ActionMenu> {
  String? selectedValue = "Atta-bot 1"; // Initial selected value

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          color: Colors.white,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text(
                    'Se ha activado la detección de obstáculos',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: const Color(0xFFDDE6F7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(color: Colors.white, width: 5.0),
                  ),
                );
              },
            );
          },
          icon: const Icon(Icons.visibility),
        ),
        IconButton(
          color: Colors.white,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    title: const Text(
                    'Repetir el ciclo',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                    content: CycleInput(
                      onCycleSelected: (value) {
                        setState(() {
                          value = value;
                        });
                      },
                    ));
              },
            );
          },
          icon: const Icon(Icons.autorenew),
        ),
        const SizedBox(width: 25),
        DropdownButton<String>(
          dropdownColor: const Color.fromARGB(200, 0, 0, 0),
          iconEnabledColor: Colors.white,
          value: selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue;
            });
          },
          style: TextStyle(color: Colors.white),
          underline: Container(
            color: Colors.white,
            height: 1,
          ),
          items: <String>['Atta-bot 1', 'Atta-bot 2', 'Atta-bot 3']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        IconButton(
          color: Colors.white,
          onPressed: () {},
          icon: const Icon(Icons.play_arrow),
        ),
      ],
    );
  }
}
