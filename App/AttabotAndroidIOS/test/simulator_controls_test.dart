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
  List<String> instructions = const ['Avanzar 180 cm'],
  ValueChanged<String>? onInstructionChange,
  int restartSignal = 0,
}) {
  return MaterialApp(
    home: Center(
      child: SizedBox(
        width: 180,
        height: 180,
        child: SimulationArea(
          instructions: instructions,
          paused: paused,
          stopSignal: stopSignal,
          restartSignal: restartSignal,
          onInstructionChange: onInstructionChange,
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
  Future<void> elapse(WidgetTester tester, int milliseconds) async {
    for (var elapsed = 0; elapsed < milliseconds; elapsed += 50) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('wait lasts 5 active seconds and pause preserves remaining time',
      (tester) async {
    var current = '';
    Widget simulation(bool paused) => _buildSimulation(
          paused: paused,
          stopSignal: 0,
          instructions: const ['Esperar 5 segundos', 'Avanzar 18 cm'],
          onInstructionChange: (instruction) => current = instruction,
        );
    await tester.pumpWidget(simulation(false));
    await elapse(tester, 2000);
    expect(current, 'Esperar 5 segundos');
    expect(_gridOffset(tester), Offset.zero);

    await tester.pumpWidget(simulation(true));
    await elapse(tester, 7000);
    expect(current, 'Esperar 5 segundos');
    expect(_gridOffset(tester), Offset.zero);

    await tester.pumpWidget(simulation(false));
    await elapse(tester, 2900);
    expect(current, 'Esperar 5 segundos');
    await elapse(tester, 100);
    expect(current, 'Avanzar 18 cm');
    expect(_gridOffset(tester), Offset.zero);
    await elapse(tester, 1000);
    expect(_gridOffset(tester), isNot(Offset.zero));

    await tester.pumpWidget(const SizedBox.shrink());
    await elapse(tester, 100);
  });

  testWidgets('stop cancels a wait and restart begins a fresh 5 seconds',
      (tester) async {
    var current = '';
    Widget simulation(int stop, int restart) => _buildSimulation(
          paused: false,
          stopSignal: stop,
          restartSignal: restart,
          instructions: const ['Esperar 5 segundos', 'Avanzar 18 cm'],
          onInstructionChange: (instruction) => current = instruction,
        );
    await tester.pumpWidget(simulation(0, 0));
    await elapse(tester, 2000);
    await tester.pumpWidget(simulation(1, 0));
    await elapse(tester, 6000);
    expect(current, isEmpty);
    expect(_gridOffset(tester), Offset.zero);

    await tester.pumpWidget(simulation(1, 1));
    await elapse(tester, 4900);
    expect(current, 'Esperar 5 segundos');
    await elapse(tester, 100);
    expect(current, 'Avanzar 18 cm');

    await tester.pumpWidget(const SizedBox.shrink());
    await elapse(tester, 100);
  });

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
