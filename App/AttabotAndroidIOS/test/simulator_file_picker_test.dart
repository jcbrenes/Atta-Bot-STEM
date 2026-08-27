import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
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

Widget buildTestApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => CommandService()),
      ChangeNotifierProvider(create: (_) => SimplifiedModeProvider()),
    ],
    child: const MaterialApp(home: SimulatorPage()),
  );
}

void main() {
  testWidgets('solo acepta archivos dart del explorador', (tester) async {
    final dartPicker = FakeFilePicker(
      FilePickerResult([
        PlatformFile(
            name: 'programa.dart', size: 20, path: '/tmp/programa.dart'),
      ]),
    );
    FilePicker.platform = dartPicker;

    await tester.pumpWidget(buildTestApp());
    await tester.pump();
    await tester.tap(find.byKey(const Key('select-dart-file')));
    await tester.pumpAndSettle();

    expect(dartPicker.requestedType, FileType.custom);
    expect(dartPicker.requestedExtensions, ['dart']);
    expect(find.text('programa.dart'), findsOneWidget);
  });

  testWidgets('rechaza una extension que el sistema devuelva por error',
      (tester) async {
    FilePicker.platform = FakeFilePicker(
      FilePickerResult([
        PlatformFile(name: 'programa.txt', size: 20, path: '/tmp/programa.txt'),
      ]),
    );

    await tester.pumpWidget(buildTestApp());
    await tester.pump();
    await tester.tap(find.byKey(const Key('select-dart-file')));
    await tester.pumpAndSettle();

    expect(find.text('Solo puedes seleccionar archivos .dart'), findsOneWidget);
    expect(find.text('Seleccionar archivo .dart'), findsOneWidget);
  });
}
