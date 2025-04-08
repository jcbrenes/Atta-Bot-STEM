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

  BoxDecoration get tileDecoration => BoxDecoration(
      borderRadius: BorderRadius.circular(15), color: neutralWhite);

  TextStyle get titleTextStyle => const TextStyle(
        fontWeight: FontWeight.w700,
        backgroundColor: Colors.transparent,
        color: neutralDarkBlue,
        fontFamily: "Poppins",
        fontSize: 13,
      );

  @override
  Widget build(BuildContext context) {
    // Construimos el widget principal
    Widget mainContent = Row(
      children: [
        // Punto indicador (mantenido del original)
        Padding(
          padding: EdgeInsets.fromLTRB(10, 0, tilePadding, 0),
          child: const Icon(
            Icons.circle,
            color: neutralWhite,
            size: 6,
          ),
        ),
        // Contenido principal del tile
        Expanded(
          child: Container(
            decoration: tileDecoration,
            margin: EdgeInsets.fromLTRB(0, tileMargin, 25, tileMargin),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  // Contenedor del título con color de fondo
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      color: color.withOpacity(0.5),
                    ),
                    padding: const EdgeInsets.fromLTRB(15, 2, 15, 2),
                    child: Text(
                      title,
                      style: titleTextStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const Spacer(),
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
