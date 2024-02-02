import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/screens/ventanaHistorial.dart';

void main() {
  runApp(const VentanaGirarDerecha());
}

class VentanaGirarDerecha extends StatelessWidget {
  const VentanaGirarDerecha({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Rueda Giratoria'),
        ),
        body: const Center(
          child: RotacionDerecha(),
        ),
      ),
    );
  }
}

class RotacionDerecha extends StatefulWidget {
  const RotacionDerecha({Key? key}) : super(key: key);

  @override
  _RotacionDerechaState createState() => _RotacionDerechaState();
}

class _RotacionDerechaState extends State<RotacionDerecha> {
  double _rotation = 0.0;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: const Text(
            '0°',
            style: TextStyle(fontSize: 20),
          ),
        ),

        const SizedBox(height: 10),
        GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _rotation -= details.delta.dx / 1000;
              _rotation = _rotation.clamp(0.0, 1.0);
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              RotacionTrianguloInterno(rotation: _rotation),

              Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child:
                    LineaCentro(rotation: _rotation), // Línea central inmóvil
              ),

              LineaMovil(rotation: _rotation), // Nueva línea móvil
              ArcoGrados(rotation: _rotation), // Nuevo arco de grados
              Transform.rotate(
                angle: _rotation * math.pi * 2,
                child: CustomPaint(
                  painter: TrianglePainter(),
                  child: const SizedBox(
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Primero, define un TextEditingController

        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Girar ',
                style: TextStyle(fontSize: 20),
              ),
              Container(
                width: 50, // puedes ajustar el ancho como necesites
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: (_rotation * 360).toStringAsFixed(0),
                  ),
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    final number = int.tryParse(value);
                    if (number != null && number >= 0 && number <= 360) {
                      setState(() {
                        _rotation = number / 360;
                      });
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: const Text(
                                'Por favor, ingrese valores entre 0 y 360.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ),
              const Text(
                '° a la derecha',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        BotonGirarDerecha(rotation: _rotation),
      ],
    );
  }
}

class BotonGirarDerecha extends StatelessWidget {
  const BotonGirarDerecha({
    required this.rotation,
  });

  final double rotation;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        minimumSize: const Size(88, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        ),
      ),
      onPressed: () {
        Provider.of<Historial>(context, listen: false)
            .addEvento("Girar ${(rotation * 360).truncate()} grados derecha");
        Navigator.of(context).pop();
      },
      child: const Text(
        'Girar',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}

class LineaCentro extends StatelessWidget {
  const LineaCentro({
    required this.rotation,
  });

  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 0,
          child: Container(
            width: 2,
            height: 100,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class RotacionTrianguloInterno extends StatelessWidget {
  const RotacionTrianguloInterno({
    required this.rotation,
  });

  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * math.pi * 2,
      child: Container(
        width: 100,
        height: 100,
        color: Colors.black,
        margin: const EdgeInsets.only(top: 50),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width / 2 - 10, 20);
    path.lineTo(size.width / 2 + 10, 20);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class LineaMovil extends StatelessWidget {
  const LineaMovil({
    required this.rotation,
  });

  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * math.pi * 2,
      child: Transform.translate(
        offset: const Offset(0.0, -50.0), // Ajusta la posición de la línea aquí
        child: Container(
          width: 2,
          height: 100, // Ajusta la longitud de la línea aquí
          color: Colors.black,
        ),
      ),
    );
  }
}

class ArcoGrados extends StatelessWidget {
  const ArcoGrados({
    required this.rotation,
  });

  final double rotation;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200), // Tamaño del CustomPainter
      painter: ArcoPainter(rotation: rotation),
    );
  }
}

class ArcoPainter extends CustomPainter {
  ArcoPainter({required this.rotation});

  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width - 150, // Ajusta el tamaño del Rect aquí
      height: size.height - 150, // Ajusta el tamaño del Rect aquí
    );

    // Dibuja un arco desde 0 hasta el ángulo de rotación
    canvas.drawArc(rect, -1.55, rotation * 2 * pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
