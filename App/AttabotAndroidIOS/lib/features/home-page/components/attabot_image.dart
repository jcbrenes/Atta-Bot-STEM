import 'package:flutter/material.dart';

class AttaBotImage extends StatelessWidget {
  final String imgPath;

  const AttaBotImage({super.key, required this.imgPath});

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        const Color(0xFF152A51)
            .withOpacity(0.7), // Color blanco con opacidad del 60%
        BlendMode
            .srcATop, // Modo de mezcla suave Modo de mezcla para combinar con el color de fondo
      ),
      child: Image.asset(
        imgPath,
        fit: BoxFit.cover,
      ),
    );
  }
}
