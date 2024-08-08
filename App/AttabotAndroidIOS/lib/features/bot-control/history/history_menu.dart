import 'package:flutter/material.dart';

class HistoryMenu extends StatelessWidget {
  const HistoryMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        const Text(
          'No hay acciones recientes',
          style: TextStyle(fontSize: 16),
        ),
        IconButton(
          onPressed: () {
            // Add your button 1 logic here
          },
          icon: const Icon(Icons.history),
        ),
      ]),
    );
  }
}
