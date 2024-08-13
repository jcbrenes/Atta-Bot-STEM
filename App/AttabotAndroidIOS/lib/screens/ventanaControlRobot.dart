import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as flutter_blue;
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/instruction-history/services/history_service.dart';
import 'package:proyecto_tec/pages/history_page.dart';
import 'package:proyecto_tec/screens/ventanaGirarDerecha.dart';
import 'package:proyecto_tec/screens/ventanaHistorial.dart';
import 'package:proyecto_tec/screens/ventanaGirarIzquierda.dart';
//import 'package:flutter_blue/flutter_blue.dart';
import 'ventanaAvanzarRetroceder.dart';
import 'globals.dart' as globals;



// Pantalla principal de control del robot.
class pantallaControlRobot extends StatefulWidget {
  const pantallaControlRobot({Key? key}) : super(key: key);

  @override
  _pantallaControlRobotState createState() => _pantallaControlRobotState();
}

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

// Incluye la lógica para manejar los gestos de deslizamiento y construir la interfaz de usuario.
class _pantallaControlRobotState extends State<pantallaControlRobot> {
  final TextEditingController controller = TextEditingController();
  final List<String> historial = [];

  // maneja los gestos de deslizamiento en la aplicación.
  void _onSwipe(DragEndDetails detalles) {
    if (detalles.primaryVelocity! < 0) {
      scaffoldKey.currentState?.openEndDrawer();
      //Scaffold.of(context).openEndDrawer();
    }
  }

  // construye la interfaz de usuario de la aplicación.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: false,
          // cuando salia el teclado para ingresar datos me generaba un overflow en la pantalla, esta linea lo soluciona
          // appBar: AppBar(
          //   title: const Text('Atta-bot Educativo'),
          //   centerTitle: true,
          //   actions: <Widget>[
          //     menuDesplegable(
          //       context: context,
          //       controller: controller,
          //       historial: historial,
          //     ),
          //   ],
          // ),
          body: GestureDetector(
            onHorizontalDragEnd: _onSwipe,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF798DB1), Color(0xFF152A51)],
                ),
              ),
              //margin: const EdgeInsets.fromLTRB(0),

              child: const Column(
                children: <Widget>[
                  SizedBox(height: 60), //Esto es para poner margenes aunque creo que se deberia hacer de otra forma
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:6.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0), // Margen a la derecha
                      child: botonInfo(),
                    ),
                    Spacer(),
                    textoInicio(),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0), // Margen a la izquierda
                      child: botonAbrirMenu(),
                    ),
                  ],
                ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(

                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[


                          botonArriba(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              botonIzquierda(),
                              imagenRobotCentral(),
                              botonDerecha(),
                            ],
                          ),
                          botonAbajo(),
                          Column(
                            children: <Widget>[
                              textfieldUltimaAccion(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  BotonDeteccionObstaculos(),
                                  BotonEjecutar(),
                                  BotonCambioColorCiclo(),

                                ],

                              ),
                              SizedBox(height: 60),
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
        ));
  }
}

//muestra la última acción realizada en un campo de texto.
class textfieldUltimaAccion extends StatelessWidget {
  const textfieldUltimaAccion({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(30.0),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // Borde redondeado
        border: Border.all(color: Colors.white,width:3.0),
        // Delineado blanco en el contorno
        color: Colors.transparent,
      ),
      child: Consumer<HistoryService>(
        builder: (context, historial, child) {
          return Center(
            child: Text(
              // lo fillea con la ultima accion del historial
              historial.historyValue.isNotEmpty
                  ? historial.historyValue.last
                  : 'No hay acciones recientes',
              style: const TextStyle(
                color: Colors.white,
                // Letras transparentes
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                height: 0.9,
              ),
            ),
          );
        },
      ),
    );
  }
}

//botón para mover el robot hacia abajo.
class botonAbajo extends StatelessWidget {
  const botonAbajo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_downward),
          //aca se encuentra el icono que se utiliza para ponerlo en pantalla
          color: Colors.white,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const ventanaRetroceder();
              },
            );
          },
        ));
  }
}

