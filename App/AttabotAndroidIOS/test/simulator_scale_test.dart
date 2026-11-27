import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_tec/features/simulator/components/grid_simulator.dart';

void main() {
  test('uses the documented robot footprint for the square grid', () {
    expect(SimulatorScale.robotFootprintWidthCentimeters, 15.5);
    expect(SimulatorScale.robotFootprintLengthCentimeters, 17.8);
    expect(SimulatorScale.robotHeightCentimeters, 10.5);
    expect(SimulatorScale.gridCellCentimeters, 18);
    expect(SimulatorScale.robotFootprintCells, 1);
  });

  test('converts movement distances to grid units', () {
    expect(
      SimulatorScale.gridUnitsForCentimeters(18),
      closeTo(1, 0.0001),
    );
    expect(
      SimulatorScale.gridUnitsForCentimeters(36),
      closeTo(2, 0.0001),
    );
    expect(
      SimulatorScale.gridUnitsForCentimeters(20),
      closeTo(20 / 18, 0.0001),
    );
  });
  test('background repeats along both axes after long moves', () async {
    final tileRecorder = ui.PictureRecorder();
    final tileCanvas = ui.Canvas(tileRecorder);
    tileCanvas.drawRect(
      const ui.Rect.fromLTWH(0, 0, 4, 2),
      ui.Paint()..color = const ui.Color(0xFFFF0000),
    );
    tileCanvas.drawRect(
      const ui.Rect.fromLTWH(2, 0, 2, 2),
      ui.Paint()..color = const ui.Color(0xFF0000FF),
    );
    final tilePicture = tileRecorder.endRecording();
    final tile = await tilePicture.toImage(4, 2);
    addTearDown(tile.dispose);
    tilePicture.dispose();

    for (final offset in [const ui.Offset(8, 0), const ui.Offset(-392, 170)]) {
      final recorder = ui.PictureRecorder();
      GridBackgroundPainter(
        cellSize: 20,
        offset: offset,
        lineColor: const ui.Color(0x00000000),
        backgroundColor: const ui.Color(0xFFFFFFFF),
        backgroundImage: tile,
      ).paint(ui.Canvas(recorder), const ui.Size(20, 20));
      final picture = recorder.endRecording();
      final image = await picture.toImage(20, 20);
      final pixels = (await image.toByteData())!;
      image.dispose();
      picture.dispose();

      // The wrapped right edge has the same color as the left edge, and
      // every row is covered at the expected opacity.
      for (var y = 0; y < 20; y++) {
        for (var x = 0; x < 20; x++) {
          expect(pixels.getUint8((y * 20 + x) * 4 + 1), closeTo(179, 2));
        }
        expect(pixels.getUint8(y * 20 * 4 + 2), greaterThan(230));
        expect(pixels.getUint8((y * 20 + 19) * 4 + 2), greaterThan(230));
        expect(pixels.getUint8((y * 20 + 13) * 4), greaterThan(240));
      }
    }
  });
}
