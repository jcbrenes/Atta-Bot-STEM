// ignore_for_file: camel_case_types, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';
import 'package:proyecto_tec/screens/ventanaHistorial.dart';
import 'dart:async';
import 'package:flutter/services.dart';

/// Define el esqueleto para una ventana de diálogo personalizada.
abstract class VentanaBase extends StatefulWidget {
  const VentanaBase({Key? key}) : super(key: key);

  // Título de la ventana de diálogo
  String get titulo;
  // Acción a realizar
  String get accion;

  @override
  _VentanaBaseState createState() => _VentanaBaseState();
}

/// Define el estado para una ventana de diálogo personalizada.
class _VentanaBaseState extends State<VentanaBase> {
  int numero = 0; // Número que se muestra en la ventana de diálogo
  Timer? _tiempo; // Temporizador para cambiar el número
  final _controller = TextEditingController(); // Controlador del TextField

  /// Cambia el número en un intervalo de tiempo.

  void _cambiarNumero(int cambio) {
    if (_tiempo != null && _tiempo!.isActive) return;

    _tiempo = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      setState(() {
        numero += cambio;
        if (numero < 0) {
          //aca es un limitador para el numero no pase de 0 o de 300, que solo sea de 0 a 300
          numero = 0;
        } else if (numero > 300) {
          numero = 300;
        }
        _controller.text = numero.toString();
      });
    });
  }

  // Detiene el temporizador
  void _pararTiempo() {
    _tiempo?.cancel();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(
          0xFFBBCEF1), // Establecer el color de fondo del AlertDialog
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(10.0), // Ajustar la curvatura de las esquinas
        side: const BorderSide(
            color: Colors.white, width: 5.0), // Agregar borde blanco
      ),

      title: _crearTitulo(),
      content: _crearContenido(),
      actions: _crearAcciones(context),
    );
  }

  /// Crea el título de la ventana de diálogo.

  Widget _crearTitulo() {
    return Center(
      child: Text(
        widget.titulo,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24, // Tamaño de la fuente
          color: Color(0xFF152A51), // Color del texto
        ),
      ),
    );
  }

  /// Crea el TextField de la ventana de diálogo.
  Widget _crearTextField() {
    return SizedBox(
      width: 120, // Ajusta el ancho según tus necesidades
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 65, // Ancho del TextField
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(
                    r'^\d{0,3}$')), //validacion de caracteres en el textfield
              ],
              onChanged: _onChanged,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30, // Tamaño del texto del TextField
                color: Color(0xFF152A51), // Color del texto del TextField
              ),
              decoration: const InputDecoration(
                hintText: '0', // Valores que se muestran al usuario como guía
                border: InputBorder.none,
              ),
            ),
          ),
          const Text(
            'cm',
            style: TextStyle(
              fontSize: 30, // Tamaño del texto "cm"
              color: Color(0xFF152A51), // Color del texto "cm"
            ),
          ),
        ],
      ),
    );
  }

  /// Maneja el cambio de valor en el TextField.
  void _onChanged(String value) {
    if (value.isEmpty) {
      numero = 0;
    } else {
      int? numeroInt = int.tryParse(value);
      if (numeroInt != null && numeroInt >= 0 && numeroInt <= 300) {
        setState(() {
          numero = numeroInt;
        });
      } else {
        _mostrarErrorDialog();
      }
    }
  }

  /// Muestra un diálogo de error cuando el valor ingresado no es válido.
  void _mostrarErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Por favor, ingrese un número entre 0 y 300.'),
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

  /// Crea las acciones de la ventana de diálogo.
  List<Widget> _crearAcciones(BuildContext context) {
    return <Widget>[
      TextButton(
        child: const Text('Cancelar'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      TextButton(
        child: const Text('Aceptar'),
        onPressed: () {
          Provider.of<CommandService>(context,
                  listen:
                      false) // Se obtiene una instancia del proveedor 'Historial' y se añade un nuevo evento a este.
              .addInstruction(
                  '${widget.accion} $numero cm'); // El evento es una cadena de texto que contiene la acción realizada y la distancia en centímetros.
          Navigator.of(context).pop();
        },
      ),
    ];
  }

  /// Crea el contenido de la ventana de diálogo.
  Widget _crearContenido() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _crearBoton(-1, Icons.remove),
        _crearTextField(),
        _crearBoton(1, Icons.add),
      ],
    );
  }

  /// Crea un botón con un icono.
  Widget _crearBoton(int cambio, IconData icono) {
    return GestureDetector(
      onTapDown: (_) => _cambiarNumero(cambio),
      onTapUp: (_) => _pararTiempo(),
      onTapCancel: () => _pararTiempo(),
      child: Container(
        width: 50, // Ancho del círculo
        height: 50, // Alto del círculo
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF1C74B5), // Color del círculo azul
        ),
        child: IconButton(
          icon: Icon(
            icono,
            color: Colors.white, // Color blanco para el icono
          ),
          onPressed: () {
            setState(() {
              numero += cambio;
              if (numero < 0) {
                numero = 0;
              } else if (numero > 300) {
                numero = 300;
              }
              _controller.text = numero.toString();
            });
          },
        ),
      ),
    );
  }
}

/// Representa una ventana de diálogo para avanzar.
class ventanaAvanzar extends VentanaBase {
  const ventanaAvanzar({Key? key}) : super(key: key);

  @override
  String get titulo => 'Avanzar';

  @override
  String get accion => 'Avanzar';
}

/// Representa una ventana de diálogo para retroceder.
class ventanaRetroceder extends VentanaBase {
  const ventanaRetroceder({Key? key}) : super(key: key);

  @override
  String get titulo => 'Retroceder';

  @override
  String get accion => 'Retroceder';
}
