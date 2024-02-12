import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/screens/ventanaHistorial.dart';



/// Punto de entrada de la aplicación.
void main() {
  runApp(const VentanaGirarDerecha());
}

/// Clase para la ventana principal de la aplicación.
class VentanaGirarDerecha extends StatelessWidget {
  const VentanaGirarDerecha({Key? key}) : super(key: key);


  /// Construye la interfaz de usuario de la aplicación.
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


/// Clase para el widget de rotación a la derecha.
class RotacionDerecha extends StatefulWidget {
  const RotacionDerecha({Key? key}) : super(key: key);


 
  @override
  _RotacionDerechaState createState() => _RotacionDerechaState();
}


/// Clase para el estado del widget de rotación a la derecha.
class _RotacionDerechaState extends State<RotacionDerecha> {
  double _rotacion = 0.0;
  final _controlador = TextEditingController();


  /// Construye la interfaz de usuario para este widget.
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
              _rotacion -= details.delta.dx / 1000;
              _rotacion = _rotacion.clamp(0.0, 1.0);
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
                  color: Colors.grey,
                ),
                child:
                    LineaCentro(rotacion: _rotacion), 
              ),

              LineaMovil(rotacion: _rotacion), 
              ArcoGrados(rotacion: _rotacion), 
              Transform.rotate(
                angle: _rotacion * math.pi * 2,
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
              Container(
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
                    if (numeroGrados != null && numeroGrados >= 0 && numeroGrados <= 360) {//limite de 0 a 360 grados
                      setState(() {
                        _rotacion = numeroGrados / 360;
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
        BotonGirarDerecha(rotacion: _rotacion),
      ],
    );
  }
}


/// Clase para el botón de girar a la derecha.
class BotonGirarDerecha extends StatelessWidget {
  const BotonGirarDerecha({
    required this.rotacion,
  });

  final double rotacion;

  /// Construye la interfaz de usuario para este widget.

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
            .addEvento("Girar ${(rotacion * 360).truncate()} grados derecha");//envia los datos si se gira a la derecha
        Navigator.of(context).pop();
      },
      child: const Text(
        'Girar',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}


/// Clase para la línea central del widget de rotación.
class LineaCentro extends StatelessWidget {
  const LineaCentro({
    required this.rotacion,
  });

  final double rotacion;
  /// Construye la interfaz de usuario para este widget.
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


/// Clase para la rotación del triángulo interno del widget de rotación.
class RotacionTrianguloInterno extends StatelessWidget {
  const RotacionTrianguloInterno({
    required this.rotacion,
  });

  final double rotacion;

  /// Construye la interfaz de usuario para este widget.
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotacion * math.pi * 2,
      child: Container(
        width: 100,
        height: 100,
        color: Colors.black,
        margin: const EdgeInsets.only(top: 50),
      ),
    );
  }
}


/// Clase para el pintor de triángulos del widget de rotación.
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
/// Clase para la línea móvil del widget de rotación.
class LineaMovil extends StatelessWidget {
  const LineaMovil({
    required this.rotacion,
  });

  final double rotacion;
  /// Construye la interfaz de usuario para este widget.
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotacion * math.pi * 2,
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
/// Clase para el arco de grados del widget de rotación.
class ArcoGrados extends StatelessWidget {
  const ArcoGrados({
    required this.rotacion,
  });

  final double rotacion;
  /// Construye la interfaz de usuario para este widget.
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200), 
      painter: ArcoPainter(rotation: rotacion),
    );
  }
}
/// Clase para el pintor de arcos del widget de rotación.
class ArcoPainter extends CustomPainter {
  ArcoPainter({required this.rotation});

  final double rotation;
  /// Pinta el arco en el canvas.
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
    canvas.drawArc(rect, -1.55, rotation * 2 * pi, false, paint);
  }
  /// Determina si el pintor debe repintarse.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
