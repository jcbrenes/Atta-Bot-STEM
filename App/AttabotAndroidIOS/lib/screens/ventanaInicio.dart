import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:proyecto_tec/screens/ventanaControlRobot.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/text_/button_factory.dart';

// //funcion que permite pedir permisos al sistema
// Future<bool> pedirPermisos() async {
//   Map<Permission, PermissionStatus> statuses = await [
//     Permission.bluetooth,
//     Permission.location,
//
//   ].request();
//
//   bool permisosConcedidos = statuses.values.every((status) => status.isGranted);
//   return permisosConcedidos;
// }

//pantalla de inicio, grafico
class pantallaInicio extends StatelessWidget {
  const pantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF798DB1), Color(0xFF152A51)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const textoInicio(),
            const textoVersion(),
            const SizedBox(height: 50),
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                const Color(0xFF152A51)
                    .withOpacity(0.7), // Color blanco con opacidad del 60%
                BlendMode
                    .srcATop, // Modo de mezcla suave Modo de mezcla para combinar con el color de fondo
              ),
              child: Image.asset(
                'assets/AttaBotRoboInicio.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 50),
            TextButtonFactory.getButton(
                type: TextButtonType.filled,
                text: 'Comenzar',
                handleButtonPress: () {
                  print('Comenzar');
                }),
          ],
        ),
      ),
    );
  }
}

//logo que se muestra al inicio
class imagenInicio extends StatelessWidget {
  const imagenInicio({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Colors.white, // Color transparente
          BlendMode
              .softLight, // Modo de mezcla para combinar con el color de fondo
        ),
        child: Image.asset(
          'assets/AttaBotLogo.png', //aca es donde se carga la imagen
          fit: BoxFit.cover,
        ));
  }
}

//texto de inicio
class textoInicio extends StatelessWidget {
  const textoInicio({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Atta-Bot\nSTEM',
      style: TextStyle(
        fontSize: 50,
        color: Colors.white,
        fontFamily: 'Poppins', // Establecer la fuente como Poppins
        fontWeight: FontWeight
            .w900, // Establecer el peso de la fuente como extrabold (800)height: 0.
        height: 1.1,
      ),
      textAlign: TextAlign.left,
    );
  }
}

class textoVersion extends StatelessWidget {
  const textoVersion({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment:
          Alignment.bottomLeft, // Alineación del contenedor a la izquierda
      padding: const EdgeInsets.only(left: 90.0),
      child: const Text(
        'v.1.1.16',
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontFamily: 'Poppins', // Establecer la fuente como Poppins
          // Establecer el peso de la fuente como extrabold (800)
        ),
        textAlign: TextAlign.center, // Alineación del texto a la izquierda
      ),
    );
  }
}

//boton de inicio verifica si el bluetooth esta activado
class botonComenzarInicio extends StatelessWidget {
  const botonComenzarInicio({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final flutterReactiveBle = FlutterReactiveBle();
    return ElevatedButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(Colors.white),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors
                .orange; // Cambia el color de fondo al naranja cuando se presiona el botón
          }
          return Colors.transparent; // Fondo transparente
        }),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0),
            side: const BorderSide(
                color: Colors.white), // Línea blanca en el borde
          ),
        ),
      ),
      onPressed: () async {
        if (Platform.isIOS) {
          //verifica si es ios y valida el bluethoot
          await FlutterBluePlus.adapterState.first;
          // Para iOS, usa Flutter Blue Plus
          if (await FlutterBluePlus.adapterState.first !=
              BluetoothAdapterState.on) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Bluetooth apagado'),
                  content: const Text(
                      'Por favor, activa el Bluetooth en tu dispositivo y el GPS'),
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
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const pantallaControlRobot()),
            );
          }
        } else if (Platform.isAndroid) {
          //verifica si es ios y valida el bluethoot
          // Solicita los permisos de Bluetooth y GPS
          //bool permisosConcedidos = await pedirPermisos();

          //if (permisosConcedidos) {
          // Para Android, usa Flutter Reactive Ble
          //var status = await flutterReactiveBle.statusStream.first;

          "estas dos lineas de codigo son medio dudosas, pero funciona";
          var permission = await Permission.bluetooth.request();
          var status = BleStatus.ready;

          if (status != BleStatus.ready) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Bluetooth apagado'),
                  content: const Text(
                      'Por favor, activa el Bluetooth en tu dispositivo'),
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
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const pantallaControlRobot()),
            );
          }
        } else {}
      },
      //},
      child: const Text(
        'Comenzar',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
