import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/primary_icon_button.dart';

class HelpDialogForSimplifiedMode {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.fromLTRB(30, 10, 10, 0),
          contentPadding: EdgeInsets.fromLTRB(30, 10, 30, 20),
          title: Row(
            children: [
              Expanded(
                child: const Text(
                  'Definir parámetros',
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
                          text: 'x centimetros',
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
                          text: 'x centímetros',
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
                      text: 'Girar ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: neutralWhite,
                          fontFamily: 'Poppins'),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'x a la derecha',
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
                      text: 'Girar ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: neutralWhite,
                          fontFamily: 'Poppins'),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'x a la izquierda',
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
                      text: 'Iniciar un ciclo, y repetirlo ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: neutralWhite,
                          fontFamily: 'Poppins'),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'x cantidad de veces',
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
}
