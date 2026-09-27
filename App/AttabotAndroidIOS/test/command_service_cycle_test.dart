import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_tec/features/commands/enums/command_types.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';

void main() {
  test('en modo simplificado la detección se activa y desactiva dentro del ciclo', () {
    final service = CommandService()..setSimplifiedMode(true);
    service.initCycleSimplified(3);
    service.activateObjectDetection();
    service.moveForward(20);
    service.deactivateObjectDetection();

    expect(service.commandHistory.map((c) => c.action).toList(), [
      CommandType.initCycle,
      CommandType.activateObjectDetection,
      CommandType.moveForward,
      CommandType.deactivateObjectDetection,
      CommandType.endCycle,
    ]);
    expect(service.obstacleDetection, isFalse);
    expect(service.getCommandsBotString(), 'ATINICI003OBINIAV020OBFINCIFINATFIN');
  });
}
