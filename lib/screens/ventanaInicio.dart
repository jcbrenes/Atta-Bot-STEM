// ignore_for_file: camel_case_types, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:proyecto_tec/screens/ventanaControlRobot.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';


//funcion que permite pedir permisos al sistema
Future<bool> pedirPermisos() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.location,
    Permission.bluetooth,
  ].request();

  bool permisosConcedidos = statuses.values.every((status) => status.isGranted);
  return permisosConcedidos;
}

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
            colors: [Colors.blue, Colors.lightBlueAccent],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              textoInicio(),
              SizedBox(height: 50),
              imagenInicio(),
              SizedBox(height: 50),
              botonComenzarInicio(),
            ],
          ),
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
    return Image.asset(
      'assets/AttaBotLogo.png',//aca es donde se carga la imagen
      fit: BoxFit.cover,
    );
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
      'Atta-bot Educativo',
      style: TextStyle(fontSize: 24, color: Colors.white),
      textAlign: TextAlign.center,
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
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.blue,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
      onPressed: () async {
        if (Platform.isIOS) {//verifica si es ios y valida el bluethoot
          await FlutterBluePlus.adapterState.first;
          // Para iOS, usa Flutter Blue Plus
          if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
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
        } else if (Platform.isAndroid) {//verifica si es ios y valida el bluethoot
          // Solicita los permisos de Bluetooth y GPS
          bool permisosConcedidos = await pedirPermisos();

          if (permisosConcedidos) {
            // Para Android, usa Flutter Reactive Ble
            var status = await flutterReactiveBle.statusStream.first;


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
          } else {
 
          }
        }
      },
      child: const Text(
        'Comenzar',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
