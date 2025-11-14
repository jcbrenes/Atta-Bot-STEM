import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/dropdown_button.dart';

class HelpDialogForSimplifiedMode {
  static void show(BuildContext context, {bool? useRootNavigator}) {
    showDialog(
      context: context,
      useRootNavigator: useRootNavigator ?? true,
      builder: (BuildContext context) {

        Widget tinyIconButton({
          required Color color,
          required IconType icon,
        }) {
          final btn = DefaultButtonFactory.getButton(
            color: color,
            buttonType: ButtonType.primaryIcon,
            icon: icon,
            onPressed: () {},
          );
          return SizedBox(width: 23, height: 23, child: FittedBox(child: btn));
        }

        return AlertDialog(
          backgroundColor: neutralDarkBlueAD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: Colors.white, width: 4.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(30, 10, 10, 0),
          contentPadding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
          title: Row(
            children: [
              const Expanded(
                child: Text(
                  'Definir parámetros',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: neutralWhite,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.close,
                  color: neutralWhite,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      tinyIconButton(color: primaryBlue, icon: IconType.forwardArrow),
                      const SizedBox(width: 6),
                      tinyIconButton(color: primaryBlue, icon: IconType.backwardArrow),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Avanzar/Retroceder',
                                style: TextStyle(
                                  color: neutralWhite,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              CustomDropdown(
                                selectedValue: null,
                                options: const [],
                                onChanged: (_) {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'centímetros',
                            style: TextStyle(
                              color: neutralWhite,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      tinyIconButton(color: secondaryIconOrange, icon: IconType.rotateRight),
                      const SizedBox(width: 6),
                      tinyIconButton(color: secondaryIconOrange, icon: IconType.rotateLeft),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Girar',
                                style: TextStyle(
                                  color: neutralWhite,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              CustomDropdown(
                                selectedValue: null,
                                options: const [],
                                onChanged: (_) {},
                                suffix: '°',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'a la izquierda/derecha',
                            style: TextStyle(
                              color: neutralWhite,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      tinyIconButton(color: secondaryGreen, icon: IconType.cycle),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Iniciar un ciclo, y repetirlo',
                                style: TextStyle(
                                  color: neutralWhite,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Dropdown auto open with options up to 2
                              CustomDropdown(
                                selectedValue: null,
                                options: const [1, 2],
                                onChanged: (_) {},
                                autoOpen: true, 
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'veces',
                            style: TextStyle(
                              color: neutralWhite,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 35),

              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Aplicar cambios',
                      style: TextStyle(
                        color: neutralWhite,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        decorationThickness: 2,
                        decorationColor: neutralWhite,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Limpiar cambios',
                      style: TextStyle(
                        color: neutralWhite,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            ),
          ),
        );
      },
    );
  }
}