//botón para mover el robot hacia la derecha, es la parte grafica del boton
class botonDerecha extends StatelessWidget {
  const botonDerecha({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: IconButton(
        icon: const Icon(Icons.rotate_right_outlined),
        color: Colors.white,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFFBBCEF1), // Establecer el color de fondo del AlertDialog
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Ajustar la curvatura de las esquinas
                  side: const BorderSide(color: Colors.white, width: 5.0), // Agregar borde blanco
                ),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child:
                      const RotacionDerecha(), //llama al widget que realiza la parte grafica y logica de la rotacion
                ),
              );
            },
          );
        },
      ),
    );
  }
}

//muestra una imagen del robot en el centro de la pantalla.
class imagenRobotCentral extends StatelessWidget {
  const imagenRobotCentral({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 20.0),
      width: 240,
      height: 240,
      child: Padding(
        padding: const EdgeInsets.only(left: 0),
        child: Center(
          child: Image.asset(
              'assets/AttaBotRobot_uno.png'), //aca es donde carga la imagen central del robot
        ),
      ),
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
      'Atta-Bot STEM',
      style: TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontFamily: 'Poppins',
        // Establecer la fuente como Poppins
        fontWeight: FontWeight.w900,
        // Establecer el peso de la fuente como extrabold (800)height: 0.
        height: 1.1,
      ),
      textAlign: TextAlign.left,
    );
  }
}

//botón para mover el robot hacia la izquierda, es la parte grafica del boton
class botonIzquierda extends StatelessWidget {
  const botonIzquierda({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: IconButton(
        icon: const Icon(Icons.rotate_left_outlined),
        color: Colors.white,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFFBBCEF1), // Establecer el color de fondo del AlertDialog
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Ajustar la curvatura de las esquinas
                  side: const BorderSide(color: Colors.white, width: 5.0), // Agregar borde blanco
                ),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child:
                      const RotacionIzquierda(), //llama al widget que realiza la parte grafica y logica de la rotacion
                ),
              );
            },
          );
        },
      ),
    );
  }
}
class botonInfo extends StatelessWidget {
  const botonInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,  // Ancho del container
      height: 40, // Alto del container
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20), // Ajusta el radio según el tamaño del container
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: IconButton(
        icon: const Icon(Icons.question_mark_outlined),
        color: Colors.white,
        onPressed: () {
          InfoDialog.show(context);
        },
        iconSize: 20, // Ajusta el tamaño del icono
        padding: EdgeInsets.zero, // Elimina el padding interno del IconButton
        constraints: BoxConstraints(
          maxHeight: 40, // Asegura que el tamaño del IconButton coincida con el Container
          maxWidth: 40,
        ),
      ),
    );
  }
}
class botonAbrirMenu extends StatelessWidget {

