import 'package:flutter/material.dart';

class SimulationArea extends StatelessWidget {
  final double width;
  final double height;

  const SimulationArea({
    Key? key,
    this.width = 200,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Stack(
        children: [
          // elementos de simulación
        ],
      ),
    );
  }
}
