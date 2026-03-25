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
  final List<List<Offset>> penPaths = [];
  int penPointCount = 0;

  final double step = 30;
  final double objectSize = 60;
  final double gridCellSize = 30;

  @override
  void initState() {
    super.initState();
    previousRotation = rotation;
    previousWorldPosition = worldPosition;
    _runInstructions();
  }

  String _normalizeInstruction(String instruction) {
    final normalized = instruction
        .toLowerCase()
        .replaceAll('\u00a2', 'o')
        .replaceAll('\u00a0', 'a')
        .replaceAll('\u00a3', 'u')
        .replaceAll(RegExp(r'[\u00e1\u00e0\u00e4\u00e2\u00e3]'), 'a')
        .replaceAll(RegExp(r'[\u00e9\u00e8\u00eb\u00ea]'), 'e')
        .replaceAll(RegExp(r'[\u00ed\u00ec\u00ef\u00ee]'), 'i')
        .replaceAll(RegExp(r'[\u00f3\u00f2\u00f6\u00f4\u00f5]'), 'o')
        .replaceAll(RegExp(r'[\u00fa\u00f9\u00fc\u00fb]'), 'u')
        .replaceAll('\u00f1', 'n')
        .replaceAll('\u00e7', 'c')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return normalized;
  }

  List<String> _expandCycles(List<String> instructions) {
    List<String> output = [];
    int i = 0;

    while (i < instructions.length) {
      final line = instructions[i].trim();
      final normalizedLine = _normalizeInstruction(line);
      if (normalizedLine.startsWith("ciclo abierto")) {
        final match = RegExp(r'ciclo abierto\D*(\d+)', caseSensitive: false)
            .firstMatch(normalizedLine);
        final repeatCount = match != null ? int.parse(match.group(1)!) : 1;

        int nest = 1;
        int j = i + 1;

        while (j < instructions.length && nest > 0) {
          final current = _normalizeInstruction(instructions[j]);
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
        final inst = _normalizeInstruction(instruction);
        double angle = _radians(rotation - 90);
        previousWorldPosition = worldPosition;
        bool moved = false;

        if (inst.contains("avanzar")) {
          worldPosition = worldPosition.translate(
            step * cos(angle),
            step * sin(angle),
          );
          moved = true;
        } else if (inst.contains("retroceder")) {
          worldPosition = worldPosition.translate(
            -step * cos(angle),
            -step * sin(angle),
          );
          moved = true;
        } else if (inst.contains("girar")) {
          final match = RegExp(r'(\d+)', caseSensitive: false).firstMatch(inst);

          if (match != null) {
            final degrees = double.parse(match.group(1)!);
            previousRotation = rotation;

            if (inst.contains("izquierda"))
              rotation -= degrees;
            else if (inst.contains("derecha")) rotation += degrees;
          }
        } else if (inst.contains("lapiz activado")) {
          if (!penActive) {
            penActive = true;
            _startPenTrail();
          }
        } else if (inst.contains("lapiz desactivado")) {
          penActive = false;
        } else if (inst.contains("deteccion iniciada")) {
          obstacleDetectionActive = true;
        } else if (inst.contains("deteccion finalizada")) {
          obstacleDetectionActive = false;
        }

        if (moved && penActive) {
          _extendPenTrail(worldPosition);
        }
      });
    }
  }

  double _radians(double degrees) => degrees * pi / 180;

  void _startPenTrail() {
    penPaths.add([worldPosition]);
    penPointCount++;
  }

  void _extendPenTrail(Offset position) {
    if (penPaths.isEmpty) {
      penPaths.add([position]);
      penPointCount++;
      return;
    }

    final currentPath = penPaths.last;
    if (currentPath.isEmpty || currentPath.last != position) {
      currentPath.add(position);
      penPointCount++;
    }
  }

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
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              TweenAnimationBuilder<Offset>(
                tween: Tween<Offset>(
                  begin: previousWorldPosition,
                  end: worldPosition,
                ),
                duration: const Duration(milliseconds: 400),
                builder: (context, animatedWorldPosition, child) {
                  return SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Stack(
                      children: [
                        CustomPaint(
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
                        ),
                        CustomPaint(
                          size: size,
                          painter: PenTrailPainter(
                            paths: penPaths,
                            pointCount: penPointCount,
                            worldPosition: animatedWorldPosition,
                          ),
                        ),
                      ],
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

class PenTrailPainter extends CustomPainter {
  final List<List<Offset>> paths;
  final int pointCount;
  final Offset worldPosition;
  final Color color;
  final double strokeWidth;

  PenTrailPainter({
    required this.paths,
    required this.pointCount,
    required this.worldPosition,
    this.color = const Color(0xFF25B35A),
    this.strokeWidth = 3,
  });

  Offset _toScreen(Offset world, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    return center + (world - worldPosition);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (paths.isEmpty) return;

    final trailPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    for (final pathPoints in paths) {
      if (pathPoints.isEmpty) continue;
      if (pathPoints.length == 1) {
        final point = _toScreen(pathPoints.first, size);
        canvas.drawCircle(point, strokeWidth / 1.5, trailPaint);
        continue;
      }

      final path = Path();
      final first = _toScreen(pathPoints.first, size);
      path.moveTo(first.dx, first.dy);

      for (int i = 1; i < pathPoints.length; i++) {
        final point = _toScreen(pathPoints[i], size);
        path.lineTo(point.dx, point.dy);
      }

      canvas.drawPath(path, trailPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PenTrailPainter oldDelegate) {
    return oldDelegate.pointCount != pointCount ||
        oldDelegate.worldPosition != worldPosition ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