  const botonAbrirMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: IconButton(
        icon: Icon(Icons.article_rounded),
        color: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HistoryPage(),
            ),
          );
        },
        iconSize: 20,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          maxHeight: 40,
          maxWidth: 40,
        ),
      ),
    );
  }
}
class InfoDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "¿Cómo funciono?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFDDE6F7), // Establecer el color de fondo del AlertDialog
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Ajustar la curvatura de las esquinas
            side: const BorderSide(color: Colors.white, width: 5.0), // Agregar borde blanco
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.arrow_upward),
                title: RichText(
                  text: const TextSpan(
                    text: 'Avanzar ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF152A51)),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'una cantidad de centímetros indicada',
                        style: TextStyle(fontWeight: FontWeight.normal, color: Color(0xFF152A51)
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.arrow_downward),
                title: RichText(
                  text: const TextSpan(
                    text: 'Retroceder ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF152A51)
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'una cantidad de centímetros indicada',
                        style: TextStyle(fontWeight: FontWeight.normal, color: Color(0xFF152A51)
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.rotate_right),
                title: RichText(
                  text: const TextSpan(
                    text: 'Girar a la derecha ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF152A51)
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'una cantidad de grados indicada',
                        style: TextStyle(fontWeight: FontWeight.normal, color: Color(0xFF152A51)
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.rotate_left),
                title: RichText(
                  text: const TextSpan(
                    text: 'Girar a la izquierda ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF152A51)
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'una cantidad de grados indicada',
                        style: TextStyle(fontWeight: FontWeight.normal, color: Color(0xFF152A51)
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.remove_red_eye),
                title: RichText(
                  text: const TextSpan(
                    text: 'Activar detección de obstáculos ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF152A51)
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'hasta deseleccionar',
                        style: TextStyle(fontWeight: FontWeight.normal, color: Color(0xFF152A51)
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.autorenew),
                title: RichText(
                  text: const TextSpan(
                    text: 'Iniciar un ciclo, ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF152A51)
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'una cantidad de veces',
                        style: TextStyle(fontWeight: FontWeight.normal, color: Color(0xFF152A51)
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
//botón para mover el robot hacia la arriba, es la parte grafica del boton
class botonArriba extends StatelessWidget {
  const botonArriba({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_upward),
          color: Colors.white,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const ventanaAvanzar(); //llama al widget que realiza la parte grafica y logica de la rotacion
              },
            );
          },
        ));
  }
}

// Define un StatefulWidget para BotonEjecutar
class BotonEjecutar extends StatefulWidget {
  const BotonEjecutar({Key? key}) : super(key: key);

  @override
  _BotonEjecutarState createState() => _BotonEjecutarState();
}

class _BotonEjecutarState extends State<BotonEjecutar> {
  String _selectedOption = 'AttaBotSTEM1'; // Opción seleccionada por defecto

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 3), // Bordes blancos
      ),
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            color: Colors.white,
            onPressed: _showOptionsDialog, // Mostrar el diálogo al presionar el botón
          ),
        ],
      ),
    );
  }

  // Método para mostrar el diálogo de opciones
  void _showOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Seleccionar opción'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _optionRadioTile(setState, 'AttaBotSTEM1'),
                  _optionRadioTile(setState, 'AttaBotSTEM2'),
                  _optionRadioTile(setState, 'AttaBotSTEM3'),
                  _optionRadioTile(setState, 'AttaBotSTEM4'),
                  _optionRadioTile(setState, 'AttaBotSTEM5'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el diálogo sin ejecutar nada
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (!globals.isPressed){
                      Navigator.of(context).pop();
                      _executeAction(_selectedOption);// Ejecutar la acción seleccionada
                    }
                    else{
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(

                            title: const Text('Debe cerrar el ciclo antes de poder ejecutar las instrucciones'),
                            backgroundColor: const Color(0xFFBBCEF1), // Establecer el color de fondo del AlertDialog
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0), // Ajustar la curvatura de las esquinas
                              side: const BorderSide(color: Colors.white, width: 5.0), // Agregar borde blanco
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Cerrar el diálogo sin ejecutar nada
                                },
                                child: const Text('Ok'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text('Ejecutar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Método para construir un RadioListTile para cada opción
  Widget _optionRadioTile(StateSetter setState, String option) {
    return RadioListTile(
      title: Text(option),
      value: option,
      groupValue: _selectedOption,
      onChanged: (String? value) {
        setState(() {
          _selectedOption = value!; // Actualizar la opción seleccionada
        });
      },
    );
  }
  // Método para ejecutar la acción correspondiente a la opción seleccionada
  void _executeAction(idDispositivoBuscado) async {
    final flutterReactiveBle = FlutterReactiveBle();
    await flutter_blue.FlutterBluePlus.adapterState.first;
    String idDispositivo = '';

    if (Platform.isIOS) {
      idDispositivo = "FF8C3368-6EB6-D271-2BE5-AC5CCEBB578A"; // ID de dispositivo esp32 solo se usa si es iOS el dispositivo
    }
    flutter_blue.BluetoothDevice dispositivo =
    flutter_blue.BluetoothDevice(remoteId: flutter_blue.DeviceIdentifier(idDispositivo));

    if (Platform.isIOS) {
      conexionIos(dispositivo, context); // si es iOS llama a esta función para hacer la conexión
    } else if (Platform.isAndroid) {
      conexionAndroid(context, flutterReactiveBle,idDispositivoBuscado); // si es android llama a esta función para hacer la conexión
    }
  }


//funcion que me permite enviar los datos si el dispositivo es ios
//rastrea primero los dispositivos para emparejar, usa un caracteristico y un servicio ya que se usa BLE bluethoot de baja frecuencia
  Future<void> conexionIos(flutter_blue.BluetoothDevice device, BuildContext context) async {
    await device.connect();

    List<flutter_blue.BluetoothService> servicios = await device.discoverServices();
    flutter_blue.BluetoothService servicio = servicios.firstWhere((service) =>
        service.uuid == flutter_blue.Guid("4fafc201-1fb5-459e-8fcc-c5c9c331914b"));
    flutter_blue.BluetoothCharacteristic caracteristico = servicio.characteristics
        .firstWhere((characteristic) =>
            characteristic.uuid ==
                flutter_blue.Guid("beb5483e-36e1-4688-b7f5-ea07361b26a8"));

    List<String> historial = Provider.of<Historial>(context, listen: false)
        .convertirComandos(); //codifica los comandos primeros tipo nemonicos antes de enviarlos
    String historialString = jsonEncode(historial);

    await caracteristico.write(
        utf8.encode(historialString)); //envia los datos tipo utf8 al esp32
  }
}

//funcion que me permite enviar los datos si el dispositivo es android
//rastrea primero los dispositivos para emparejar, usa un caracteristico y un servicio ya que se usa BLE bluethoot de baja frecuencia
Future<void> conexionAndroid(
  BuildContext context,
  FlutterReactiveBle flutterReactiveBle,
    idDispositivoBuscado
) async {
  // Obtener 'historial' cada vez que se presiona el botón
  var historial =
      Provider.of<Historial>(context, listen: false).convertirComandos();
  //80:64:6f:11:32:c8 //direccion mac del esp32 antes de sumarle 2 al ultimo digito
  //const dispositivoID = 'D4:D4:DA:16:AC:CA'; //direccion mac del esp32
//80:64:6F:11:32:CA
  //const dispositivoID = 'D4:8A:FC:B6:5C:F2';

  try {
    var dispositivoID = await startScan(flutterReactiveBle,idDispositivoBuscado,context);
    print("dispositivoID:");
    print(dispositivoID);

    final connectionStream = flutterReactiveBle.connectToDevice(id: dispositivoID);

    // Manejar la suscripción al stream
    StreamSubscription<ConnectionStateUpdate>? connectionSubscription;

    connectionSubscription = connectionStream.listen((state) async {
      if (state.connectionState == DeviceConnectionState.connected) {
        print('Dispositivo conectado: $dispositivoID');

        final caracteristico = QualifiedCharacteristic(
          serviceId: Uuid.parse('4fafc201-1fb5-459e-8fcc-c5c9c331914b'),
          characteristicId: Uuid.parse('beb5483e-36e1-4688-b7f5-ea07361b26a8'),
          deviceId: dispositivoID,
        );

        // Unir todos los elementos de la lista en una sola cadena
        var historialString = historial.join("");
        print(historialString);

        try {
          print("escribiendo característico");
          await flutterReactiveBle.writeCharacteristicWithResponse(
            caracteristico,
            value: utf8.encode(historialString),
          );
          print('Escritura exitosa');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Se enviaron las instrucciones correctamente'),
                backgroundColor: const Color(0xFFBBCEF1), // Establecer el color de fondo del AlertDialog
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // Ajustar la curvatura de las esquinas
                  side: const BorderSide(color: Colors.white, width: 5.0), // Agregar borde blanco
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar el diálogo sin ejecutar nada
                    },
                    child: const Text('Ok'),
                  ),
                ],
              );
            },
          );
        } catch (e) {
          print('Error al escribir: $e');

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(

                title: const Text('Error al enviar las instrucciones'),
                content: Text(
                    'error: $e'),
                backgroundColor: const Color(0xFFBBCEF1), // Establecer el color de fondo del AlertDialog
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // Ajustar la curvatura de las esquinas
                  side: const BorderSide(color: Colors.white, width: 5.0), // Agregar borde blanco
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar el diálogo sin ejecutar nada
                    },
                    child: const Text('Ok'),
                  ),
                ],
              );
            },
          );
        }

        // Cancelar la suscripción después de escribir
        await connectionSubscription?.cancel();
      } else if (state.connectionState == DeviceConnectionState.disconnected) {
        print('Dispositivo desconectado: $dispositivoID');
        await connectionSubscription?.cancel(); // Cancelar la suscripción si se desconecta
      }
    });
  } catch (e) {
    print('Error durante el proceso: $e');
  }
}

