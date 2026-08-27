import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_tec/features/simulator/components/grid_simulator.dart';

Finder get _gridPainterFinder => find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint && widget.painter is GridBackgroundPainter,
    );

Offset _gridOffset(WidgetTester tester) {
  final customPaint = tester.widget<CustomPaint>(_gridPainterFinder);
  return (customPaint.painter! as GridBackgroundPainter).offset;
}

Widget _buildSimulation({
  required bool paused,
  required int stopSignal,
}) {
  return MaterialApp(
    home: Center(
      child: SizedBox(
        width: 180,
        height: 180,
        child: SimulationArea(
          instructions: const ['Avanzar 180 cm'],
          paused: paused,
          stopSignal: stopSignal,
        ),
      ),
    ),
  );
}

Future<void> _startLongMovement(WidgetTester tester) async {
  for (int i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  testWidgets('pause freezes and resume continues an active movement',
      (tester) async {
    await tester.pumpWidget(_buildSimulation(paused: false, stopSignal: 0));
    await _startLongMovement(tester);

    final offsetBeforePause = _gridOffset(tester);
    expect(offsetBeforePause, isNot(Offset.zero));

    await tester.pumpWidget(_buildSimulation(paused: true, stopSignal: 0));
    await tester.pump(const Duration(milliseconds: 500));
    expect(_gridOffset(tester), offsetBeforePause);

    await tester.pumpWidget(_buildSimulation(paused: false, stopSignal: 0));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_gridOffset(tester), isNot(offsetBeforePause));

    await tester.pumpWidget(_buildSimulation(paused: false, stopSignal: 1));
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('stop freezes an active movement at its current position',
      (tester) async {
    await tester.pumpWidget(_buildSimulation(paused: false, stopSignal: 0));
    await _startLongMovement(tester);

    await tester.pumpWidget(_buildSimulation(paused: false, stopSignal: 1));
    await tester.pump(const Duration(milliseconds: 50));
    final offsetAfterStop = _gridOffset(tester);

    await tester.pump(const Duration(milliseconds: 500));
    expect(_gridOffset(tester), offsetAfterStop);
  });
}
