// ignore_for_file: file_names, camel_case_types, library_private_types_in_public_api, unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';

import 'package:proyecto_tec/screens/ventanaGirarDerecha.dart';
import 'package:proyecto_tec/screens/ventanaHistorial.dart';
import 'package:proyecto_tec/screens/ventanaGirarIzquierda.dart';

import 'ventanaAvanzarRetroceder.dart';

class pantallaControlRobot extends StatefulWidget {
  const pantallaControlRobot({Key? key}) : super(key: key);

  @override
  _pantallaControlRobotState createState() => _pantallaControlRobotState();
}

class _pantallaControlRobotState extends State<pantallaControlRobot> {
  final TextEditingController controller = TextEditingController();
  final List<String> historial = [];

  void _onSwipe(DragEndDetails detalles) {
    if (detalles.primaryVelocity! < 0) {
      Scaffold.of(context).openEndDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Atta-bot Educativo'),
            centerTitle: true,
            actions: <Widget>[
              menuDesplegable(
                context: context,
                controller: controller,
                historial: historial,
              ),
            ],
          ),
          body: GestureDetector(
            onHorizontalDragEnd: _onSwipe,
            child: Container(
              margin: const EdgeInsets.all(
                  10.0), // Aplica un margen de 10 píxeles en todos los lados.
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const botonArriba(),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              botonIzquierda(),
                              imagenRobotCentral(),
                              botonDerecha(),
                            ],
                          ),
                          const botonAbajo(),
                          Column(
                            children: <Widget>[
                              const textfieldUltimaAccion(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  BotonEjecutar(),
                                  const BotonDeteccionObstaculos(),
                                ],
                              ),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  BotonCambioColorCiclo(),
                                  botonBorrarHistorial(),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          endDrawer: SizedBox(
            width: MediaQuery.of(context).size.width * 1,
            child: const ventanaHistorial(),
          ),
        ));
  }
}

class textfieldUltimaAccion extends StatelessWidget {
  const textfieldUltimaAccion({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(30.0),
      height: 50,
      color: Colors.grey[200],
      child: Consumer<Historial>(
        builder: (context, historial, child) {
          return Center(
            child: Text(
              historial.historial.isNotEmpty
                  ? historial.historial.last
                  : 'No hay acciones recientes',
            ),
          );
        },
      ),
    );
  }
}

class botonAbajo extends StatelessWidget {
  const botonAbajo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_downward),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const ventanaRetroceder(); // widgetRuedaArriba es la clase que contiene la rueda giratoria
              },
            );
          },
        ));
  }
}

class botonDerecha extends StatelessWidget {
  const botonDerecha({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_forward_rounded),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.8, // Ancho del contenido
                  height: MediaQuery.of(context).size.height *
                      0.5, // Altura del contenido
                  child: const RotacionDerecha(), // Contenido centrado
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class imagenRobotCentral extends StatelessWidget {
  const imagenRobotCentral({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15.0),
      width: 200,
      height: 200,
      child: Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Center(
          child: Image.asset('assets/AttaBotRobot.png'),
        ),
      ),
    );
  }
}

class botonIzquierda extends StatelessWidget {
  const botonIzquierda({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.8, // Ancho del contenido
                  height: MediaQuery.of(context).size.height *
                      0.5, // Altura del contenido
                  child: const RotacionIzquierda(), // Contenido centrado
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class botonArriba extends StatelessWidget {
  const botonArriba({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_upward),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const ventanaAvanzar(); // widgetRuedaArriba es la clase que contiene la rueda giratoria
              },
            );
          },
        ));
  }
}

class botonBorrarHistorial extends StatelessWidget {
  const botonBorrarHistorial({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Provider.of<Historial>(context, listen: false).clear();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Historial eliminado'),
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
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Icon(Icons.delete_forever),
    );
  }
}

class BotonEjecutar extends StatelessWidget {
  BotonEjecutar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.play_circle_outline),
        onPressed: () async {
          // Crear un dispositivo con el ID dado
          final flutterReactiveBle = FlutterReactiveBle();
          await FlutterBluePlus.adapterState.first;

          String deviceId = "";

          if (Platform.isIOS) {
            deviceId = "FF8C3368-6EB6-D271-2BE5-AC5CCEBB578A";
          } else if (Platform.isAndroid) {
            deviceId = "80:84:6F:11:32:CA";
          }

          BluetoothDevice device =
              BluetoothDevice(remoteId: DeviceIdentifier(deviceId));

          if (Platform.isIOS) {
            connectToDeviceIos(device, context);
          } else if (Platform.isAndroid) {
            connectAndWriteToDevice(context, flutterReactiveBle);
          }
        });
  }

  Future<void> connectToDeviceIos(
      BluetoothDevice device, BuildContext context) async {
    await device.connect();

    List<BluetoothService> services = await device.discoverServices();
    BluetoothService service = services.firstWhere((service) =>
        service.uuid == Guid("4fafc201-1fb5-459e-8fcc-c5c9c331914b"));
    BluetoothCharacteristic characteristic = service.characteristics.firstWhere(
        (characteristic) =>
            characteristic.uuid ==
            Guid("beb5483e-36e1-4688-b7f5-ea07361b26a8"));

    List<String> historial =
        Provider.of<Historial>(context, listen: false).convertirComandos();
    String historialString = jsonEncode(historial);

    await characteristic.write(utf8.encode(historialString));
  }
}