Future<String> startScan(FlutterReactiveBle flutterReactiveBle,idDispositivoBuscado,context) async {
  print(idDispositivoBuscado);
  List<DiscoveredDevice> devices = [];
  StreamController<List<DiscoveredDevice>> controller = StreamController();
  String idDispositivo = '';
  Completer<String> completer = Completer<String>();

  final subscription = flutterReactiveBle.scanForDevices(
    withServices: [],
    scanMode: ScanMode.lowLatency,
  ).listen((device) {
    if (!devices.any((d) => d.id == device.id)) {
      devices.add(device);
      print('Dispositivo encontrado: ${device.name}, ID: ${device.id}');
      if (device.name.toString() == idDispositivoBuscado) {
        print('Se encontró a AttaBot');
        idDispositivo = device.id;
        if (!completer.isCompleted) {
          completer.complete(idDispositivo); // Completar el completer
        }
        //subscription.cancel(); // Cancelar la suscripción al stream
        if (!controller.isClosed) {
          controller.close(); // Cerrar el controlador
        }
        return;
      }
      if (!controller.isClosed) {
        controller.add(List.from(devices));
      }
    }
  }, onError: (error) {
    print('Error durante el escaneo: $error');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(

          title: const Text('Error durante el escaneo'),
          content: Text(
              'error: $error'),
          backgroundColor: const Color(0xFFBBCEF1), // Establecer el color de fondo del AlertDialog
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0), // Ajustar la curvatura de las esquinas
            side: const BorderSide(color: Colors.white, width: 5.0), // Agregar borde blanco
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo sin ejecutar nada
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
    if (!controller.isClosed) {
      controller.addError(error);
      controller.close();  // Cerrar el controlador en caso de error
    }
    if (!completer.isCompleted) {
      completer.completeError(error); // Completar el completer con el error
    }
  }, onDone: () {
    if (!controller.isClosed) {
      controller.close();  // Cerrar el controlador cuando el escaneo termine
    }
  });

  return completer.future; // Devolver el future del completer
}



