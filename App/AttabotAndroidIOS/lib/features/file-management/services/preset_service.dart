import 'dart:convert';

import 'package:flutter/services.dart';

class InstructionPreset {
  final String name;
  final String assetPath;
  final PresetIcon icon;

  const InstructionPreset({
    required this.name,
    required this.assetPath,
    this.icon = PresetIcon.square,
  });
}

enum PresetIcon {
  square,
  triangle,
  stepHigh,
  stepLow,
}

class PresetService {
  static const List<InstructionPreset> availablePresets = [
    InstructionPreset(
      name: 'Cuadrado',
      assetPath: 'assets/presets/cuadrado.dat',
      icon: PresetIcon.square,
    ),
    InstructionPreset(
      name: 'Cuadrado con ciclo',
      assetPath: 'assets/presets/cuadrado_con_ciclo.dat',
      icon: PresetIcon.square,
    ),
    InstructionPreset(
      name: 'Triángulo rectángulo',
      assetPath: 'assets/presets/triangulo_rectangulo.dat',
      icon: PresetIcon.triangle,
    ),
    InstructionPreset(
      name: 'Frecuencia alta',
      assetPath: 'assets/presets/frecuencia_alta.dat',
      icon: PresetIcon.stepHigh,
    ),
    InstructionPreset(
      name: 'Frecuencia alta con ciclo',
      assetPath: 'assets/presets/frecuencia_alta_con_ciclo.dat',
      icon: PresetIcon.stepHigh,
    ),
    InstructionPreset(
      name: 'Frecuencia baja',
      assetPath: 'assets/presets/frecuencia_baja.dat',
      icon: PresetIcon.stepLow,
    ),
    InstructionPreset(
      name: 'Frecuencia baja con ciclo',
      assetPath: 'assets/presets/frecuencia_baja_con_ciclo.dat',
      icon: PresetIcon.stepLow,
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
