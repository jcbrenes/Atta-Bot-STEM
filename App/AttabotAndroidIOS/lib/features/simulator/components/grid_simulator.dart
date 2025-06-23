import 'dart:math';
import 'package:flutter/material.dart';
import 'object_simulator.dart';

class SimulationArea extends StatefulWidget {
  final List<String> instructions;
  final double width;
  final double height;
  final void Function(String)? onInstructionChange;
  final bool useImage;
  final String? botImagePath;
  final bool paused;

  const SimulationArea({
    Key? key,
    required this.instructions,
    required this.paused,
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
  bool obstacleDetectionActive = false;
  bool penActive = false;

  final double step = 30;
  final double objectSize = 40;

  @override
  void initState() {
    super.initState();
    _runInstructions();
  }

  Future<void> _runInstructions() async {
    for (final instruction in widget.instructions) {
      // Notifica la instrucción actual
      widget.onInstructionChange?.call(instruction);

      // Esperar si está en pausa
      while (widget.paused) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      await Future.delayed(const Duration(milliseconds: 600));

      setState(() {
        final inst = instruction.toLowerCase();

        // 🔥 Ajuste clave: -90° para alinear con la orientación del triángulo
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
        } else if (inst.contains("lápiz activado")) {
          penActive = true;
        } else if (inst.contains("lápiz desactivado")) {
          penActive = false;
        } else if (inst.contains("detección iniciada")) {
          obstacleDetectionActive = true;
        } else if (inst.contains("detección finalizada")) {
          obstacleDetectionActive = false;
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
                  child: SizedBox(
                    width: objectSize,
                    height: objectSize,
                    child: ObjectSimulator(
                      size: objectSize,
                      useImage: widget.useImage,
                      botImagePath: widget.botImagePath ?? '',
                      penActive: penActive,
                      obstacleDetectionActive: obstacleDetectionActive,
                    ),
                  ),
                );
              },
              onEnd: () {
                setState(() {
                  previousRotation = rotation;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