//
// //menu desplegable arriba derecha de la pantalla, contiene las funcionalidades de guardar y cargar datos
// class menuDesplegable extends StatelessWidget {
//   const menuDesplegable({super.key,
//     required this.context,
//     required TextEditingController controller,
//     required List<String> historial,
//   })  : _controller = controller,
//         _historial = historial;
//
//   final BuildContext context;
//   final TextEditingController _controller;
//   final List<String> _historial;
//
//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.add),
//       onPressed: () {
//         showMenu(
//           context: this.context,
//           position: RelativeRect.fromLTRB(
//             MediaQuery.of(this.context).size.width,
//             kToolbarHeight,
//             0.0,
//             0.0,
//           ),
//           items: <PopupMenuEntry>[//
//             const PopupMenuItem(
//               value: 'Opción 1',
//               child: Text('Guardar Historial'),
//             ),
//             const PopupMenuItem(
//               value: 'Opción 2',
//               child: Text('Cargar Historial'),
//             ),
//           ],
//           elevation: 8.0,
//         ).then((value) {
//           if (value == 'Opción 1') {
//             Provider.of<Historial>(this.context, listen: false) //si se marca la opcion 1 llama a la funcion guardar archivo del historial
//                 .guardarArchivo(this.context);
//           } else if (value == 'Opción 2') {
//             Provider.of<Historial>(this.context, listen: false)//si se marca la opcion 1 llama a la funcion cargar archivo del historial
//                 .cargarArchivo(this.context);
//           }
//         });
//       },
//     );
//   }
// }
//

