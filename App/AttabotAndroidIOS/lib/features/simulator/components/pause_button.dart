// ✅ Archivo: pause_button.dart
import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class PauseButton extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onToggle;

  const PauseButton({
    super.key,
    required this.isPaused,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: Icon(
        isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
        color: neutralWhite,
        size: 26,
      ),
      tooltip: isPaused ? 'Reanudar' : 'Pausar',
    );
  }
}
