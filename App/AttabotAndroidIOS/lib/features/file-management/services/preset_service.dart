import 'dart:convert';

import 'package:flutter/services.dart';

class InstructionPreset {
  final String name;
  final String assetPath;

  const InstructionPreset({
    required this.name,
    required this.assetPath,
  });
}

class PresetService {
  static const List<InstructionPreset> availablePresets = [
    InstructionPreset(
      name: 'Cuadrado',
      assetPath: 'assets/presets/cuadrado.dat',
    ),
  ];

  Future<List<String>> loadPreset(InstructionPreset preset) async {
    final source = await rootBundle.loadString(preset.assetPath);
    final decoded = jsonDecode(source);

    if (decoded is! List || decoded.any((item) => item is! String)) {
      throw const FormatException(
          'El preset no contiene instrucciones válidas');
    }

    return List<String>.from(decoded);
  }
}
