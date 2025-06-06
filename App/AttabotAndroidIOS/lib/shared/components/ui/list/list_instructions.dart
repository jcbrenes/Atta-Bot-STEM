import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class InstructionsList extends StatelessWidget {
  final List<String> instructions;

  const InstructionsList({
    Key? key,
    required this.instructions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (instructions.isEmpty) {
      return const Center(
        child: Text(
          "No hay instrucciones",
          style: TextStyle(
            color: neutralWhite,
            fontFamily: "Poppins",
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: instructions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            instructions[index],
            style: const TextStyle(
              color: neutralWhite,
              fontFamily: "Poppins",
            ),
          ),
        );
      },
    );
  }
}
