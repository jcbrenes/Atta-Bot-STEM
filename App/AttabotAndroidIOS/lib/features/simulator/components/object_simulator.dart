import 'package:flutter/material.dart';

class ObjectSimulator extends StatelessWidget {
  final String botImagePath;
  final double size; // Tamaño del triángulo
  final bool useImage;

  const ObjectSimulator({
    super.key,
    this.botImagePath = '',
    this.size = 40,
    this.useImage = false, // por defecto usa el triángulo
  });

  @override
  Widget build(BuildContext context) {
    if (useImage && botImagePath.isNotEmpty) {
      return Image.asset(botImagePath, width: size, height: size);
    } else {
      return CustomPaint(
        size: Size(size, size),
        painter: TrianglePainter(),
      );
    }
  }
}

// CustomPainter para dibujar un triángulo
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint trianglePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final Path path = Path();

    // Triángulo isósceles (más alargado verticalmente)
    path.moveTo(size.width / 2, 0); // Vértice superior (frente)
    path.lineTo(size.width * 0.1, size.height); // Inferior izquierda
    path.lineTo(size.width * 0.9, size.height); // Inferior derecha
    path.close();

    canvas.drawPath(path, trianglePaint);

    // Punto en el frente del triángulo
    final Paint dotPaint = Paint()
      ..color = const Color.fromARGB(255, 38, 18, 226)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(size.width / 2, 4), 3, dotPaint); // punto en la punta superior
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
