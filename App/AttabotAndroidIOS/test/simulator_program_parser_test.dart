import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_tec/features/commands/enums/command_types.dart';
import 'package:proyecto_tec/features/simulator/services/simulator_program_parser.dart';

void main() {
  final parser = SimulatorProgramParser();

  test('convierte un programa válido en instrucciones del simulador', () {
    final commands = parser.parse('''
      void main() {
        avanzar(18);
        repetir(2, () {
          girarDerecha(90);
          activarDeteccion();
        });
        desactivarDeteccion();
      }
    ''');

    expect(
      commands.map((command) => command.action),
      [
        CommandType.moveForward,
        CommandType.initCycle,
        CommandType.rotateRight,
        CommandType.activateObjectDetection,
        CommandType.endCycle,
        CommandType.deactivateObjectDetection,
      ],
    );
    expect(commands[0].value, 18);
    expect(commands[1].value, 2);
    expect(commands[2].value, 90);
  });

  test('rechaza una instrucción no admitida e informa la línea', () {
    expect(
      () => parser.parse('void main() {\n  volar(10);\n}'),
      throwsA(
        isA<SimulatorProgramParseException>()
            .having((error) => error.line, 'línea', 2)
            .having(
              (error) => error.message,
              'mensaje',
              'La instrucción "volar" no es válida.',
            ),
      ),
    );
  });

  test('rechaza valores fuera de los límites del simulador', () {
    expect(
      () => parser.parse('void main() { girarIzquierda(361); }'),
      throwsA(
        isA<SimulatorProgramParseException>().having(
          (error) => error.message,
          'mensaje',
          'girarIzquierda requiere un número entero entre 1 y 360.',
        ),
      ),
    );
  });
}
