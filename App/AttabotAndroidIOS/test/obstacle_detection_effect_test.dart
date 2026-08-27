import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_tec/features/simulator/components/grid_simulator.dart';
import 'package:proyecto_tec/features/simulator/components/object_simulator.dart';

Finder get _glowPainterFinder => find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint && widget.painter is FlashlightGlowPainter,
    );

FlashlightGlowPainter _glowPainter(WidgetTester tester) {
  final customPaint = tester.widget<CustomPaint>(_glowPainterFinder);
  return customPaint.painter! as FlashlightGlowPainter;
}

Widget _buildSimulation({
  required List<String> instructions,
  required int stopSignal,
}) {
  return MaterialApp(
    home: Center(
      child: SizedBox(
        width: 180,
        height: 180,
        child: SimulationArea(
          instructions: instructions,
          paused: false,
          stopSignal: stopSignal,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('the obstacle detection beam pulses while active',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: ObjectSimulator(
              size: 40,
              obstacleDetectionActive: true,
            ),
          ),
        ),
      ),
    );

    final initialBeamWidth = _glowPainter(tester).beamWidth;
    await tester.pump(const Duration(milliseconds: 300));

    expect(_glowPainterFinder, findsOneWidget);
    expect(_glowPainter(tester).beamWidth, isNot(initialBeamWidth));
  });

  testWidgets('stopping the simulation turns off obstacle detection',
      (tester) async {
    const instructions = ['Detección iniciada'];

    await tester.pumpWidget(
      _buildSimulation(instructions: instructions, stopSignal: 0),
    );
    for (int i = 0; i < 14; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(_glowPainterFinder, findsOneWidget);

    await tester.pumpWidget(
      _buildSimulation(instructions: instructions, stopSignal: 1),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(_glowPainterFinder, findsNothing);
  });
}
