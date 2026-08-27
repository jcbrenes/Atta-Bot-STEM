import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/enums/command_types.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/pages/bot_control_page.dart';
import 'package:proyecto_tec/pages/simulator_page.dart';

class FakeFilePicker extends FilePicker {
  FakeFilePicker(this.result);

  final FilePickerResult? result;
  FileType? requestedType;
  List<String>? requestedExtensions;

  @override
  Future<FilePickerResult?> pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool allowCompression = true,
    int compressionQuality = 30,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileLoading,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    requestedType = type;
    requestedExtensions = allowedExtensions;
    return result;
  }
}

Widget buildTestApp(CommandService commandService) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: commandService),
      ChangeNotifierProvider(create: (_) => SimplifiedModeProvider()),
    ],
    child: const MaterialApp(home: SimulatorPage()),
  );
}

Future<void> disposeSimulator(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 60));
}

void main() {
  testWidgets('solo acepta archivos dart del explorador', (tester) async {
    final commandService = CommandService();
    final dartPicker = FakeFilePicker(
      FilePickerResult([
        PlatformFile(
          name: 'programa.dart',
          size: 31,
          bytes: Uint8List.fromList(
            utf8.encode('void main() { avanzar(18); }'),
          ),
          path: '/tmp/programa.dart',
        ),
      ]),
    );
    FilePicker.platform = dartPicker;

    await tester.pumpWidget(buildTestApp(commandService));
    await tester.pump();
    await tester.tap(find.byKey(const Key('select-dart-file')));
    await tester.pump();
    await tester.pump();

    expect(dartPicker.requestedType, FileType.any);
    expect(dartPicker.requestedExtensions, isNull);
    expect(find.text('programa.dart'), findsOneWidget);
    expect(commandService.commandHistory, hasLength(1));
    expect(
      commandService.commandHistory.single.action,
      CommandType.moveForward,
    );

    await disposeSimulator(tester);
  });

  testWidgets('rechaza una extension que el sistema devuelva por error',
      (tester) async {
    final commandService = CommandService();
    FilePicker.platform = FakeFilePicker(
      FilePickerResult([
        PlatformFile(name: 'programa.txt', size: 20, path: '/tmp/programa.txt'),
      ]),
    );

    await tester.pumpWidget(buildTestApp(commandService));
    await tester.pump();
    await tester.tap(find.byKey(const Key('select-dart-file')));
    await tester.pumpAndSettle();

    expect(find.text('Solo puedes seleccionar archivos .dart'), findsOneWidget);
    expect(find.text('Seleccionar archivo .dart'), findsOneWidget);

    await disposeSimulator(tester);
  });

  testWidgets('informa la línea y conserva las instrucciones si no es válido',
      (tester) async {
    final commandService = CommandService()..moveForward(18);
    FilePicker.platform = FakeFilePicker(
      FilePickerResult([
        PlatformFile(
          name: 'programa.dart',
          size: 35,
          bytes: Uint8List.fromList(
            utf8.encode('void main() {\n  volar(10);\n}'),
          ),
          path: '/tmp/programa.dart',
        ),
      ]),
    );

    await tester.pumpWidget(buildTestApp(commandService));
    await tester.pump();
    await tester.tap(find.byKey(const Key('select-dart-file')));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Error en línea 2: La instrucción "volar" no es válida.'),
      findsOneWidget,
    );
    expect(commandService.commandHistory, hasLength(1));
    expect(
      commandService.commandHistory.single.action,
      CommandType.moveForward,
    );
    expect(find.text('Seleccionar archivo .dart'), findsOneWidget);

    await disposeSimulator(tester);
  });
}
