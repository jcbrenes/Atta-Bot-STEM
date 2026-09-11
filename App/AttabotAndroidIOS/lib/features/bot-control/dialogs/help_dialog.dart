import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/primary_icon_button.dart';
import 'package:proyecto_tec/features/simulator/components/grid_simulator.dart';

class HelpDialog {
  static void show(
    BuildContext context, {
    bool? useRootNavigator,
    bool showSimulatorScale = false,
  }) {
    showDialog(
      context: context,
      useRootNavigator: useRootNavigator ?? true,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(30, 10, 10, 0),
          contentPadding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
          title: Row(
            children: [
              const Expanded(
                child: Text(
                  '¿Cómo funciono?',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: neutralWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Poppins'),
                ),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: neutralWhite,
                  ))
            ],
          ),
          backgroundColor: neutralDarkBlueAD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: Colors.white, width: 4.0),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showSimulatorScale) ...[
                    _buildSimulatorScaleInfo(),
                    const SizedBox(height: 16),
                  ],
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    leading: PrimaryIconButton(
                      borderRadius: 6,
                      borderWidth: 3,
                      horizontalPadding: 10,
                      verticalPadding: 10,
                      color: primaryBlue,
                      disabled: true,
                      onPressed: () {},
                      child: Image.asset(
                        'assets/button_icons/forward_arrow.png',
                        color: neutralWhite,
                        height: 20,
                        width: 20,
                      ),
                    ),
                    title: RichText(
                      text: const TextSpan(
                        text: 'Avanzar ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: neutralWhite,
                            fontFamily: 'Poppins'),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'una cantidad de centímetros',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: neutralWhite,
                                fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    leading: PrimaryIconButton(
                      borderRadius: 6,
                      borderWidth: 3,
                      horizontalPadding: 10,
                      verticalPadding: 10,
                      color: primaryBlue,
                      disabled: true,
                      onPressed: () {},
                      child: Image.asset(
                        'assets/button_icons/backward_arrow.png',
                        color: neutralWhite,
                        height: 20,
                        width: 20,
                      ),
                    ),
                    title: RichText(
                      text: const TextSpan(
                        text: 'Retroceder ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: neutralWhite,
                            fontFamily: 'Poppins'),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'una cantidad de centímetros',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: neutralWhite,
                                fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    leading: PrimaryIconButton(
                      borderRadius: 6,
                      borderWidth: 3,
                      horizontalPadding: 10,
                      verticalPadding: 10,
                      color: secondaryIconOrange,
                      disabled: true,
                      onPressed: () {},
                      child: Image.asset(
                        'assets/button_icons/rotate_right.png',
                        color: neutralWhite,
                        height: 20,
                        width: 20,
                      ),
                    ),
                    title: RichText(
                      text: const TextSpan(
                        text: 'Girar a la derecha ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: neutralWhite,
                            fontFamily: 'Poppins'),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'una cantidad de grados',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: neutralWhite,
                                fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    leading: PrimaryIconButton(
                      borderRadius: 6,
                      borderWidth: 3,
                      horizontalPadding: 10,
                      verticalPadding: 10,
                      color: secondaryIconOrange,
                      disabled: true,
                      onPressed: () {},
                      child: Image.asset(
                        'assets/button_icons/rotate_left.png',
                        color: neutralWhite,
                        height: 20,
                        width: 20,
                      ),
                    ),
                    title: RichText(
                      text: const TextSpan(
                        text: 'Girar a la izquierda ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: neutralWhite,
                            fontFamily: 'Poppins'),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'una cantidad de grados',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: neutralWhite,
                                fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    leading: PrimaryIconButton(
                      borderRadius: 6,
                      borderWidth: 3,
                      horizontalPadding: 10,
                      verticalPadding: 10,
                      color: secondaryGreen,
                      disabled: true,
                      onPressed: () {},
                      child: Image.asset(
                        'assets/button_icons/cycle.png',
                        color: neutralWhite,
                        height: 20,
                        width: 20,
                      ),
                    ),
                    title: RichText(
                      text: const TextSpan(
                        text: 'Iniciar un ciclo, ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: neutralWhite,
                            fontFamily: 'Poppins'),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'una cantidad de veces',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: neutralWhite,
                                fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    leading: PrimaryIconButton(
                      borderRadius: 6,
                      borderWidth: 3,
                      horizontalPadding: 10,
                      verticalPadding: 10,
                      color: primaryYellow,
                      disabled: true,
                      onPressed: () {},
                      child: Image.asset(
                        'assets/button_icons/obstacle_detection.png',
                        color: neutralWhite,
                        height: 20,
                        width: 20,
                      ),
                    ),
                    title: RichText(
                      text: const TextSpan(
                        text: 'Activar ',
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: neutralWhite,
                            fontFamily: 'Poppins'),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'detección de obstáculos',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: neutralWhite,
                                fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    leading: PrimaryIconButton(
                      borderRadius: 6,
                      borderWidth: 3,
                      horizontalPadding: 10,
                      verticalPadding: 10,
                      color: secondaryPurple,
                      disabled: true,
                      onPressed: () {},
                      child: Image.asset(
                        'assets/button_icons/pencil.png',
                        color: neutralWhite,
                        height: 20,
                        width: 20,
                      ),
                    ),
                    title: RichText(
                      text: const TextSpan(
                        text: 'Activar lápiz ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: neutralWhite,
                            fontFamily: 'Poppins'),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'que dibuje sobre la superficie',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: neutralWhite,
                                fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    leading: PrimaryIconButton(
                      borderRadius: 6,
                      borderWidth: 3,
                      horizontalPadding: 10,
                      verticalPadding: 10,
                      color: secondaryPink,
                      disabled: true,
                      onPressed: () {},
                      child: Image.asset(
                        'assets/button_icons/cloud.png',
                        color: neutralWhite,
                        height: 20,
                        width: 20,
                      ),
                    ),
                    title: RichText(
                      text: const TextSpan(
                        text: 'Enviar instrucciones ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: neutralWhite,
                            fontFamily: 'Poppins'),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'al AttaBot conectado a la aplicación',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: neutralWhite,
                                fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    leading: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                        backgroundColor: neutralDarkBlueAD,
                        alignment: Alignment.center,
                        shape: const CircleBorder(
                          side: BorderSide(color: neutralWhite, width: 3.0),
                        ),
                        iconColor: neutralWhite,
                      ),
                      onPressed: () {},
                      child: Image.asset(
                        'assets/button_icons/play.png',
                        color: neutralWhite,
                        width: 18,
                        height: 18,
                        alignment: const Alignment(0, 3),
                      ),
                    ),
                    title: RichText(
                      text: const TextSpan(
                        text: 'Iniciar o detener ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: neutralWhite,
                            fontFamily: 'Poppins'),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'el set de instrucciones',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: neutralWhite,
                                fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildSimulatorScaleInfo() {
    final gridCell = SimulatorScale.gridCellCentimeters.toStringAsFixed(0);
    final robotWidth =
        SimulatorScale.robotFootprintWidthCentimeters.toStringAsFixed(1);
    final robotLength =
        SimulatorScale.robotFootprintLengthCentimeters.toStringAsFixed(1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryBlue.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: neutralWhite.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Escala del simulador',
            style: TextStyle(
              color: neutralWhite,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '1 cuadrado = $gridCell cm. El robot ocupa 1 cuadrado '
            '($robotWidth × $robotLength cm). Por ejemplo, avanzar '
            '$gridCell cm equivale a avanzar un cuadrado.',
            style: const TextStyle(
              color: neutralWhite,
              fontWeight: FontWeight.normal,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
