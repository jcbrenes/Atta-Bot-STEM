import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/instruction-history/services/history_service.dart';
import 'package:proyecto_tec/screens/ventanaHistorial.dart';

void main() {
  runApp(const VentanaGirarIzquierda());
}

class VentanaGirarIzquierda extends StatelessWidget {
  const VentanaGirarIzquierda({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Rueda Giratoria'),
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
  double _rotacion = 0.0;
  final _controlador = TextEditingController();
  Offset _centro = Offset.zero;
  double _anguloPrevio = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _centro = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: Text(
                '${(_rotacion * 360).toStringAsFixed(0)}°',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onPanStart: (details) {
                final toque = details.localPosition;
                final delta = toque - _centro;
                _anguloPrevio = math.atan2(delta.dy, delta.dx);
              },
              onPanUpdate: (details) {
                setState(() {
                  final toque = details.localPosition;
                  final delta = toque - _centro;
                  final anguloActual = math.atan2(delta.dy, delta.dx);
                  final diferenciaAngular = anguloActual - _anguloPrevio;

                  _rotacion -= diferenciaAngular / (2 * math.pi);
                  _rotacion = _rotacion % 1.0;
                  _anguloPrevio = anguloActual;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  RotacionTrianguloInterno(rotacion: _rotacion),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: LineaCentro(rotacion: _rotacion),
                  ),
                  LineaMovil(rotacion: _rotacion),
                  ArcoGrados(rotacion: _rotacion),
                  Transform.rotate(
                    angle: -_rotacion * math.pi * 2,
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
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Girar ',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _controlador,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: (_rotacion * 360).toStringAsFixed(0),
                      ),
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        final numeroGrados = int.tryParse(value);
                        if (numeroGrados != null && numeroGrados >= 0 && numeroGrados <= 360) {
                          setState(() {
                            _rotacion = numeroGrados / 360;
                          });
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Error'),
                                content: const Text('Por favor, ingrese valores entre 0 y 360.'),
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
            const SizedBox(height: 30),
            BotonGirarIzquierda(rotacion: _rotacion),
          ],
        );
      },
    );
  }
}

class BotonGirarIzquierda extends StatelessWidget {
  const BotonGirarIzquierda({super.key, required this.rotacion});

  final double rotacion;

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
        Provider.of<HistoryService>(context, listen: false)
            .addInstruction("Girar ${(rotacion * 360).truncate()} grados izquierda");
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
  const LineaCentro({super.key, required this.rotacion});

  final double rotacion;

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
  const RotacionTrianguloInterno({super.key, required this.rotacion});

  final double rotacion;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -rotacion * math.pi * 2,  // Rotación en sentido antihorario
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
  const LineaMovil({super.key, required this.rotacion});

  final double rotacion;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -rotacion * math.pi * 2,  // Rotación en sentido antihorario
      child: Transform.translate(
        offset: const Offset(0.0, -50.0),
        child: Container(
          width: 2,
          height: 100,
          color: Colors.black,
        ),
      ),
    );
  }
}

class ArcoGrados extends StatelessWidget {
  const ArcoGrados({super.key, required this.rotacion});

  final double rotacion;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200),
      painter: ArcoPainter(rotation: rotacion),
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
      width: size.width - 150,
      height: size.height - 150,
    );

    // Dibuja un arco desde 0 hasta el ángulo de rotación
    canvas.drawArc(rect, -math.pi / 2, -rotation * 2 * math.pi, false, paint);  // Arco antihorario
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

