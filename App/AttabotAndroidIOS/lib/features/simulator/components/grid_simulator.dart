import 'dart:math';
import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
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
    super.key,
    required this.instructions,
    required this.paused,
    this.width = 300,
    this.height = 300,
    this.onInstructionChange,
    this.useImage = false,
    this.botImagePath,
  });

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
  final List<_TrailSegment> trailSegments = [];
  final List<_InstructionMarker> instructionMarkers = [];
  int trailSegmentCount = 0;
  int instructionMarkerCount = 0;
  int? selectedInstructionMarkerIndex;

  final double step = 30;
  final double objectSize = 60;
  final double gridCellSize = 30;
  static const double _markerHitRadius = 14;

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
          if (current.startsWith("ciclo abierto")) {
            nest++;
          } else if (current.startsWith("ciclo cerrado")) {
            nest--;
          }
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
        bool markInstructionStart = false;
        String? instructionMarkerLabel;

        if (inst.contains("avanzar")) {
          markInstructionStart = true;
          instructionMarkerLabel =
              "Avanzar ${_instructionValue(instruction)} cm";
          worldPosition = worldPosition.translate(
            step * cos(angle),
            step * sin(angle),
          );
          moved = true;
        } else if (inst.contains("retroceder")) {
          markInstructionStart = true;
          instructionMarkerLabel =
              "Retroceder ${_instructionValue(instruction)} cm";
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

            if (inst.contains("izquierda")) {
              markInstructionStart = true;
              instructionMarkerLabel =
                  "Girar a la izquierda ${_formatDegrees(degrees)}°";
              rotation -= degrees;
            } else if (inst.contains("derecha")) {
              markInstructionStart = true;
              instructionMarkerLabel =
                  "Girar a la derecha ${_formatDegrees(degrees)}°";
              rotation += degrees;
            }
          }
        } else if (inst.contains("lapiz activado")) {
          markInstructionStart = true;
          instructionMarkerLabel = "Lápiz activado";
          penActive = true;
        } else if (inst.contains("lapiz desactivado")) {
          penActive = false;
        } else if (inst.contains("deteccion iniciada")) {
          markInstructionStart = true;
          instructionMarkerLabel = "Detección de objetos activada";
          obstacleDetectionActive = true;
        } else if (inst.contains("deteccion finalizada")) {
          obstacleDetectionActive = false;
        }

        if (markInstructionStart && instructionMarkerLabel != null) {
          _addInstructionMarker(previousWorldPosition, instructionMarkerLabel);
        }

        if (moved) {
          _addTrailSegment(previousWorldPosition, worldPosition);
        }
      });
    }
  }

  double _radians(double degrees) => degrees * pi / 180;

  String _instructionValue(String instruction) {
    final match = RegExp(r'(\d+(?:[\.,]\d+)?)').firstMatch(instruction);
    if (match == null) return "1";

    final value = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    if (value == null) return match.group(1)!;
    return _formatDegrees(value);
  }

  String _formatDegrees(double degrees) {
    if (degrees % 1 == 0) return degrees.toInt().toString();
    return degrees.toStringAsFixed(1);
  }

  void _addInstructionMarker(Offset position, String label) {
    instructionMarkers.add(
      _InstructionMarker(
        position: position,
        label: label,
      ),
    );
    instructionMarkerCount++;
  }

  Offset _worldToScreen(Offset world, Size size, Offset cameraWorldPosition) {
    final center = Offset(size.width / 2, size.height / 2);
    return center + (world - cameraWorldPosition);
  }

  int? _findTappedInstructionMarker(
    Offset tapPosition,
    Size size,
    Offset cameraWorldPosition,
  ) {
    for (int i = instructionMarkers.length - 1; i >= 0; i--) {
      final markerPosition = _worldToScreen(
        instructionMarkers[i].position,
        size,
        cameraWorldPosition,
      );

      if ((tapPosition - markerPosition).distance <= _markerHitRadius) {
        return i;
      }
    }

    return null;
  }

  void _addTrailSegment(Offset start, Offset end) {
    if (start == end) return;

    trailSegments.add(
      _TrailSegment(
        start: start,
        end: end,
        color: penActive ? secondaryPurple : primaryBlue,
      ),
    );
    trailSegmentCount++;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final robotLeft = (size.width - objectSize) / 2;
        final robotTop = (size.height - objectSize) / 2;
        final gridLineColor = const Color(0xFF2E6CC8).withValues(alpha: 0.35);

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
                          painter: _PenTrailPainter(
                            segments: trailSegments,
                            segmentCount: trailSegmentCount,
                            markers: instructionMarkers,
                            markerCount: instructionMarkerCount,
                            worldPosition: animatedWorldPosition,
                            targetWorldPosition: worldPosition,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTapDown: (details) {
                            final markerIndex = _findTappedInstructionMarker(
                              details.localPosition,
                              size,
                              animatedWorldPosition,
                            );

                            setState(() {
                              selectedInstructionMarkerIndex = markerIndex;
                            });
                          },
                          child: SizedBox(
                            width: size.width,
                            height: size.height,
                          ),
                        ),
                        if (selectedInstructionMarkerIndex != null &&
                            selectedInstructionMarkerIndex! <
                                instructionMarkers.length)
                          _InstructionMarkerTooltip(
                            marker: instructionMarkers[
                                selectedInstructionMarkerIndex!],
                            position: _worldToScreen(
                              instructionMarkers[
                                      selectedInstructionMarkerIndex!]
                                  .position,
                              size,
                              animatedWorldPosition,
                            ),
                            canvasSize: size,
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
                      alignment: Alignment.center,
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

class _TrailSegment {
  final Offset start;
  final Offset end;
  final Color color;

  const _TrailSegment({
    required this.start,
    required this.end,
    required this.color,
  });
}

class _InstructionMarker {
  final Offset position;
  final String label;

  const _InstructionMarker({
    required this.position,
    required this.label,
  });
}

class _InstructionMarkerTooltip extends StatelessWidget {
  static const double _width = 220;
  static const double _estimatedHeight = 56;

  final _InstructionMarker marker;
  final Offset position;
  final Size canvasSize;

  const _InstructionMarkerTooltip({
    required this.marker,
    required this.position,
    required this.canvasSize,
  });

  @override
  Widget build(BuildContext context) {
    final tooltipWidth = min(_width, max(80.0, canvasSize.width - 16.0));
    final maxLeft = max(8.0, canvasSize.width - tooltipWidth - 8.0);
    final left =
        (position.dx - (tooltipWidth / 2)).clamp(8.0, maxLeft).toDouble();
    final hasSpaceAbove = position.dy > _estimatedHeight + 18;
    final rawTop =
        hasSpaceAbove ? position.dy - _estimatedHeight - 12 : position.dy + 12;
    final maxTop = max(8.0, canvasSize.height - _estimatedHeight - 8.0);
    final top = rawTop.clamp(8.0, maxTop).toDouble();

    return Positioned(
      left: left,
      top: top,
      width: tooltipWidth,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: neutralDarkBlueAD,
          border: Border.all(color: neutralWhite, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: primaryOrange,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                marker.label,
                style: const TextStyle(
                  color: neutralWhite,
                  fontFamily: "Poppins",
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PenTrailPainter extends CustomPainter {
  static const double _strokeWidth = 3;
  static const double _markerRadius = 4;

  final List<_TrailSegment> segments;
  final int segmentCount;
  final List<_InstructionMarker> markers;
  final int markerCount;
  final Offset worldPosition;
  final Offset targetWorldPosition;

  _PenTrailPainter({
    required this.segments,
    required this.segmentCount,
    required this.markers,
    required this.markerCount,
    required this.worldPosition,
    required this.targetWorldPosition,
  });

  Offset _toScreen(Offset world, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    return center + (world - worldPosition);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final trailPaint = Paint()
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final end = i == segments.length - 1 && segment.end == targetWorldPosition
          ? worldPosition
          : segment.end;
      trailPaint.color = segment.color;
      canvas.drawLine(
        _toScreen(segment.start, size),
        _toScreen(end, size),
        trailPaint,
      );
    }

    final markerPaint = Paint()
      ..color = primaryOrange
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (final marker in markers) {
      canvas.drawCircle(
        _toScreen(marker.position, size),
        _markerRadius,
        markerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PenTrailPainter oldDelegate) {
    return oldDelegate.segmentCount != segmentCount ||
        oldDelegate.markerCount != markerCount ||
        oldDelegate.worldPosition != worldPosition ||
        oldDelegate.targetWorldPosition != targetWorldPosition;
  }
}
