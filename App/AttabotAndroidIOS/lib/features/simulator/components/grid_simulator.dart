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
  double rotation = 0;
  double previousRotation = 0;
  bool obstacleDetectionActive = false;
  bool penActive = false;

  final double step = 30;
  final double objectSize = 40;

  @override
  void initState() {
    super.initState();
    previousRotation = rotation;
    _runInstructions();
  }

  List<String> _expandCycles(List<String> instructions) {
    List<String> output = [];
    int i = 0;

    while (i < instructions.length) {
      final line = instructions[i].trim();
      if (line.toLowerCase().startsWith("ciclo abierto")) {
        final match =
            RegExp(r'ciclo abierto\s*\·\s*(\d+)', caseSensitive: false)
                .firstMatch(line);
        final repeatCount = match != null ? int.parse(match.group(1)!) : 1;

        int nest = 1;
        int j = i + 1;

        while (j < instructions.length && nest > 0) {
          final current = instructions[j].toLowerCase();
          if (current.startsWith("ciclo abierto"))
            nest++;
          else if (current.startsWith("ciclo cerrado")) nest--;
          j++;
        }

        final block = _expandCycles(instructions.sublist(i + 1, j - 1));

        for (int r = 0; r < repeatCount; r++) {
          output.addAll(block);
        }

        i = j;
      } else {
        output.add(line);
        i++;
      }
    }
    return output;
  }

  Future<void> _runInstructions() async {
    final expandedInstructions = _expandCycles(widget.instructions);

    for (final instruction in expandedInstructions) {
      widget.onInstructionChange?.call(instruction);

      while (widget.paused) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      await Future.delayed(const Duration(milliseconds: 600));

      setState(() {
        final inst = instruction.toLowerCase();
        double angle = _radians(rotation - 90);

        if (inst.contains("avanzar")) {
          posX += step * cos(angle);
          posY += step * sin(angle);
        } else if (inst.contains("retroceder")) {
          posX -= step * cos(angle);
          posY -= step * sin(angle);
        } else if (inst.contains("girar")) {
          final match = RegExp(r'(\d+)\s*[\u00b0]?', caseSensitive: false)
              .firstMatch(inst);

          if (match != null) {
            final degrees = double.parse(match.group(1)!);
            previousRotation = rotation;

            if (inst.contains("izquierda"))
              rotation -= degrees;
            else if (inst.contains("derecha")) rotation += degrees;
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
        border: Border.all(color: Colors.white, width: 2),
        image: const DecorationImage(
          image: AssetImage('assets/grid_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            left: posX,
            top: posY,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: previousRotation,
                end: rotation,
              ),
              duration: const Duration(milliseconds: 400),
              builder: (context, angleDegrees, child) {
                return Transform.rotate(
                  angle: _radians(angleDegrees),
                  origin: Offset(objectSize / 2, objectSize / 3),
                  child: child,
                );
              },
              onEnd: () {
                setState(() {
                  previousRotation = rotation;
                });
              },
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
            ),
          ),
        ],
      ),
    );
  }
}
