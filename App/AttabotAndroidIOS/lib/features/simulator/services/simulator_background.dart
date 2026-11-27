import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum SimulatorBackgroundSource { file, farm }

/// Holds the background for as long as the simulator's host is open.
class SimulatorBackground extends ChangeNotifier {
  static const int _maximumImageFileBytes = 10 * 1024 * 1024;
  static const String _farmAsset = 'assets/simulator_farm_background.png';
  // Bounds of the illustrated map in the bundled 736 × 1104 PNG.
  static const ui.Rect _farmMapBounds = ui.Rect.fromLTRB(32, 69, 705, 963);

  ui.Image? _image;
  bool _visible = false;
  bool _loading = false;
  bool _disposed = false;

  ui.Image? get image => _image;
  bool get visible => _visible;
  bool get loading => _loading;

  void setVisible(bool visible) {
    if (_visible == visible || (visible && _image == null)) return;
    _visible = visible;
    notifyListeners();
  }

  Future<void> load(SimulatorBackgroundSource source) async {
    if (_loading || _disposed) return;
    _loading = true;
    notifyListeners();
    try {
      final bytes = await _readImage(source);
      if (_disposed || bytes == null) return;

      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 2048,
        allowUpscaling: false,
      );
      ui.Image image;
      try {
        image = (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
      if (source == SimulatorBackgroundSource.farm && !_disposed) {
        image = await _cropFarmMap(image);
      }
      if (_disposed) {
        image.dispose();
        return;
      }
      _image?.dispose();
      _image = image;
    } finally {
      _loading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<Uint8List?> _readImage(SimulatorBackgroundSource source) async {
    if (source == SimulatorBackgroundSource.farm) {
      return Uint8List.sublistView(await rootBundle.load(_farmAsset));
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw const FormatException('No se pudo leer la imagen');
    }
    if (file.size > _maximumImageFileBytes ||
        bytes.length > _maximumImageFileBytes) {
      throw const FormatException('La imagen debe pesar como máximo 10 MB');
    }
    return bytes;
  }

  Future<ui.Image> _cropFarmMap(ui.Image original) async {
    final recorder = ui.PictureRecorder();
    final tileBounds = ui.Offset.zero & _farmMapBounds.size;
    ui.Canvas(recorder)
        .drawImageRect(original, _farmMapBounds, tileBounds, ui.Paint());
    final picture = recorder.endRecording();
    try {
      return await picture.toImage(
        tileBounds.width.toInt(),
        tileBounds.height.toInt(),
      );
    } finally {
      picture.dispose();
      original.dispose();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _image?.dispose();
    super.dispose();
  }
}