Future<void> connectAndWriteToDevice(
    BuildContext context, FlutterReactiveBle flutterReactiveBle) async {
          // Obtener 'historial' cada vez que se presiona el botón
        var historial = Provider.of<Historial>(context, listen: false).convertirComandos();
        print(historial);

        // Asegúrate de reemplazar 'deviceId' con el ID de tu dispositivo BLE
        final deviceId = '80:64:6F:11:32:CA' ;
        final connectedDevice = await flutterReactiveBle.connectToDevice(id: deviceId);
        final characteristic = QualifiedCharacteristic(serviceId: Uuid.parse('4fafc201-1fb5-459e-8fcc-c5c9c331914b'), characteristicId: Uuid.parse('beb5483e-36e1-4688-b7f5-ea07361b26a8'), deviceId: deviceId);
        
        // Unir todos los elementos de la lista en una sola cadena
        var historialString = historial.join(",");
      
        flutterReactiveBle.writeCharacteristicWithResponse(characteristic, value: utf8.encode(historialString));
}

class menuDesplegable extends StatelessWidget {
  const menuDesplegable({
    required this.context,
    required TextEditingController controller,
    required List<String> historial,
  })  : _controller = controller,
        _historial = historial;

  final BuildContext context;
  final TextEditingController _controller;
  final List<String> _historial;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        showMenu(
          context: this.context,
          position: RelativeRect.fromLTRB(
            MediaQuery.of(this.context).size.width,
            kToolbarHeight,
            0.0,
            0.0,
          ),
          items: <PopupMenuEntry>[
            const PopupMenuItem(
              value: 'Opción 1',
              child: Text('Guardar Historial'),
            ),
            const PopupMenuItem(
              value: 'Opción 2',
              child: Text('Cargar Historial'),
            ),
          ],
          elevation: 8.0,
        ).then((value) {
          if (value == 'Opción 1') {
            Provider.of<Historial>(this.context, listen: false)
                .guardarArchivo(this.context);
          } else if (value == 'Opción 2') {
            Provider.of<Historial>(this.context, listen: false)
                .cargarArchivo(this.context);
          }
        });
      },
    );
  }
}

class BotonCambioColorCiclo extends StatefulWidget {
  const BotonCambioColorCiclo({Key? key}) : super(key: key);

  @override
  _BotonCambioColorCicloState createState() => _BotonCambioColorCicloState();
}

class _BotonCambioColorCicloState extends State<BotonCambioColorCiclo> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isPressed = !_isPressed;
        });
        if (_isPressed) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const DialogoCiclo();
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertDialog(
                title: Text('Fin del ciclo'),
              );
            },
          );
          Provider.of<Historial>(context, listen: false)
              .addEvento('Fin del ciclo');
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          _isPressed ? Colors.red : Colors.grey,
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      child: const Icon(Icons.refresh),
    );
  }
}

class DialogoCiclo extends StatefulWidget {
  const DialogoCiclo({Key? key}) : super(key: key);

  @override
  _DialogoCicloState createState() => _DialogoCicloState();
}

class _DialogoCicloState extends State<DialogoCiclo> {
  int cantidadDeVeces = 2;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Realizar ciclo $cantidadDeVeces veces'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              setState(() {
                if (cantidadDeVeces > 0) {
                  cantidadDeVeces--;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                cantidadDeVeces++;
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Realizar ciclo'),
          onPressed: () {
            Provider.of<Historial>(context, listen: false)
                .addEvento('Inicio de ciclo, $cantidadDeVeces ciclos');
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

//----------------------------------------------------------------------------------------

class BotonDeteccionObstaculos extends StatefulWidget {
  const BotonDeteccionObstaculos({Key? key}) : super(key: key);

  @override
  _BotonDeteccionObstaculosState createState() =>
      _BotonDeteccionObstaculosState();
}

class _BotonDeteccionObstaculosState extends State<BotonDeteccionObstaculos> {
  bool _isActivated = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.remove_red_eye_outlined),
      color: _isActivated ? Colors.red : Colors.grey,
      onPressed: () {
        setState(() {
          _isActivated = !_isActivated;
        });
        Provider.of<Historial>(context, listen: false).addEvento(_isActivated
            ? 'Detección de obstáculos activada'
            : 'Fin detección de obstáculos');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(_isActivated
                  ? 'Se ha activado la detección de obstáculos'
                  : 'Se ha desactivado la detección de obstáculos'),
            );
          },
        );
      },
    );
  }
}
