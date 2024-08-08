import 'package:flutter/material.dart';

class ActionMenu extends StatefulWidget {
  const ActionMenu({super.key});

  @override
  State<ActionMenu> createState() => _ActionMenuState();
}

class _ActionMenuState extends State<ActionMenu> {
  String? selectedValue = 'Option 1'; // Initial selected value

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            // Add your button 2 logic here
          },
          icon: const Icon(Icons.visibility),
        ),
        IconButton(
          onPressed: () {
            // Add your button 2 logic here
          },
          icon: const Icon(Icons.autorenew),
        ),
        const SizedBox(width: 40),
        DropdownButton<String>(
          value: selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue;
            });
          },
          items: <String>['Option 1', 'Option 2', 'Option 3']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        IconButton(
          onPressed: () {
            // Add your button 2 logic here
          },
          icon: const Icon(Icons.play_arrow),
        ),
      ],
    );
  }
}
