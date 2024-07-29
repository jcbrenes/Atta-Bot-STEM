import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/screens/ventanaHistorial.dart';

class InstructionHistoryDropdown extends StatelessWidget {
  const InstructionHistoryDropdown({
    super.key,
    required this.context,
  });

  final BuildContext context;

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
