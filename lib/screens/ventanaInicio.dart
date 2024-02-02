// ignore_for_file: camel_case_types

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:proyecto_tec/screens/ventanaControlRobot.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';



Future<bool> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.location,
    Permission.bluetooth,
  ].request();

  bool allPermissionsGranted = statuses.values.every((status) => status.isGranted);
  return allPermissionsGranted;
}


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

class imagenInicio extends StatelessWidget {
  const imagenInicio({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/AttaBotLogo.png',
      fit: BoxFit.cover,
    );
  }
}

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




class botonComenzarInicio extends StatelessWidget {
  const botonComenzarInicio({Key? key}) : super(key: key);

  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetooth,
    ].request();

    bool allPermissionsGranted = statuses.values.every((status) => status.isGranted);
    return allPermissionsGranted;
  }

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
        if (Platform.isIOS) {
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
        } else if (Platform.isAndroid) {
          // Solicita los permisos de Bluetooth y GPS
          bool permissionsGranted = await requestPermissions();

          if (permissionsGranted) {
            // Para Android, usa Flutter Reactive Ble
            var status = await flutterReactiveBle.statusStream.first;
            print(status);

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
            // Maneja el caso en que los permisos no fueron concedidos
            // Por ejemplo, podrías mostrar un mensaje al usuario
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
