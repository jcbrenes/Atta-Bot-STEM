// ignore_for_file: camel_case_types, library_private_types_in_public_api

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/screens/ventanaGirarDerecha.dart';
import 'package:proyecto_tec/screens/ventanaHistorial.dart';

/// Punto de entrada de la aplicación.
void main() {
  runApp(const ventanaGirarIzquierda());
}

/// Clase para la ventana principal de la aplicación.
class ventanaGirarIzquierda extends StatelessWidget {
  const ventanaGirarIzquierda({Key? key}) : super(key: key);



  /// Construye la interfaz de usuario de la aplicación.
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

/// Clase para el widget de rotación a la izquierda.
class RotacionIzquierda extends StatefulWidget {
  const RotacionIzquierda({Key? key}) : super(key: key);

  /// Crea el estado para este widget.
  @override
  _RotacionIzquierdaState createState() => _RotacionIzquierdaState();
}


/// Clase para el estado del widget de rotación a la izquierda.
class _RotacionIzquierdaState extends State<RotacionIzquierda> {
  double _rotacion = 0.0; // Inicia en 0 grados
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
              _rotacion += details.delta.dx / 1000; // Cambia a suma para giro antihorario
              _rotacion = (_rotacion < 0.0) ? 0.0 : _rotacion; // Limita a 0 grados
              _rotacion = (_rotacion > 1.0) ? 1.0 : _rotacion; // Limita a 360 grados
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
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    LineaCentro(),
                    
                  ],
                ),
              ),
    
              Transform.rotate(
                angle: _rotacion * math.pi * -2, // Cambio de dirección
                child: CustomPaint(
                  painter: TrianglePainter(),
                  child: const SizedBox(
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
    
              ArcoGrados(rotacion: _rotacion),
      
              LineaMovil(rotacion: _rotacion),
            ],
          ),
        ),
        const SizedBox(height: 30),
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
                    final numero = int.tryParse(value);
                    if (numero != null && numero >= 0 && numero <= 360) {
                      setState(() {
                        _rotacion = numero / 360;
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
        const SizedBox(height: 30),
        botonGirarIzquierda(rotacion: _rotacion),
      ],
    );
  }
}


/// Clase para el botón de girar a la izquierda.
class botonGirarIzquierda extends StatelessWidget {
  const botonGirarIzquierda({super.key, 
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
            .addEvento("Girar ${(rotacion * 360).truncate()} grados izquierda");
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
    required double rotacion,
  }) : _rotacion = rotacion;

  final double _rotacion;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _rotacion * math.pi * -2, // Cambio de dirección
      child: Container(
        width: 100,
        height: 1,
        color: Colors.black,
        margin: const EdgeInsets.only(top: 50),
      ),
    );
  }
}


//clase para la linea movil
class LineaMovil extends StatelessWidget {
  const LineaMovil({super.key, 
    required this.rotacion,
  });

  final double rotacion;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotacion * math.pi * -2, // Cambio de dirección
      child: Transform.translate(
        offset: const Offset(0.0, -50.0), // Posicion
        child: Container(
          width: 2,
          height: 100, 
          color: Colors.black,
        ),
      ),
    );
  }
}

//realiza el arco de la linea movil e inmovil
class ArcoGrados extends StatelessWidget {
  const ArcoGrados({super.key, 
    required this.rotacion,
  });

  final double rotacion;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200), // Tamaño del CustomPainter
      painter: ArcoPainter(rotacion: rotacion),
    );
  }
}

class ArcoPainter extends CustomPainter {
  ArcoPainter({required this.rotacion});

  final double rotacion;

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

    // Dibuja un arco desde la línea vertical inmóvil hasta el ángulo de rotación
    canvas.drawArc(rect, -math.pi / 2, -rotacion * 2 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

