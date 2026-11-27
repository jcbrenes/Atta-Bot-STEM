import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/features/file-management/services/preset_service.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class PredeterminedFiguresDialog extends StatefulWidget {
  const PredeterminedFiguresDialog({super.key});

  static Future<void> show(
    BuildContext context, {
    bool useRootNavigator = true,
  }) {
    return showDialog<void>(
      context: context,
      useRootNavigator: useRootNavigator,
      builder: (_) => const PredeterminedFiguresDialog(),
    );
  }

  @override
  State<PredeterminedFiguresDialog> createState() =>
      _PredeterminedFiguresDialogState();
}

class _PredeterminedFiguresDialogState
    extends State<PredeterminedFiguresDialog> {
  final PresetService _presetService = PresetService();
  InstructionPreset? _selectedPreset;

  IconData _iconFor(PresetIcon icon) {
    switch (icon) {
      case PresetIcon.square:
        return Icons.crop_square;
      case PresetIcon.triangle:
        return Icons.change_history;
      case PresetIcon.stepHigh:
        return Icons.stacked_line_chart;
      case PresetIcon.stepLow:
        return Icons.show_chart;
    }
  }

  Future<void> _accept() async {
    final preset = _selectedPreset;
    if (preset == null) return;

    try {
      final instructions = await _presetService.loadPreset(preset);
      if (!mounted) return;
      context.read<CommandService>().loadCommands(instructions);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${preset.name} cargado'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FormatException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La figura no contiene instrucciones válidas'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FlutterError {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cargar la figura'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      fontFamily: 'Poppins',
      color: neutralWhite,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    );
    const contentStyle = TextStyle(
      fontFamily: 'Poppins',
      color: neutralWhite,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );

    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final dialogWidth = (size.width * (isTablet ? 0.42 : 0.82))
        .clamp(320.0, 520.0)
        .toDouble();

    return AlertDialog(
      backgroundColor: neutralDarkBlueAD,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: const BorderSide(color: neutralWhite, width: 4.0),
      ),
      title: const Center(
        child: Text('Figuras predeterminadas', style: titleStyle),
      ),
      content: SizedBox(
        width: dialogWidth,
        child: DropdownButtonFormField<InstructionPreset>(
          value: _selectedPreset,
          dropdownColor: darkBlueGray,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: neutralWhite),
          decoration: InputDecoration(
            filled: true,
            fillColor: darkBlueGray,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: mediumBlueGray, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: mediumBlueGray, width: 1.5),
            ),
          ),
          hint: const Text('Seleccionar figura', style: contentStyle),
          items: PresetService.availablePresets
              .map(
                (preset) => DropdownMenuItem(
                  value: preset,
                  child: Row(
                    children: [
                      Icon(
                        _iconFor(preset.icon),
                        color: neutralWhite,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(preset.name, style: contentStyle),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (preset) {
            setState(() {
              _selectedPreset = preset;
            });
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: neutralWhite,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: _selectedPreset == null ? null : _accept,
          child: Text(
            'Aceptar',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: _selectedPreset == null
                  ? neutralWhite.withOpacity(0.45)
                  : neutralWhite,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
