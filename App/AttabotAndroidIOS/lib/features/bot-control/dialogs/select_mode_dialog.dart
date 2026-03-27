import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class SelectModeDialog {
  static Future<bool?> show(
    BuildContext context, {
    bool? useRootNavigator,
  }) {
    return showDialog<bool>(
      context: context,
      useRootNavigator: useRootNavigator ?? true,
      builder: (BuildContext context) {
        final size = MediaQuery.of(context).size;
        final bool isTablet = size.shortestSide >= 600;

        final dialogWidth =
            (size.width * (isTablet ? 0.65 : 0.82)).clamp(320.0, 860.0);
        final scale = (dialogWidth / 360.0).clamp(1.0, 1.6);
        final paddingScale = scale.clamp(1.0, 1.25);

        final titleStyle = TextStyle(
          color: neutralWhite,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          fontSize: 20 * scale.clamp(1.0, 1.3),
        );

        final bodyStyle = TextStyle(
          color: neutralWhite,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 16 * scale.clamp(1.0, 1.2),
        );

        const buttonTextStyle = TextStyle(
          color: neutralWhite,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          fontSize: 16,
        );

        return AlertDialog(
          backgroundColor: neutralDarkBlueAD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: Colors.white, width: 4.0),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? size.width * 0.07 : 28,
            vertical: isTablet ? size.height * 0.06 : 24,
          ),
          contentPadding: EdgeInsets.fromLTRB(
            30 * paddingScale,
            14 * paddingScale,
            30 * paddingScale,
            22 * paddingScale,
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              minWidth: dialogWidth * 0.85,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 4 * paddingScale),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(
                            context,
                            rootNavigator: useRootNavigator ?? true,
                          ).pop();
                        },
                        child: Image.asset(
                          'assets/button_icons/left_arrow.png',
                          width: 28,
                          height: 28,
                          color: neutralWhite,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12 * paddingScale),
                  Text(
                    'Attabot v.1.2 cuenta con dos modos de uso:',
                    style: bodyStyle,
                  ),
                  SizedBox(height: 16 * paddingScale),
                  Text('Manual', style: titleStyle),
                  SizedBox(height: 6 * paddingScale),
                  Text(
                    'Permite la definición personalizada de los parámetros de movimiento (giros, desplazamientos y ciclos) según los requerimientos específicos de la secuencia de instrucciones.',
                    style: bodyStyle,
                  ),
                  SizedBox(height: 16 * paddingScale),
                  Text('Simplificado', style: titleStyle),
                  SizedBox(height: 6 * paddingScale),
                  Text(
                    'Utiliza valores predeterminados y fijos para todos los movimientos. El entorno de ejecución se limita a los parámetros establecidos al inicio de la sesión.',
                    style: bodyStyle,
                  ),
                  SizedBox(height: 20 * paddingScale),
                  Text(
                    'Seleccione el modo de preferencia:',
                    style: bodyStyle,
                  ),
                  SizedBox(height: 16 * paddingScale),
                  SizedBox(
                    width: double.infinity,
                    child: DefaultButtonFactory.getButton(
                      text: 'Manual',
                      textStyle: buttonTextStyle,
                      color: Colors.transparent,
                      borderColor: mediumBlueGray,
                      fullWidthText: true,
                      buttonType: ButtonType.primaryIcon,
                      borderWidth: 4.0,
                      borderRadius: 30,
                      verticalPadding: 10,
                      horizontalPadding: 14,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  SizedBox(height: 12 * paddingScale),
                  SizedBox(
                    width: double.infinity,
                    child: DefaultButtonFactory.getButton(
                      text: 'Simplificado',
                      textStyle: buttonTextStyle,
                      color: mediumBlueGray,
                      borderColor: mediumBlueGray,
                      fullWidthText: true,
                      buttonType: ButtonType.primaryIcon,
                      borderWidth: 4.0,
                      borderRadius: 30,
                      verticalPadding: 10,
                      horizontalPadding: 14,
                      onPressed: () => Navigator.of(context).pop(true),
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
