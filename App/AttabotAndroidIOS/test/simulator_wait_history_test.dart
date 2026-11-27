import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_tec/features/commands/enums/command_types.dart';
import 'package:proyecto_tec/features/commands/models/command.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/features/simulator/dialogs/simulator_actions_dialog.dart';
import 'package:provider/provider.dart';

void main() {
  test('wait survives saving but cannot be sent to current robot firmware', () {
    final service = CommandService()
      ..loadCommands(
          ['AV018', Command(CommandType.wait, null).toBotString(), 'RE018']);
    expect(service.commandHistory[1].action, CommandType.wait);
    expect(service.hasSimulatorOnlyCommands, isTrue);
    expect(service.getCommandsBotString, throwsStateError);
  });

  testWidgets(
      'inserts wait at chosen position and applies only on confirmation',
      (tester) async {
    final service = CommandService()
      ..moveForward(18)
      ..rotateRight(90);
    List<Command>? result;
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: service,
        child: MaterialApp(
          home: Builder(
              builder: (context) => Scaffold(
                    body: TextButton(
                      onPressed: () async {
                        result = await showSimulatorActionsDialog(context);
                      },
                      child: const Text('Abrir'),
                    ),
                  )),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('insert-wait-1')));
    await tester.pump();
    expect(service.commandHistory, hasLength(2));
    await tester.tap(find.text('Aplicar y reiniciar'));
    await tester.pumpAndSettle();
    expect(result!.map((command) => command.action), [
      CommandType.moveForward,
      CommandType.wait,
      CommandType.rotateRight,
    ]);

    result = null;
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('insert-wait-0')));
    await tester.pump();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(service.commandHistory, hasLength(2));
  });
}
