import 'dart:math';
import 'package:flutter/material.dart';
import 'object_simulator.dart';

class SimulationArea extends StatefulWidget {
  final List<String> instructions;
  final double width;
  final double height;
  final void Function(String)? onInstructionChange;
  final bool useImage; // 👈 nuevo parámetro
  final String? botImagePath;

  const SimulationArea({
    Key? key,
    required this.instructions,
    this.width = 300,
    this.height = 300,
    this.onInstructionChange,
    this.useImage = false,
    this.botImagePath,
  }) : super(key: key);

  @override
  State<SimulationArea> createState() => _SimulationAreaState();
}

class _SimulationAreaState extends State<SimulationArea> {
  double posX = 130;
  double posY = 130;
  double rotation = 0; // grados actuales
  double previousRotation = 0; // para animación

  final double step = 30;
  final double objectSize = 40;

  @override
  void initState() {
    super.initState();
    _runInstructions();
  }

  Future<void> _runInstructions() async {
    for (final instruction in widget.instructions) {
      // 🔔 Notifica la instrucción actual
      widget.onInstructionChange?.call(instruction);

      await Future.delayed(const Duration(milliseconds: 600));

      setState(() {
        final inst = instruction.toLowerCase();

        // 🔁 Ajustar rotación para movimiento real (0° es arriba)
        double angle = _radians(rotation - 90);

        if (inst.contains("avanzar")) {
          posX += step * cos(angle);
          posY += step * sin(angle);
        } else if (inst.contains("retroceder")) {
          posX -= step * cos(angle);
          posY -= step * sin(angle);
        } else if (inst.contains("girar")) {
          final match = RegExp(r'(\d+)\s*grados').firstMatch(inst);
          if (match != null) {
            final degrees = double.parse(match.group(1)!);
            previousRotation = rotation;
            if (inst.contains("izquierda")) {
              rotation -= degrees;
            } else if (inst.contains("derecha")) {
              rotation += degrees;
            }
          }
        }

        // Limita el movimiento dentro del contenedor
        posX = posX.clamp(0, widget.width - objectSize);
        posY = posY.clamp(0, widget.height - objectSize);
      });
    }
  }

  double _radians(double degrees) => degrees * pi / 180;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            left: posX,
            top: posY,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: _radians(previousRotation),
                end: _radians(rotation),
              ),
              duration: const Duration(milliseconds: 400),
              builder: (context, angle, child) {
                return Transform.rotate(
                  angle: angle,
                  child: child,
                );
              },
              child: ObjectSimulator(
                size: objectSize,
                useImage: widget.useImage,
                botImagePath: widget.botImagePath ?? '',
              ),
              onEnd: () {
                previousRotation = rotation;
              },
            ),
          ),
        ],
      ),
    );
  }
}