//clase del boton del ciclo, tiene la funcionalidad grafica de cambiar el color del boton de acuerdo si se preciono o no
class BotonCambioColorCiclo extends StatefulWidget {
  const BotonCambioColorCiclo({Key? key}) : super(key: key);

  @override
  _BotonCambioColorCicloState createState() => _BotonCambioColorCicloState();
}


class _BotonCambioColorCicloState extends State<BotonCambioColorCiclo> {


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white,width: 3), // Bordes blancos
      ),
      child: IconButton(
          icon: const Icon(Icons.autorenew),
          color: Colors.white,
          onPressed: () {

            if (!globals.isPressed) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const DialogoCiclo();
                },
              );
            } else {
              globals.isPressed = !globals.isPressed;
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(

                    title: const Text('Fin del ciclo'),
                    backgroundColor: const Color(0xFFBBCEF1), // Establecer el color de fondo del AlertDialog
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0), // Ajustar la curvatura de las esquinas
                      side: const BorderSide(color: Colors.white, width: 5.0), // Agregar borde blanco
                    ),
                  );
                },
              );
              Provider.of<HistoryService>(context,
                      listen:
                          false) //agrega Fin del ciclo al historial si se toco 2 veces
                  .addInstruction('Fin del ciclo');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,// Fondo transparente
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
      ),
    );
  }
}

//pantalla emergente que pregunta cuantas veces quiere realizar el ciclo
class DialogoCiclo extends StatefulWidget {
  const DialogoCiclo({Key? key}) : super(key: key);

  @override
  _DialogoCicloState createState() => _DialogoCicloState();
}

class _DialogoCicloState extends State<DialogoCiclo> {
  int cantidadDeVeces = 2; // minimo de veces para realizar el ciclo

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Realizar ciclo $cantidadDeVeces veces'),
      backgroundColor: const Color(0xFFBBCEF1), // Establecer el color de fondo del AlertDialog
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Ajustar la curvatura de las esquinas
        side: const BorderSide(color: Colors.white, width: 5.0), // Agregar borde blanco
      ),

      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              setState(() {
                if (cantidadDeVeces > 0) {
                  //permite bajar la cantidad de veces, si llega a 0 no hace nada
                  cantidadDeVeces--;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                //permite aumentar la cantidad de veces, no tiene limite
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
            globals.isPressed = !globals.isPressed;
            Provider.of<HistoryService>(context, listen: false).addInstruction(
                'Inicio de ciclo, $cantidadDeVeces ciclos'); // envia la info al historial
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

//boton de deteccion de obstaculos
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
    return Container(
      width: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white,width: 3), // Bordes blancos
      ),
      child: IconButton(
        icon: const Icon(Icons.remove_red_eye_outlined),
        color: _isActivated ? Colors.red : Colors.white,
        onPressed: () {
          setState(() {
            _isActivated = !_isActivated;
          });
          Provider.of<HistoryService>(context, listen: false).addInstruction(
              _isActivated //envia la informacion aca si se activa o se desactiva
                  ? 'Detección de obstáculos activada'
                  : 'Fin detección de obstáculos');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFFBBCEF1), // Establecer el color de fondo del AlertDialog
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // Ajustar la curvatura de las esquinas
                  side: const BorderSide(color: Colors.white, width: 5.0), // Agregar borde blanco
                ),
                title: Text(_isActivated // lo muestra en pantalla
                    ? 'Se ha activado la detección de obstáculos'
                    : 'Se ha desactivado la detección de obstáculos'),
              );

            },
          );
        },
      ),
    );
  }
}
