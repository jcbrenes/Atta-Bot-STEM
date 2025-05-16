import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/components/bot_simulation.dart';
import 'package:proyecto_tec/screens/ventanaHistorial.dart';
import 'package:proyecto_tec/shared/components/ui/item_separator.dart';

class PlaneSimulation extends StatefulWidget {
  const PlaneSimulation({super.key});

  @override
  State<PlaneSimulation> createState() => _PlaneSimulationState();
}

class _PlaneSimulationState extends State<PlaneSimulation> {
  
  final String _actionLabel = 'Empezar';
  final double _planeSimulationViewSize = 300;

  void initSimulationAnimation() {
    print('Iniciando simulación');
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentHistory = context.watch<Historial>().historial;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
            dimension: _planeSimulationViewSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Stack(
                children: [
                  for (int i = 0; i < currentHistory.length; i++)
                    Positioned(
                      left: 0,
                      top: i * 50.0,
                      child: Text(currentHistory[i]),
                    ),
                  const Center(child: BotSimulation(
                    botImagePath: 'assets/AttaBotRobot_uno.png',
                  ))
                ],
              ),
            )),
        const ItemSeparator(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: initSimulationAnimation,
              child: Text(_actionLabel),
            )
          ],
        )
      ],
    );
  }
}
