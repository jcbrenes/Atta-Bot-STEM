import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class InstructionTile extends StatelessWidget {
  final Color color;
  final String title;
  final Widget? trailing;
  final double tilePadding;
  final int index;

  const InstructionTile({
    super.key,
    required this.color,
    required this.title,
    this.trailing,
    required this.tilePadding,
    required this.index,
  });

  double get tileMargin => 8;

  TextStyle get titleTextStyle => const TextStyle(
        fontWeight: FontWeight.w700,
        color: neutralDarkBlue,
        fontFamily: "Poppins",
        fontSize: 13,
      );

  // Determina el ícono según el texto de la instrucción
  String getIconPath() {
    final lower = title.toLowerCase();

    if (lower.contains('detención') || lower.contains('detección')) {
      return 'assets/button_icons/obstacle_detection.png';
    } else if (lower.contains('avanzar')) {
      return 'assets/button_icons/forward_arrow.png';
    } else if (lower.contains('retroceder')) {
      return 'assets/button_icons/backward_arrow.png';
    } else if (lower.contains('girar')) {
      return 'assets/button_icons/rotate_right.png';
    } else if (lower.contains('ciclo abierto')) {
      return 'assets/button_icons/cycle.png';
    } else if (lower.contains('ciclo cerrado')) {
      return 'assets/button_icons/cycle.png';
    } else if (lower.contains('lápiz activado')) {
      return 'assets/button_icons/pencil.png';
    } else if (lower.contains('lápiz desactivado')) {
      return 'assets/button_icons/pencil.png';
    }
    // Ícono por defecto
    return 'assets/button_icons/default.png';
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = Row(
      children: [
        // Punto indicador
        Padding(
          padding: EdgeInsets.fromLTRB(10, 0, tilePadding, 0),
          child: const Icon(
            Icons.circle,
            color: neutralWhite,
            size: 6,
          ),
        ),

        // Caja completa de la instrucción
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(0, tileMargin, 40, tileMargin),
            decoration: BoxDecoration(
              color: color, // Fondo completo
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Row(
                children: [
                  // Ícono a la izquierda
                  Image.asset(
                    getIconPath(),
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                  // Texto de la instrucción
                  Expanded(
                    child: Text(
                      title,
                      style: titleTextStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  trailing ?? const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    return ReorderableDragStartListener(
      index: index,
      child: mainContent,
    );
  }
}
