import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/enums/command_types.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/features/simulator/components/grid_simulator.dart';
import 'package:proyecto_tec/pages/bot_control_page.dart';
import 'package:proyecto_tec/pages/landing_page.dart';
import 'package:proyecto_tec/pages/simulator_page.dart';

class FakeFilePicker extends FilePicker {
  FakeFilePicker(this.result);

  final FilePickerResult? result;
  FileType? requestedType;
  List<String>? requestedExtensions;
  int pickCount = 0;

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
    pickCount++;
    requestedExtensions = allowedExtensions;
    return result;
  }
}

Widget buildTestApp(
  CommandService commandService, {
  Widget home = const SimulatorPage(),
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: commandService),
      ChangeNotifierProvider(create: (_) => SimplifiedModeProvider()),
    ],
    child: MaterialApp(home: home),
  );
}

Future<void> disposeSimulator(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 60));
}

Future<void> selectBackground(WidgetTester tester, String option) async {
  await tester.tap(find.text('Cargar imagen'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(option));
  await tester.pumpAndSettle();
  final imageMenu =
      find.byWidgetPredicate((widget) => widget is PopupMenuButton);
  // Image codecs complete on the engine thread rather than fake test time.
  for (var i = 0; i < 100; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
    if (tester.widget<PopupMenuButton>(imageMenu).enabled) return;
  }
  fail('Timed out loading the background image');
}

void main() {
  tearDown(() => FilePicker.platform = FakeFilePicker(null));

  testWidgets('conserva la imagen y la casilla al cambiar de pestaña',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1340);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      buildTestApp(CommandService(), home: const LandingPage()),
    );
    await tester.pumpAndSettle();

    Future<void> selectTab(int index) async {
      final navigation =
          tester.widget<NavigationBar>(find.byType(NavigationBar));
      navigation.onDestinationSelected!(index);
      await tester.pumpAndSettle();
    }

    final checkbox = find.byType(Checkbox);
    SimulationArea simulation() =>
        tester.widget<SimulationArea>(find.byType(SimulationArea));

    await selectTab(9);
    expect(tester.widget<Checkbox>(checkbox).value, isFalse);
    await selectBackground(tester, 'Usar mapa de la granja');
    await tester.tap(checkbox);
    await tester.pumpAndSettle();
    final image = simulation().backgroundImage;
    expect(image, isNotNull);

    await selectTab(8);
    expect(find.text('Instrucciones'), findsOneWidget);
    await selectTab(7);
    expect(find.byType(SimulatorPage), findsNothing);
    await selectTab(9);
    expect(tester.widget<Checkbox>(checkbox).value, isTrue);
    expect(simulation().backgroundImage, same(image));

    await tester.tap(checkbox);
    await tester.pumpAndSettle();
    await selectTab(8);
    await selectTab(9);
    expect(tester.widget<Checkbox>(checkbox).value, isFalse);
    expect(simulation().backgroundImage, isNull);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();
    expect(simulation().backgroundImage, same(image));
  });

  testWidgets('oculta y recupera el fondo sin abrir otra vez el explorador',
      (tester) async {
    final commandService = CommandService()..moveForward(180);
    final imageData = await rootBundle.load('assets/button_icons/cycle.png');
    final imageBytes = imageData.buffer.asUint8List(
      imageData.offsetInBytes,
      imageData.lengthInBytes,
    );
    final picker = FakeFilePicker(FilePickerResult([
      PlatformFile(
          name: 'circuito.png', size: imageBytes.length, bytes: imageBytes),
    ]));
    FilePicker.platform = picker;
    await tester.pumpWidget(buildTestApp(commandService));
    await tester.pump();
    for (var i = 0; i < 16; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.tap(find.byTooltip('Pausar'));
    await tester.pump();
    final gridFinder = find.byWidgetPredicate((widget) =>
        widget is CustomPaint && widget.painter is GridBackgroundPainter);
    Offset gridOffset() => (tester.widget<CustomPaint>(gridFinder).painter!
            as GridBackgroundPainter)
        .offset;
    final positionBefore = gridOffset();
    expect(positionBefore, isNot(Offset.zero));
    final checkbox = find.byType(Checkbox);
    SimulationArea simulation() =>
        tester.widget<SimulationArea>(find.byType(SimulationArea));
    expect(tester.widget<Checkbox>(checkbox).value, isFalse);
    await tester.tap(find.text('Mostrar imagen'));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(checkbox).value, isFalse);
    expect(find.text('Primero carga una imagen de fondo'), findsOneWidget);
    expect(simulation().backgroundImage, isNull);

    await selectBackground(tester, 'Elegir archivo');
    expect(picker.requestedType, FileType.image);
    expect(tester.widget<Checkbox>(checkbox).value, isFalse);
    expect(simulation().backgroundImage, isNull);
    await tester.tap(checkbox);
    await tester.pump();
    expect(tester.widget<Checkbox>(checkbox).value, isTrue);
    final image = simulation().backgroundImage;
    expect(image, isNotNull);
    await tester.tap(checkbox);
    await tester.pump();
    expect(simulation().backgroundImage, isNull);
    await tester.tap(checkbox);
    await tester.pump();
    expect(simulation().backgroundImage, same(image));
    await selectBackground(tester, 'Usar mapa de la granja');
    final farmTile = simulation().backgroundImage!;
    expect(farmTile.width, 673);
    expect(farmTile.height, 894);
    expect(picker.pickCount, 1);
    expect(gridOffset(), positionBefore);
    expect(tester.widget<SimulationArea>(find.byType(SimulationArea)).paused,
        isTrue);
    await disposeSimulator(tester);
  });

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
