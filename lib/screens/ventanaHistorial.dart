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

  List<String> convertirComandos() {
    List<String> resultado = [];
    for (String comando in _historial) {
      if (comando.startsWith('Avanzar')) {
        resultado.add('AV ${comando.split(' ')[1]}');
      } else if (comando.startsWith('Retroceder')) {
        resultado.add('RE ${comando.split(' ')[1]}');
      } else if (comando.startsWith('Girar')) {
        if (comando.contains('izquierda')) {
          resultado.add('GI ${comando.split(' ')[1]}');
        } else {
          resultado.add('GD ${comando.split(' ')[1]}');
        }
      } else if (comando.startsWith('Inicio de ciclo')) {
        resultado.add('IN ${comando.split(' ')[3]}');
      } else if (comando.startsWith('Fin del ciclo')) {
        resultado.add('FI');
      } else if (comando.startsWith('Detección de obstáculos activada')) {
        resultado.add('IO');
      } else if (comando.startsWith('Fin detección de obstáculos')) {
        resultado.add('FO');
      }
    }

    return resultado;
  }

  Future<void> guardarArchivo(BuildContext context) async {
    final TextEditingController _controller = TextEditingController();
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
                controller: _controller,
                decoration:
                    const InputDecoration(hintText: "Nombre del archivo"),
              ),
            ),
            actions: <Widget>[
              botonGuardar(controller: _controller, historial: _historial),
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
    final String nuevaUbicacion = '${directorio!.path}/historial';
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
              content: Container(
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
                content: SingleChildScrollView(
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
        final String nuevaUbicacion = '${directorio!.path}/historial';
        final nuevoDirectorio = Directory(nuevaUbicacion);
        if (!await nuevoDirectorio.exists()) {
          await nuevoDirectorio.create();
        }
        final File archivo = File('${nuevaUbicacion}/${_controller.text}.dat');
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

class ventanaHistorial extends StatelessWidget {
  const ventanaHistorial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
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
