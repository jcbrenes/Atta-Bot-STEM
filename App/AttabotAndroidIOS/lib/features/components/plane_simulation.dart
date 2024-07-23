import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/screens/ventanaHistorial.dart';

class PlaneSimulation extends StatefulWidget {

  const PlaneSimulation({super.key});

  @override
  State<PlaneSimulation> createState() => _PlaneSimulationState();
}

class _PlaneSimulationState extends State<PlaneSimulation> {

  final double _planeSimulationViewSize = 300;

  @override
  Widget build(BuildContext context) {
    List<String> currentHistory = context.watch<Historial>().historial;
    return SizedBox(
        width: _planeSimulationViewSize,
        height: _planeSimulationViewSize,
        child: ListView.builder(
            itemCount: currentHistory.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(currentHistory[index]),
              );
            }));
  }
}
