// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class Historial extends ChangeNotifier {
  List<String> _historial = [];

  List<String> get historial => _historial;

  void addEvento(String evento) {
    _historial.add(evento);
    notifyListeners();
  }

  void removeEvento(int index) {
    if (_historial[index].contains('Inicio de ciclo') ||
        _historial[index].contains('Detección de obstáculos activada')) {
      String endEvent = _historial[index].contains('Inicio de ciclo')
          ? 'Fin del ciclo'
          : 'Fin detección de obstáculos';
      int endIndex =
          _historial.indexWhere((element) => element.contains(endEvent), index);
      if (endIndex != -1) {
        _historial.removeRange(index, endIndex + 1);
      } else {
        _historial.removeRange(index, _historial.length);
      }
    } else {
      _historial.removeAt(index);
    }
    notifyListeners();
  }

  void clear() {
    _historial = [];
    notifyListeners();
  }

  // List<String> convertirComandos() {
  //   List<String> resultado = [];
  //   for (String comando in _historial) {
  //     if (comando.startsWith('Avanzar')) {
  //       resultado.add('AV ${comando.split(' ')[1]}');
  //     } else if (comando.startsWith('Retroceder')) {
  //       resultado.add('RE ${comando.split(' ')[1]}');
  //     } else if (comando.startsWith('Girar')) {
  //       if (comando.contains('izquierda')) {
  //         resultado.add('GI ${comando.split(' ')[1]}');
  //       } else {
  //         resultado.add('GD ${comando.split(' ')[1]}');
  //       }
  //     } else if (comando.startsWith('Inicio de ciclo')) {
  //       resultado.add('IN ${comando.split(' ')[3]}');
  //     } else if (comando.startsWith('Fin del ciclo')) {
  //       resultado.add('FI');
  //     } else if (comando.startsWith('Detección de obstáculos activada')) {
  //       resultado.add('IO');
  //     } else if (comando.startsWith('Fin detección de obstáculos')) {
  //       resultado.add('FO');
  //     }
  //   }
  //
  //   return resultado;
  // }
  List<String> convertirComandos() {
    List<String> resultado = ['ATINI'];
    for (String comando in _historial) {
      if (comando.startsWith('Avanzar')) {
        resultado.add('AV${_formatearNumero(comando.split(' ')[1])}');
      } else if (comando.startsWith('Retroceder')) {
        resultado.add('RE${_formatearNumero(comando.split(' ')[1])}');
      } else if (comando.startsWith('Girar')) {
        if (comando.contains('izquierda')) {
          resultado.add('GI${_formatearNumero(comando.split(' ')[1])}');
        } else {
          resultado.add('GD${_formatearNumero(comando.split(' ')[1])}');
        }
      } else if (comando.startsWith('Inicio de ciclo')) {
        resultado.add('CI${_formatearNumero(comando.split(' ')[3])}');
      } else if (comando.startsWith('Fin del ciclo')) {
        resultado.add('CIFIN');
      } else if (comando.startsWith('Detección de obstáculos activada')) {
        resultado.add('OBINI');
      } else if (comando.startsWith('Fin detección de obstáculos')) {
        resultado.add('OBFIN');
      }
    }

    resultado.add('ATFIN');
    return resultado;
  }

  String _formatearNumero(String numero) {
    // Si el número tiene menos de 3 caracteres, agregar ceros a la izquierda hasta alcanzar una longitud de 3 caracteres
    if (numero.length < 3) {
      return int.parse(numero).toString().padLeft(3, '0');
    } else {
      // Si el número ya tiene 3 caracteres, no es necesario formatearlo
      return numero;
    }
  }

  Future<void> guardarArchivo(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          widthFactor: 0.9,
          heightFactor: 0.9,
          child: AlertDialog(
            title: const Text('Ingresa el nombre del archivo'),
            content: SingleChildScrollView(
              child: TextField(
                controller: controller,
                decoration:
                    const InputDecoration(hintText: "Nombre del archivo"),
              ),
            ),
            actions: <Widget>[
              botonGuardar(controller: controller, historial: _historial),
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> cargarArchivo(BuildContext context) async {
    final directorio =
        await getApplicationDocumentsDirectory(); //final directorio = await getExternalStorageDirectory();
    final String nuevaUbicacion = '${directorio.path}/historial';
    final nuevoDirectorio = Directory(nuevaUbicacion);
    if (await nuevoDirectorio.exists()) {
      final archivos = nuevoDirectorio.listSync();
      final archivosDat =
          archivos.where((file) => file.path.endsWith('.dat')).toList();
      if (archivosDat.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Selecciona un archivo'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: archivosDat.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(archivosDat[index]
                          .path
                          .split('/')
                          .last), // Solo muestra el nombre del archivo
                      onTap: () async {
                        Navigator.of(context).pop();
                        final File file = File(archivosDat[index].path);
                        final String contents = await file.readAsString();
                        _historial = List<String>.from(jsonDecode(contents));
                        notifyListeners();
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('No hay archivos .dat'),
              content: const Text(
                  'No se encontraron archivos .dat en la carpeta /historial.'),
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
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Carpeta /historial no encontrada'),
            content: const Text('La carpeta /historial no existe.'),
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
  }
}

class botonGuardar extends StatelessWidget {
  const botonGuardar({
    super.key,
    required TextEditingController controller,
    required List<String> historial,
  })  : _controller = controller,
        _historial = historial;

  final TextEditingController _controller;
  final List<String> _historial;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('Guardar'),
      onPressed: () async {
        String nombre = _controller.text;
        if (nombre.length > 20 || !RegExp(r'^[a-z0-9_-]+$').hasMatch(nombre)) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Datos inválidos'),
                content: const SingleChildScrollView(
                  child: Text(
                      'El nombre no puede ser guardado porque contiene datos inválidos.'),
                ),
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
          return;
        }

        Navigator.of(context).pop();
        final directorio =
            await getApplicationDocumentsDirectory(); //final directorio = await getExternalStorageDirectory(); android
        final String nuevaUbicacion = '${directorio.path}/historial';
        final nuevoDirectorio = Directory(nuevaUbicacion);
        if (!await nuevoDirectorio.exists()) {
          await nuevoDirectorio.create();
        }
        final File archivo = File('$nuevaUbicacion/${_controller.text}.dat');
        await archivo.writeAsString(jsonEncode(_historial));

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return FractionallySizedBox(
              widthFactor: 0.9,
              heightFactor: 0.9,
              child: AlertDialog(
                title: const Text('Archivo Guardado'),
                content: SingleChildScrollView(
                  child: Text('Archivo guardado en: ${archivo.path}'),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class menuDesplegable extends StatelessWidget {
  const menuDesplegable({
    super.key,
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
      icon: const Icon(Icons.menu),
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
            //
            const PopupMenuItem(
              value: 'Opción 0',
              child: Text('¿Cómo funciono?',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            ),
            const PopupMenuItem(
              value: 'Opción 1',
              child: Text('Guardar Historial',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            ),
            const PopupMenuItem(
              value: 'Opción 2',
              child: Text('Cargar Historial',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            ),
            const PopupMenuItem(
              value: 'Opción 3',
              child: Text('Borrar Historial',
                  style: TextStyle(
                      color: Colors.red,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold)),
            ),
          ],
          elevation: 8.0,
        ).then((value) {
          if (value == 'Opción 0') {
              InfoDialog.show(context);
          }
          else if (value == 'Opción 1') {
            Provider.of<Historial>(this.context,
                    listen:
                        false) //si se marca la opcion 1 llama a la funcion guardar archivo del historial
                .guardarArchivo(this.context);
          } else if (value == 'Opción 2') {
            Provider.of<Historial>(this.context,
                    listen:
                        false) //si se marca la opcion 1 llama a la funcion cargar archivo del historial
                .cargarArchivo(this.context);
          } else if (value == 'Opción 3') {
            showDialog(
              context: this.context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirmación'),
                  content: const Text(
                      '¿Estás seguro de que quieres eliminar todo el historial?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancelar'),
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // Cierra el cuadro de diálogo
                      },
                    ),
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Provider.of<Historial>(this.context,
                                listen:
                                    false) //si se marca la opcion 1 llama a la funcion cargar archivo del historial
                            .clear();
                        Navigator.of(context).pop();
/*                        return AlertDialog(
                          title: const Text('Historial eliminado'),
                        actions: <Widget>[
                        TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                        Navigator.of(context).pop();
                        },
                        ),
                        ],
                        );*/
                      },
                    ),
                  ],
                );
              },
            );
          }
        });
      },
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



class ventanaHistorial extends StatefulWidget {
  const ventanaHistorial({Key? key}) : super(key: key);

  @override
  _ventanaHistorial createState() => _ventanaHistorial();
}

class _ventanaHistorial extends State<ventanaHistorial> {
  final TextEditingController controller = TextEditingController();
  final List<String> historial = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),

        actions: <Widget>[
          menuDesplegable(
            context: context,
            controller: controller,
            historial: historial,
          ),
        ],
      ),
      body: Consumer<Historial>(
        builder: (context, historial, child) {
          bool inicioCiclo = false;
          bool deteccionObstaculos = false;
          return ListView.builder(
            itemCount: historial.historial.length,
            itemBuilder: (context, index) {
              Color? color;
              double padding = 8.0;
              if (historial.historial[index].contains('Inicio de ciclo')) {
                color = const Color.fromARGB(255, 158, 11, 158);
                inicioCiclo = true;
              } else if (historial.historial[index].contains('Fin del ciclo')) {
                color = const Color.fromARGB(255, 158, 11, 158);
                inicioCiclo = false;
              } else if (historial.historial[index]
                  .contains('Detección de obstáculos activada')) {
                color = const Color.fromARGB(255, 11, 158, 158);
                deteccionObstaculos = true;
              } else if (historial.historial[index]
                  .contains('Fin detección de obstáculos')) {
                color = const Color.fromARGB(255, 11, 158, 158);
                deteccionObstaculos = false;
              } else if (inicioCiclo || deteccionObstaculos) {
                padding = 50.0;
                if (historial.historial[index].contains('Avanzar')) {
                  color = Colors.lightGreen[100];
                } else if (historial.historial[index].contains('Retroceder')) {
                  color = Colors.red[100];
                } else if (historial.historial[index].contains('derecha')) {
                  color = Colors.lightBlue[100];
                } else if (historial.historial[index].contains('izquierda')) {
                  color = Colors.yellow[100];
                }
              } else {
                if (historial.historial[index].contains('Avanzar')) {
                  color = Colors.lightGreen[100];
                } else if (historial.historial[index].contains('Retroceder')) {
                  color = Colors.red[100];
                } else if (historial.historial[index].contains('derecha')) {
                  color = Colors.lightBlue[100];
                } else if (historial.historial[index].contains('izquierda')) {
                  color = Colors.yellow[100];
                }
              }
              return Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: EdgeInsets.fromLTRB(padding, 8.0, 8.0, 8.0),
                child: ListTile(
                  title: Text(historial.historial[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirmación'),
                            content: const Text(
                                '¿Estás seguro de que quieres eliminar este elemento?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancelar'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Cierra el cuadro de diálogo
                                },
                              ),
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  historial.removeEvento(
                                      index); // Elimina el elemento
                                  Navigator.of(context)
                                      .pop(); // Cierra el cuadro de diálogo
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
