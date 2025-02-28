import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/primary_icon_button.dart';

class HelpDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '¿Cómo funciono?',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: neutralWhite,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Poppins'),
          ),
          backgroundColor: neutralDarkBlueAD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: Colors.white, width: 4.0),
          ),
          content: Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Spacer(),
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
                Spacer(),
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
                    color: secondaryIconBlue,
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
                Spacer(),
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      backgroundColor: secondaryPurple,
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
                      text: 'Enviar instrucciones ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: neutralWhite,
                          fontFamily: 'Poppins'),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'al AttaBot',
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cerrar',
                style: TextStyle(
                    color: neutralWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Poppins'),
              ),
            ),
          ],
        );
      },
    );
  }
}
