import 'dart:math';
import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'object_simulator.dart';

class SimulationArea extends StatefulWidget {
  final List<String> instructions;
  final double width;
  final double height;
  final void Function(String)? onInstructionChange;
  final void Function(bool)? onExecutionStateChanged;
  final int stopSignal;
  final int restartSignal;
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
    this.onExecutionStateChanged,
    this.stopSignal = 0,
    this.restartSignal = 0,
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

  static const double _defaultGridCellSize = 30;
  static const double _tabletColumns = 10;
  static const double _tabletMinGridCellSize = 60;
  double _gridCellSize = _defaultGridCellSize;
  int _runVersion = 0;

  @override
  void initState() {
    super.initState();
    previousRotation = rotation;
    previousWorldPosition = worldPosition;
    _startRun();
  }

  @override
  void didUpdateWidget(covariant SimulationArea oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.stopSignal != oldWidget.stopSignal) {
      _stopRun();
      return;
    }

    if (widget.restartSignal != oldWidget.restartSignal) {
      _restartRun();
    }
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

  void _startRun() {
    final runId = ++_runVersion;
    _runInstructions(runId);
  }

  void _stopRun() {
    _runVersion++;
    widget.onInstructionChange?.call('');
    widget.onExecutionStateChanged?.call(false);
  }

  void _restartRun() {
    _runVersion++;
    if (!mounted) return;

    setState(() {
      worldPosition = Offset.zero;
      previousWorldPosition = Offset.zero;
      rotation = 0;
      previousRotation = 0;
      obstacleDetectionActive = false;
      penActive = false;
      trailSegments.clear();
      instructionMarkers.clear();
      trailSegmentCount = 0;
      instructionMarkerCount = 0;
      selectedInstructionMarkerIndex = null;
    });

    widget.onInstructionChange?.call('');
    _startRun();
  }

  bool _isRunActive(int runId) => mounted && runId == _runVersion;

  Future<bool> _waitFor(
    Duration duration,
    int runId, {
    bool allowPause = false,
  }) async {
    const tick = Duration(milliseconds: 50);
    var elapsed = Duration.zero;

    while (elapsed < duration) {
      if (!_isRunActive(runId)) return false;

      while (allowPause && widget.paused) {
        if (!_isRunActive(runId)) return false;
        await Future.delayed(tick);
      }

      final remaining = duration - elapsed;
      final currentTick = remaining < tick ? remaining : tick;
      await Future.delayed(currentTick);
      elapsed += currentTick;
    }

    return _isRunActive(runId);
  }

  Future<void> _runInstructions(int runId) async {
    final expandedInstructions = _expandCycles(widget.instructions);

    if (expandedInstructions.isEmpty) {
      if (!_isRunActive(runId)) return;
      widget.onInstructionChange?.call('');
      widget.onExecutionStateChanged?.call(false);
      return;
    }

    if (!_isRunActive(runId)) return;
    widget.onExecutionStateChanged?.call(true);

    for (final instruction in expandedInstructions) {
      if (!_isRunActive(runId)) return;
      widget.onInstructionChange?.call(instruction);

      final canContinue = await _waitFor(
        const Duration(milliseconds: 600),
        runId,
        allowPause: true,
      );
      if (!canContinue || !_isRunActive(runId)) return;

      bool stateChanged = false;

      setState(() {
        final inst = _normalizeInstruction(instruction);
        double angle = _radians(rotation - 90);
        previousWorldPosition = worldPosition;
        bool moved = false;
        bool markInstructionStart = false;
        String? instructionMarkerLabel;

        if (inst.contains("avanzar")) {
          stateChanged = true;
          markInstructionStart = true;
          instructionMarkerLabel =
              "Avanzar ${_instructionValue(instruction)} cm";
          worldPosition = worldPosition.translate(
            _gridCellSize * cos(angle),
            _gridCellSize * sin(angle),
          );
          moved = true;
        } else if (inst.contains("retroceder")) {
          stateChanged = true;
          markInstructionStart = true;
          instructionMarkerLabel =
              "Retroceder ${_instructionValue(instruction)} cm";
          worldPosition = worldPosition.translate(
            -_gridCellSize * cos(angle),
            -_gridCellSize * sin(angle),
          );
          moved = true;
        } else if (inst.contains("girar")) {
          final match = RegExp(r'(\d+)', caseSensitive: false).firstMatch(inst);

          if (match != null) {
            final degrees = double.parse(match.group(1)!);
            previousRotation = rotation;

            if (inst.contains("izquierda")) {
              stateChanged = true;
              markInstructionStart = true;
              instructionMarkerLabel =
                  "Girar a la izquierda ${_formatDegrees(degrees)}°";
              rotation -= degrees;
            } else if (inst.contains("derecha")) {
              stateChanged = true;
              markInstructionStart = true;
              instructionMarkerLabel =
                  "Girar a la derecha ${_formatDegrees(degrees)}°";
              rotation += degrees;
            }
          }
        } else if (inst.contains("lapiz activado")) {
          stateChanged = true;
          markInstructionStart = true;
          instructionMarkerLabel = "Lápiz activado";
          penActive = true;
        } else if (inst.contains("lapiz desactivado")) {
          stateChanged = true;
          markInstructionStart = true;
          instructionMarkerLabel = "Lápiz desactivado";
          penActive = false;
        } else if (inst.contains("deteccion iniciada")) {
          stateChanged = true;
          markInstructionStart = true;
          instructionMarkerLabel = "Detección de objetos activada";
          obstacleDetectionActive = true;
        } else if (inst.contains("deteccion finalizada")) {
          stateChanged = true;
          markInstructionStart = true;
          instructionMarkerLabel = "Detección de objetos desactivada";
          obstacleDetectionActive = false;
        }

        if (markInstructionStart && instructionMarkerLabel != null) {
          _addInstructionMarker(previousWorldPosition, instructionMarkerLabel);
        }

        if (moved) {
          _addTrailSegment(previousWorldPosition, worldPosition);
        }
      });

      if (stateChanged) {
        final completedAnimation = await _waitFor(
          const Duration(milliseconds: 400),
          runId,
        );
        if (!completedAnimation || !_isRunActive(runId)) return;
      }
    }

    final finishedCleanly = await _waitFor(
      const Duration(milliseconds: 50),
      runId,
    );
    if (!finishedCleanly || !_isRunActive(runId)) return;

    widget.onExecutionStateChanged?.call(false);
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

  bool _isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  double _gridCellSizeFor(BuildContext context, Size size) {
    if (!_isTablet(context)) return _defaultGridCellSize;
    return max(_tabletMinGridCellSize, size.width / _tabletColumns);
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

      if ((tapPosition - markerPosition).distance <= _gridCellSize * 0.5) {
        return i;
      }
    }

    return null;
  }

