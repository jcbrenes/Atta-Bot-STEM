import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/screens/ventanaGirarDerecha.dart';
import 'package:proyecto_tec/screens/ventanaHistorial.dart';

void main() {
  runApp(const ventanaGirarIzquierda());
}

class ventanaGirarIzquierda extends StatelessWidget {
  const ventanaGirarIzquierda({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Rueda Giratoria Izquierda'),
        ),
        body: const Center(
          child: RotacionIzquierda(),
        ),
      ),
    );
  }
}

class RotacionIzquierda extends StatefulWidget {
  const RotacionIzquierda({Key? key}) : super(key: key);

  @override
  _RotacionIzquierdaState createState() => _RotacionIzquierdaState();
}

class _RotacionIzquierdaState extends State<RotacionIzquierda> {
  double _rotation = 0.0; // Inicia en 0 grados
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
              _rotation += details.delta.dx / 1000; // Cambio a suma para giro antihorario
              _rotation = (_rotation < 0.0) ? 0.0 : _rotation; // Limita a 0 grados
              _rotation = (_rotation > 1.0) ? 1.0 : _rotation; // Limita a 360 grados
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // Línea que va del centro a la circunferencia
              RotacionTrianguloInterno(rotation: _rotation),
              // Circunferencia
              Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    LineaCentro(),
                    
                  ],
                ),
              ),
              // Triángulo indicador
              Transform.rotate(
                angle: _rotation * math.pi * -2, // Cambio de dirección
                child: CustomPaint(
                  painter: TrianglePainter(),
                  child: const SizedBox(
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
              // Arco de grados
              ArcoGrados(rotation: _rotation),
              // Línea móvil
              LineaMovil(rotation: _rotation),
            ],
          ),
        ),
        SizedBox(height: 30),
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
                '° a la izquierda',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        botonGirarIzquierda(rotation: _rotation),
      ],
    );
  }
}

class botonGirarIzquierda extends StatelessWidget {
  const botonGirarIzquierda({
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
            .addEvento("Girar ${(rotation * 360).truncate()} grados izquierda");
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      child: Container(
        width: 2, // Ancho de la línea
        height: 100, // Largo de la línea
        color: Colors.black, // Color de la línea
      ),
    );
  }
}

class RotacionTrianguloInterno extends StatelessWidget {
  const RotacionTrianguloInterno({
    super.key,
    required double rotation,
  }) : _rotation = rotation;

  final double _rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _rotation * math.pi * -2, // Cambio de dirección
      child: Container(
        width: 100,
        height: 1,
        color: Colors.black,
        margin: const EdgeInsets.only(top: 50),
      ),
    );
  }
}

class LineaMovil extends StatelessWidget {
  const LineaMovil({
    required this.rotation,
  });

  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * math.pi * -2, // Cambio de dirección
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

    // Dibuja un arco desde la línea vertical inmóvil hasta el ángulo de rotación
    canvas.drawArc(rect, -math.pi / 2, -rotation * 2 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

