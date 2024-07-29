import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/instruction-history/components/instruction_tile.dart';
import 'package:proyecto_tec/features/instruction-history/components/instructions_dropdown_menu.dart';
import 'package:proyecto_tec/screens/ventanaHistorial.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final Text pageTitle = const Text(
    'Instrucciones',
    style: TextStyle(
      fontWeight: FontWeight.bold,
    ),
  );
  final Map<String, Color> appbarColors = {
    'foreground': Colors.white,
    'background': const Color(0xFF586B8F),
  };

  final BoxDecoration bodyDecoration = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [Color(0xFF798DB1), Color(0xFF586B8F)],
    ),
  );

  final Map<String, Color> stateInstructions = {
    'Inicio de ciclo': const Color(0xFFF2B100),
    'Fin del ciclo': const Color(0xFFF2B100),
    'Detección de obstáculos activada': const Color.fromARGB(255, 11, 158, 158),
    'Fin detección de obstáculos': const Color.fromARGB(255, 11, 158, 158),
  };

  final Map<String, Color> movementInstructions = {
    'Avanzar': const Color(0XFF006DBD),
    'Retroceder': const Color(0XFF006DBD),
    'derecha': const Color(0xFFF47E3E),
    'izquierda': const Color(0xFFF47E3E),
  };

  Color processInstruction(String instruction) {
    List<String> instructionParts;
    instructionParts = instruction.split(' ');

    Color? color = movementInstructions[instructionParts.first] ??
        movementInstructions[instructionParts.last];

    if (color != null) return color;
    instructionParts = instruction.split(',');
    return stateInstructions[instructionParts.first] ?? Colors.white;
  }

  Widget? setTrailing(String instruction) {
    if (instruction.contains('Fin del ciclo')) return null;

    return IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirmación'),
                content: const Text(
                    '¿Estás seguro de que quieres eliminar este elemento?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      // historial.removeEvento(
                      //     index); // Elimina el elemento
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: pageTitle,
            foregroundColor: appbarColors['foreground'],
            backgroundColor: appbarColors['background'],
            actions: <Widget>[InstructionHistoryDropdown(context: context)]),
        body: Container(
          decoration: bodyDecoration,
          child: Consumer<Historial>(
            builder: (context, historial, child) {
              return ListView.builder(
                itemCount: historial.historial.length,
                itemBuilder: (context, index) {
                  return InstructionTile(
                      color: processInstruction(historial.historial[index]),
                      title: historial.historial[index],
                      trailing: setTrailing(historial.historial[index]));
                },
              );
            },
          ),
        ));
  }
}