  List<_InstructionMarker> _markersAtPosition(Offset position) {
    return instructionMarkers
        .where((marker) => (marker.position - position).distance < 0.01)
        .toList();
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
        _gridCellSize = _gridCellSizeFor(context, size);
        final objectSize = _gridCellSize * 2;
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
                            cellSize: _gridCellSize,
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
                            markers: _markersAtPosition(instructionMarkers[
                                    selectedInstructionMarkerIndex!]
                                .position),
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

  final List<_InstructionMarker> markers;
  final Offset position;
  final Size canvasSize;

  const _InstructionMarkerTooltip({
    required this.markers,
    required this.position,
    required this.canvasSize,
  });

  @override
  Widget build(BuildContext context) {
    final estimatedHeight = 24.0 + (markers.length * 26.0);
    final tooltipWidth = min(_width, max(80.0, canvasSize.width - 16.0));
    final maxLeft = max(8.0, canvasSize.width - tooltipWidth - 8.0);
    final left =
        (position.dx - (tooltipWidth / 2)).clamp(8.0, maxLeft).toDouble();
    final hasSpaceAbove = position.dy > estimatedHeight + 18;
    final rawTop =
        hasSpaceAbove ? position.dy - estimatedHeight - 12 : position.dy + 12;
    final maxTop = max(8.0, canvasSize.height - estimatedHeight - 8.0);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < markers.length; i++) ...[
              Row(
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
                      markers[i].label,
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
              if (i < markers.length - 1)
                const SizedBox(
                  height: 6,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PenTrailPainter extends CustomPainter {
  static const double _strokeWidth = 3;
  static const double _markerRadius = 4;
  static const double _overlapDistance = 0.01;

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

    final paintedPositions = <Offset>[];
    for (final marker in markers) {
      if (paintedPositions.any(
        (position) => (position - marker.position).distance < _overlapDistance,
      )) {
        continue;
      }

      final markerCount = markers
          .where(
            (other) =>
                (other.position - marker.position).distance < _overlapDistance,
          )
          .length;
      paintedPositions.add(marker.position);

      final screenPosition = _toScreen(marker.position, size);
      canvas.drawCircle(
        screenPosition,
        _markerRadius,
        markerPaint,
      );

      if (markerCount > 1) {
        _paintMarkerCount(canvas, screenPosition, markerCount);
      }
    }
  }

  void _paintMarkerCount(Canvas canvas, Offset markerPosition, int count) {
    final badgeCenter = markerPosition + const Offset(7, -7);
    final badgePaint = Paint()
      ..color = neutralDarkBlueAD
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final badgeBorderPaint = Paint()
      ..color = neutralWhite
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawCircle(badgeCenter, 7, badgePaint);
    canvas.drawCircle(badgeCenter, 7, badgeBorderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: count.toString(),
        style: const TextStyle(
          color: neutralWhite,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      badgeCenter - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _PenTrailPainter oldDelegate) {
    return oldDelegate.segmentCount != segmentCount ||
        oldDelegate.markerCount != markerCount ||
        oldDelegate.worldPosition != worldPosition ||
        oldDelegate.targetWorldPosition != targetWorldPosition;
  }
}
