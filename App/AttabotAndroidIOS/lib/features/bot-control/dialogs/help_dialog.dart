import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/primary_icon_button.dart';

class HelpDialog {
  // Método principal para mostrar el diálogo de ayuda
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(30, 10, 10, 0),
          contentPadding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
          title: _buildTitle(context),
          backgroundColor: neutralDarkBlueAD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: Colors.white, width: 4.0),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de movimientos lineales
                _buildInstructionTile(
                  color: primaryBlue,
                  imagePath: 'assets/button_icons/forward_arrow.png',
                  boldText: 'Avanzar ',
                  normalText: 'una cantidad de centímetros',
                ),
                _buildInstructionTile(
                  color: primaryBlue,
                  imagePath: 'assets/button_icons/backward_arrow.png',
                  boldText: 'Retroceder ',
                  normalText: 'una cantidad de centímetros',
                ),
                const SizedBox(height: 10),

                // Sección de giros
                _buildInstructionTile(
                  color: secondaryIconOrange,
                  imagePath: 'assets/button_icons/rotate_right.png',
                  boldText: 'Girar a la derecha ',
                  normalText: 'una cantidad de grados',
                ),
                _buildInstructionTile(
                  color: secondaryIconOrange,
                  imagePath: 'assets/button_icons/rotate_left.png',
                  boldText: 'Girar a la izquierda ',
                  normalText: 'una cantidad de grados',
                ),
                const SizedBox(height: 10),

                // Sección de funcionalidades especiales
                _buildInstructionTile(
                  color: secondaryGreen,
                  imagePath: 'assets/button_icons/cycle.png',
                  boldText: 'Iniciar un ciclo, ',
                  normalText: 'una cantidad de veces',
                ),
                _buildInstructionTile(
                  color: primaryYellow,
                  imagePath: 'assets/button_icons/obstacle_detection.png',
                  normalText: 'Activar ',
                  boldText: 'detección de obstáculos',
                ),
                _buildInstructionTile(
                  color: secondaryPurple,
                  imagePath: 'assets/button_icons/pencil.png',
                  boldText: 'Activar lápiz ',
                  normalText: 'que dibuje sobre la superficie',
                ),
                const SizedBox(height: 10),

                // Botón para enviar instrucciones
                _buildPlayButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  // Construye el título del diálogo con el botón de cierre
  static Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            '¿Cómo funciono?',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: neutralWhite,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: neutralWhite),
        )
      ],
    );
  }

  // Crea un tile de instrucción reutilizable
  static Widget _buildInstructionTile({
    required Color color,
    required String imagePath,
    required String boldText,
    required String normalText,
    bool boldFirst = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      leading: PrimaryIconButton(
        borderRadius: 6,
        borderWidth: 3,
        horizontalPadding: 10,
        verticalPadding: 10,
        color: color,
        disabled: true,
        onPressed: () {},
        child: Image.asset(
          imagePath,
          color: neutralWhite,
          height: 20,
          width: 20,
        ),
      ),
      title: RichText(
        text: TextSpan(
          text: boldFirst ? boldText : normalText,
          style: TextStyle(
              fontWeight: boldFirst ? FontWeight.bold : FontWeight.normal,
              color: neutralWhite,
              fontFamily: 'Poppins'),
          children: <TextSpan>[
            TextSpan(
              text: boldFirst ? normalText : boldText,
              style: TextStyle(
                  fontWeight: boldFirst ? FontWeight.normal : FontWeight.bold,
                  color: neutralWhite,
                  fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }

  // Construye el botón de reproducción para enviar instrucciones
  static Widget _buildPlayButton() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
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
    );
  }
}
