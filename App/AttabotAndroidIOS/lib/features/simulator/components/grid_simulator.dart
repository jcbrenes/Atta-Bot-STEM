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
  final void Function(bool)? onCycleExecutionStateChanged;
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
    this.onCycleExecutionStateChanged,
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
  final List<Offset> cycleBoundaryMarkers = [];
  final List<_InstructionMarker> instructionMarkers = [];
  int trailSegmentCount = 0;
  int cycleBoundaryMarkerCount = 0;
  int instructionMarkerCount = 0;
  int? selectedInstructionMarkerIndex;

  static const double _defaultGridCellSize = 36;
  static const double _tabletColumns = 7;
  static const double _tabletMinGridCellSize = 68;
  static const double _centimetersPerGridCell = 20;
  static const int _movementMillisecondsPerGridCell = 400;
  static const int _rotationMillisecondsPer90Degrees = 300;
  static const Duration _defaultAnimationDuration = Duration(milliseconds: 400);
  double _gridCellSize = _defaultGridCellSize;
  int _runVersion = 0;
  Duration _currentMovementAnimationDuration = _defaultAnimationDuration;
  Duration _currentRotationAnimationDuration = _defaultAnimationDuration;

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

  List<_ExpandedInstruction> _expandCycles(
    List<String> instructions, {
    int cycleDepth = 0,
  }) {
    List<_ExpandedInstruction> output = [];
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

        final block = _expandCycles(
          instructions.sublist(i + 1, j - 1),
          cycleDepth: cycleDepth + 1,
        );

        for (int r = 0; r < repeatCount; r++) {
          for (int index = 0; index < block.length; index++) {
            output.add(
              block[index].copyWith(
                startsCycleIteration:
                    block[index].startsCycleIteration || index == 0,
                endsCycleIteration: block[index].endsCycleIteration ||
                    index == block.length - 1,
              ),
            );
          }
        }

        i = j;
      } else {
        output.add(
          _ExpandedInstruction(
            text: line,
            isInsideCycle: cycleDepth > 0,
          ),
        );
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
    widget.onCycleExecutionStateChanged?.call(false);
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
      cycleBoundaryMarkers.clear();
      instructionMarkers.clear();
      trailSegmentCount = 0;
      cycleBoundaryMarkerCount = 0;
      instructionMarkerCount = 0;
      selectedInstructionMarkerIndex = null;
      _currentMovementAnimationDuration = _defaultAnimationDuration;
      _currentRotationAnimationDuration = _defaultAnimationDuration;
    });

    widget.onInstructionChange?.call('');
    widget.onCycleExecutionStateChanged?.call(false);
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
      widget.onCycleExecutionStateChanged?.call(false);
      return;
    }

    if (!_isRunActive(runId)) return;
    widget.onExecutionStateChanged?.call(true);

    for (final expandedInstruction in expandedInstructions) {
      final instruction = expandedInstruction.text;
      if (!_isRunActive(runId)) return;
      widget.onInstructionChange?.call(instruction);
      widget.onCycleExecutionStateChanged
          ?.call(expandedInstruction.isInsideCycle);

      final canContinue = await _waitFor(
        const Duration(milliseconds: 600),
        runId,
        allowPause: true,
      );
      if (!canContinue || !_isRunActive(runId)) return;

      bool stateChanged = false;
      var animationDuration = _defaultAnimationDuration;

      setState(() {
        final inst = _normalizeInstruction(instruction);
        double angle = _radians(rotation - 90);
        previousWorldPosition = worldPosition;
        final instructionStartPosition = previousWorldPosition;
        bool moved = false;
        bool markInstructionStart = false;
        String? instructionMarkerLabel;

        if (expandedInstruction.startsCycleIteration) {
          _addCycleBoundaryMarker(instructionStartPosition);
        }

        if (inst.contains("avanzar")) {
          stateChanged = true;
          markInstructionStart = true;
          instructionMarkerLabel =
              "Avanzar ${_instructionValue(instruction)} cm";
          animationDuration = _movementAnimationDuration(instruction);
          _currentMovementAnimationDuration = animationDuration;
          final distanceInPixels =
              _gridCellSize * _instructionGridUnits(instruction);
          worldPosition = worldPosition.translate(
            distanceInPixels * cos(angle),
            distanceInPixels * sin(angle),
          );
          moved = true;
        } else if (inst.contains("retroceder")) {
          stateChanged = true;
          markInstructionStart = true;
          instructionMarkerLabel =
              "Retroceder ${_instructionValue(instruction)} cm";
          animationDuration = _movementAnimationDuration(instruction);
          _currentMovementAnimationDuration = animationDuration;
          final distanceInPixels =
              _gridCellSize * _instructionGridUnits(instruction);
          worldPosition = worldPosition.translate(
            -distanceInPixels * cos(angle),
            -distanceInPixels * sin(angle),
          );
          moved = true;
        } else if (inst.contains("girar")) {
          final match = RegExp(r'(\d+)', caseSensitive: false).firstMatch(inst);

          if (match != null) {
            final degrees = double.parse(match.group(1)!);
            previousRotation = rotation;
            animationDuration = _rotationAnimationDuration(degrees);
            _currentRotationAnimationDuration = animationDuration;

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
          _addTrailSegment(
            previousWorldPosition,
            worldPosition,
            penWasActive: penActive,
          );
        }

        if (expandedInstruction.endsCycleIteration) {
          _addCycleBoundaryMarker(worldPosition);
        }
      });

      if (stateChanged) {
        final completedAnimation = await _waitFor(animationDuration, runId);
        if (!completedAnimation || !_isRunActive(runId)) return;
      }
    }

    final finishedCleanly = await _waitFor(
      const Duration(milliseconds: 50),
      runId,
    );
    if (!finishedCleanly || !_isRunActive(runId)) return;

    widget.onInstructionChange?.call('Ciclo cerrado');
    widget.onCycleExecutionStateChanged?.call(false);
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

  double _instructionGridUnits(String instruction) {
    final match = RegExp(r'(\d+(?:[\.,]\d+)?)').firstMatch(instruction);
    if (match == null) return 1;

    final value = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    if (value == null) return 1;

    return value / _centimetersPerGridCell;
  }

  Duration _movementAnimationDuration(String instruction) {
    final gridUnits = _instructionGridUnits(instruction);
    final milliseconds =
        max(1, (gridUnits * _movementMillisecondsPerGridCell).round());
    return Duration(milliseconds: milliseconds);
  }

  Duration _rotationAnimationDuration(double degrees) {
    final milliseconds =
        max(1, ((degrees / 90) * _rotationMillisecondsPer90Degrees).round());
    return Duration(milliseconds: milliseconds);
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

  void _addCycleBoundaryMarker(Offset position) {
    for (final marker in cycleBoundaryMarkers) {
      if ((marker - position).distance < 0.01) {
        return;
      }
    }

    cycleBoundaryMarkers.add(position);
    cycleBoundaryMarkerCount++;
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

  void _addTrailSegment(
    Offset start,
    Offset end, {
    required bool penWasActive,
  }) {
    if (start == end) return;

    trailSegments.add(
      _TrailSegment(
        start: start,
        end: end,
        penActive: penWasActive,
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
        const gridLineColor = Color(0xFFC8CDD8);

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD5DBE8),
              width: 1.2,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              TweenAnimationBuilder<Offset>(
                tween: Tween<Offset>(
                  begin: previousWorldPosition,
                  end: worldPosition,
                ),
                duration: _currentMovementAnimationDuration,
                builder: (context, animatedWorldPosition, child) {
                  return SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRect(
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
                                  cycleBoundaryMarkers: cycleBoundaryMarkers,
                                  cycleBoundaryMarkerCount:
                                      cycleBoundaryMarkerCount,
                                  markers: instructionMarkers,
                                  markerCount: instructionMarkerCount,
                                  worldPosition: animatedWorldPosition,
                                  targetWorldPosition: worldPosition,
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTapDown: (details) {
                                  final markerIndex =
                                      _findTappedInstructionMarker(
                                    details.localPosition,
                                    size,
                                    animatedWorldPosition,
                                  );

                                  setState(() {
                                    selectedInstructionMarkerIndex =
                                        markerIndex;
                                  });
                                },
                                child: SizedBox(
                                  width: size.width,
                                  height: size.height,
                                ),
                              ),
                            ],
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
                  duration: _currentRotationAnimationDuration,
                  builder: (context, angleDegrees, child) {
                    return SizedBox(
                      width: objectSize,
                      height: objectSize,
                      child: ObjectSimulator(
                        size: objectSize,
                        useImage: widget.useImage,
                        botImagePath: widget.botImagePath ?? '',
                        penActive: penActive,
                        obstacleDetectionActive: obstacleDetectionActive,
                        rotationRadians: _radians(angleDegrees),
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
      },
    );
  }
}

class _ExpandedInstruction {
  final String text;
  final bool isInsideCycle;
  final bool startsCycleIteration;
  final bool endsCycleIteration;

  const _ExpandedInstruction({
    required this.text,
    required this.isInsideCycle,
    this.startsCycleIteration = false,
    this.endsCycleIteration = false,
  });

  _ExpandedInstruction copyWith({
    String? text,
    bool? isInsideCycle,
    bool? startsCycleIteration,
    bool? endsCycleIteration,
  }) {
    return _ExpandedInstruction(
      text: text ?? this.text,
      isInsideCycle: isInsideCycle ?? this.isInsideCycle,
      startsCycleIteration: startsCycleIteration ?? this.startsCycleIteration,
      endsCycleIteration: endsCycleIteration ?? this.endsCycleIteration,
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
      ..strokeWidth = 2.35
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
  final bool penActive;

  const _TrailSegment({
    required this.start,
    required this.end,
    required this.penActive,
  });

  Color get color => penActive ? secondaryPurple : primaryBlue;
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
  static const double _defaultWidth = 170;
  static const double _wideWidth = 220;

  final List<_InstructionMarker> markers;
  final Offset position;
  final Size canvasSize;

  const _InstructionMarkerTooltip({
    required this.markers,
    required this.position,
    required this.canvasSize,
  });

  ({
    IconData icon,
    Color color,
    double width,
    String? assetPath,
  }) _styleForLabel(String label) {
    final normalized = label
        .toLowerCase()
        .replaceAll(RegExp(r'[\u00e1\u00e0\u00e4\u00e2\u00e3]'), 'a')
        .replaceAll(RegExp(r'[\u00e9\u00e8\u00eb\u00ea]'), 'e')
        .replaceAll(RegExp(r'[\u00ed\u00ec\u00ef\u00ee]'), 'i')
        .replaceAll(RegExp(r'[\u00f3\u00f2\u00f6\u00f4\u00f5]'), 'o')
        .replaceAll(RegExp(r'[\u00fa\u00f9\u00fc\u00fb]'), 'u')
        .replaceAll('\u00f1', 'n');
    if (normalized.contains('girar') && normalized.contains('izquierda')) {
      return (
        icon: Icons.turn_left_rounded,
        color: primaryOrange,
        width: _defaultWidth,
        assetPath: null,
      );
    }
    if (normalized.contains('girar') && normalized.contains('derecha')) {
      return (
        icon: Icons.turn_right_rounded,
        color: primaryOrange,
        width: _defaultWidth,
        assetPath: null,
      );
    }
    if (normalized.contains('avanzar')) {
      return (
        icon: Icons.arrow_upward_rounded,
        color: primaryBlue,
        width: _defaultWidth,
        assetPath: null,
      );
    }
    if (normalized.contains('retroceder')) {
      return (
        icon: Icons.arrow_downward_rounded,
        color: primaryBlue,
        width: _defaultWidth,
        assetPath: null,
      );
    }
    if (normalized.contains('lapiz')) {
      return (
        icon: Icons.edit_rounded,
        color: secondaryPurple,
        width: _defaultWidth,
        assetPath: 'assets/button_icons/pencil.png',
      );
    }
    if (normalized.contains('deteccion')) {
      return (
        icon: Icons.visibility_outlined,
        color: primaryYellow,
        width: _wideWidth,
        assetPath: 'assets/button_icons/obstacle_detection.png',
      );
    }
    return (
      icon: Icons.circle_rounded,
      color: primaryOrange,
      width: _defaultWidth,
      assetPath: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    const rowHeight = 58.0;
    const rowGap = 10.0;
    final estimatedHeight =
        (markers.length * rowHeight) + ((markers.length - 1) * rowGap);
    final maxRequestedWidth = markers.fold<double>(
      _defaultWidth,
      (currentMax, marker) => max(currentMax, _styleForLabel(marker.label).width),
    );
    final tooltipWidth = min(
      maxRequestedWidth,
      max(140.0, canvasSize.width - 20.0),
    );
    final rightCandidate = position.dx + 12;
    final leftCandidate = position.dx - tooltipWidth - 12;
    final canShowRight = rightCandidate + tooltipWidth <= canvasSize.width - 8;
    final left = canShowRight
        ? rightCandidate
        : leftCandidate.clamp(8.0, canvasSize.width - tooltipWidth - 8.0)
              .toDouble();
    final maxTop = max(8.0, canvasSize.height - estimatedHeight - 8.0);
    final top =
        (position.dy - (estimatedHeight / 2)).clamp(8.0, maxTop).toDouble();
    const borderColor = Color(0xFF7E8CAA);
    const fillColor = Color(0xFFF7F8FC);

    return Positioned(
      left: left,
      top: top,
      width: tooltipWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < markers.length; i++) ...[
            Builder(
              builder: (context) {
                final style = _styleForLabel(markers[i].label);
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: rowHeight,
                      maxWidth: tooltipWidth,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: fillColor,
                      border: Border.all(color: borderColor, width: 2.2),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: style.assetPath != null
                              ? Image.asset(
                                  style.assetPath!,
                                  width: 23,
                                  height: 23,
                                  color: style.color,
                                )
                              : Icon(
                                  style.icon,
                                  color: style.color,
                                  size: 23,
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            markers[i].label,
                            style: const TextStyle(
                              color: neutralDarkBlueAD,
                              fontFamily: 'Poppins',
                              fontSize: 12.8,
                              fontWeight: FontWeight.w600,
                              height: 1.15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (i < markers.length - 1) const SizedBox(height: rowGap),
          ],
        ],
      ),
    );
  }
}

class _PenTrailPainter extends CustomPainter {
  static const double _strokeWidth = 5;
  static const double _endpointRadius = 5.5;
  static const double _markerRadius = 7;
  static const double _cycleBoundaryRadius = 7.5;
  static const double _overlapDistance = 0.01;
  static const double _dashLength = 13;
  static const double _dashGap = 7;

  final List<_TrailSegment> segments;
  final int segmentCount;
  final List<Offset> cycleBoundaryMarkers;
  final int cycleBoundaryMarkerCount;
  final List<_InstructionMarker> markers;
  final int markerCount;
  final Offset worldPosition;
  final Offset targetWorldPosition;

  _PenTrailPainter({
    required this.segments,
    required this.segmentCount,
    required this.cycleBoundaryMarkers,
    required this.cycleBoundaryMarkerCount,
    required this.markers,
    required this.markerCount,
    required this.worldPosition,
    required this.targetWorldPosition,
  });

  Offset _toScreen(Offset world, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    return center + (world - worldPosition);
  }

  bool _hasCycleBoundary(Offset position) {
    return cycleBoundaryMarkers.any(
      (marker) => (marker - position).distance < _overlapDistance,
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    final delta = end - start;
    final distance = delta.distance;
    if (distance == 0) return;

    final direction = delta / distance;
    double currentDistance = 0;

    while (currentDistance < distance) {
      final segmentStart = start + (direction * currentDistance);
      final segmentEnd =
          start + (direction * min(currentDistance + _dashLength, distance));
      canvas.drawLine(segmentStart, segmentEnd, paint);
      currentDistance += _dashLength + _dashGap;
    }
  }

  void _drawSegmentEndpoint(
    Canvas canvas,
    Size size,
    Offset worldPoint,
    Color color,
  ) {
    final screenPoint = _toScreen(worldPoint, size);
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final borderPaint = Paint()
      ..color = neutralWhite
      ..strokeWidth = 1.7
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawCircle(screenPoint, _endpointRadius, fillPaint);
    canvas.drawCircle(screenPoint, _endpointRadius, borderPaint);

    if (_hasCycleBoundary(worldPoint)) {
      final cycleFillPaint = Paint()
        ..color = secondaryGreen.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      final cycleBorderPaint = Paint()
        ..color = secondaryGreen
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true;

      canvas.drawCircle(screenPoint, _cycleBoundaryRadius, cycleFillPaint);
      canvas.drawCircle(screenPoint, _cycleBoundaryRadius, cycleBorderPaint);
    }
  }

  void _drawStandaloneCycleBoundary(
    Canvas canvas,
    Size size,
    Offset worldPoint,
  ) {
    final screenPoint = _toScreen(worldPoint, size);
    final fillPaint = Paint()
      ..color = secondaryGreen.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final borderPaint = Paint()
      ..color = secondaryGreen
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawCircle(screenPoint, _cycleBoundaryRadius, fillPaint);
    canvas.drawCircle(screenPoint, _cycleBoundaryRadius, borderPaint);
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
      final endWorldPosition =
          i == segments.length - 1 && segment.end == targetWorldPosition
              ? worldPosition
              : segment.end;
      final start = _toScreen(segment.start, size);
      final end = _toScreen(endWorldPosition, size);
      trailPaint.color = segment.color;

      if (segment.penActive) {
        canvas.drawLine(start, end, trailPaint);
      } else {
        _drawDashedLine(canvas, start, end, trailPaint);
      }

      _drawSegmentEndpoint(canvas, size, segment.start, segment.color);
      _drawSegmentEndpoint(canvas, size, segment.end, segment.color);
    }

    for (final cycleBoundaryMarker in cycleBoundaryMarkers) {
      final isSegmentEndpoint = segments.any(
        (segment) =>
            (segment.start - cycleBoundaryMarker).distance < _overlapDistance ||
            (segment.end - cycleBoundaryMarker).distance < _overlapDistance,
      );

      if (!isSegmentEndpoint) {
        _drawStandaloneCycleBoundary(canvas, size, cycleBoundaryMarker);
      }
    }

    final markerPaint = Paint()
      ..color = primaryOrange
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final markerBorderPaint = Paint()
      ..color = const Color(0xFFFFE1D2)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final paintedPositions = <Offset>[];
    for (final marker in markers) {
      if (paintedPositions.any(
        (position) => (position - marker.position).distance < _overlapDistance,
      )) {
        continue;
      }

      paintedPositions.add(marker.position);

      final screenPosition = _toScreen(marker.position, size);
      canvas.drawCircle(
        screenPosition,
        _markerRadius,
        markerPaint,
      );
      canvas.drawCircle(
        screenPosition,
        _markerRadius,
        markerBorderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PenTrailPainter oldDelegate) {
    return oldDelegate.segmentCount != segmentCount ||
        oldDelegate.cycleBoundaryMarkerCount != cycleBoundaryMarkerCount ||
        oldDelegate.markerCount != markerCount ||
        oldDelegate.worldPosition != worldPosition ||
        oldDelegate.targetWorldPosition != targetWorldPosition;
  }
}