import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'globals.dart' as globals;

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
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              botonGuardar(controller: controller, historial: _historial),
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
        if (_historial.isEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const SingleChildScrollView(
                  child: Text(
                      'No se pueden guardar listas de instrucciones vacías.'),
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
        if (globals.isPressed){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(

                title: const Text('Debe cerrar el ciclo antes de poder guardar las instrucciones'),
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
          return;
        }
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

        final directorio =
        await getApplicationDocumentsDirectory(); //final directorio = await getExternalStorageDirectory(); android
        final String nuevaUbicacion = '${directorio.path}/historial';
        final nuevoDirectorio = Directory(nuevaUbicacion);
        if (!await nuevoDirectorio.exists()) {
          await nuevoDirectorio.create();
        }

        final File archivo = File('$nuevaUbicacion/${_controller.text}.dat');

        if (await archivo.exists()) {
          bool? sobrescribir = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirmar Sobrescritura'),
                content: const Text('Ya existe un archivo con este nombre. ¿Desea sobrescribirlo?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: const Text('Sí'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          );

          if (sobrescribir != true) {
            return;
          }
        }

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
              value: 'Opción 1',
              child: Text('Guardar Instrucciones',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            ),
            const PopupMenuItem(
              value: 'Opción 2',
              child: Text('Cargar Instrucciones',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            ),
            const PopupMenuItem(
              value: 'Opción 3',
              child: Text('Borrar Instrucciones',
                  style: TextStyle(
                      color: Colors.red,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold)),
            ),
          ],
          elevation: 8.0,
        ).then((value) {
          if (value == 'Opción 1') {
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
        title: const Text(
        'Instrucciones',
          style: TextStyle(
          fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF586B8F),
        actions: <Widget>[
          menuDesplegable(
            context: context,
            controller: controller,
            historial: historial,
          ),
        ],
      ),
    body: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF798DB1), Color(0xFF586B8F)],
      ),
    ),
      child: Consumer<Historial>(
        builder: (context, historial, child) {
          bool inicioCiclo = false;
          bool deteccionObstaculos = false;
          return ListView.builder(
            itemCount: historial.historial.length,
            itemBuilder: (context, index) {
              Color? color;
              double padding = 8.0;
              if (historial.historial[index].contains('Inicio de ciclo')) {
                color = const Color(0xFFF2B100);
                inicioCiclo = true;
              } else if (historial.historial[index].contains('Fin del ciclo')) {
                color = const Color(0xFFF2B100);
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
                  color = const Color(0XFF006DBD);
                } else if (historial.historial[index].contains('Retroceder')) {
                  color = const Color(0xFF006DBD);
                } else if (historial.historial[index].contains('derecha')) {
                  color = const Color(0xFFF47E3E);
                } else if (historial.historial[index].contains('izquierda')) {
                  color = const Color(0xFFF47E3E);
                }
              } else {
                if (historial.historial[index].contains('Avanzar')) {
                  color = const Color(0XFF006DBD);
                } else if (historial.historial[index].contains('Retroceder')) {
                  color = const Color(0xFF006DBD);
                } else if (historial.historial[index].contains('derecha')) {
                  color = const Color(0xFFF47E3E);
                } else if (historial.historial[index].contains('izquierda')) {
                  color = const Color(0xFFF47E3E);
                }
              }
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color!, const Color.fromRGBO(245, 248, 249, 0.6)],//Color(0xFFF5F8F9)],
                  ),
                ),
                margin: EdgeInsets.fromLTRB(padding, 8.0, 8.0, 8.0),
                child: ListTile(
                  title: Text(historial.historial[index],style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF152A51),
                  ),),
                  trailing: !historial.historial[index].contains('Fin del ciclo')
                      ? IconButton(
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
                  ): null,
                ),
              );
            },
          );
        },
      ),
    ),
    );
  }
}
