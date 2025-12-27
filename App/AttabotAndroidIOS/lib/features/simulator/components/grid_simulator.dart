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
  Offset worldPosition = Offset.zero;
  Offset previousWorldPosition = Offset.zero;
  double rotation = 0;
  double previousRotation = 0;
  bool obstacleDetectionActive = false;
  bool penActive = false;

  final double step = 30;
  final double objectSize = 40;
  final double gridCellSize = 30;

  @override
  void initState() {
    super.initState();
    previousRotation = rotation;
    previousWorldPosition = worldPosition;
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
        previousWorldPosition = worldPosition;

        if (inst.contains("avanzar")) {
          worldPosition = worldPosition.translate(
            step * cos(angle),
            step * sin(angle),
          );
        } else if (inst.contains("retroceder")) {
          worldPosition = worldPosition.translate(
            -step * cos(angle),
            -step * sin(angle),
          );
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

      });
    }
  }

  double _radians(double degrees) => degrees * pi / 180;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final robotLeft = (size.width - objectSize) / 2;
        final robotTop = (size.height - objectSize) / 2;
        final gridLineColor = const Color(0xFF2E6CC8).withOpacity(0.35);

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: ClipRect(
            child: Stack(
              children: [
                TweenAnimationBuilder<Offset>(
                  tween: Tween<Offset>(
                    begin: previousWorldPosition,
                    end: worldPosition,
                  ),
                  duration: const Duration(milliseconds: 400),
                  builder: (context, animatedWorldPosition, child) {
                    return CustomPaint(
                      size: size,
                      painter: GridBackgroundPainter(
                        cellSize: gridCellSize,
                        offset: Offset(
                          -animatedWorldPosition.dx,
                          -animatedWorldPosition.dy,
                        ),
                        lineColor: gridLineColor,
                        backgroundColor: Colors.white,
                      ),
                    );
                  },
                ),
                Positioned(
                  left: robotLeft,
                  top: robotTop,
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
          ),
        );
      },
    );
  }
}

class GridBackgroundPainter extends CustomPainter {
  final double cellSize;
  final Offset offset;
  final Color lineColor;
  final Color backgroundColor;

  GridBackgroundPainter({
    required this.cellSize,
    required this.offset,
    required this.lineColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final startX = offset.dx % cellSize;
    final startY = offset.dy % cellSize;

    for (double x = startX; x <= size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    for (double y = startY; y <= size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant GridBackgroundPainter oldDelegate) {
    return oldDelegate.offset != offset ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
