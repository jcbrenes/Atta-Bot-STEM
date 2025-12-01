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
        final size = MediaQuery.of(context).size;
        final bool isTablet = size.shortestSide >= 600;
        final bool isLandscape = size.width > size.height;

        if (!isTablet && isLandscape) {
          Widget tinyIconButton({required Color color, required IconType icon}) {
            final btn = DefaultButtonFactory.getButton(
              color: color,
              buttonType: ButtonType.primaryIcon,
              icon: icon,
              onPressed: () {},
            );
            return SizedBox(width: 23, height: 23, child: FittedBox(child: btn));
          }

          const titleStyle = TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            fontFamily: 'Poppins',
            color: neutralWhite,
          );
          const bodyStyle = TextStyle(
            color: neutralWhite,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            fontSize: 12,
          );

          return AlertDialog(
            backgroundColor: neutralDarkBlueAD,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: const BorderSide(color: Colors.white, width: 4.0),
            ),
            contentPadding: const EdgeInsets.all(16),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(child: Text('Definir parámetros', style: titleStyle)),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: neutralWhite, size: 24),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                  const Text('Avanzar/Retroceder', style: bodyStyle),
                                  const SizedBox(width: 8),
                                  CustomDropdown(
                                    selectedValue: null,
                                    options: const [],
                                    onChanged: (_) {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text('centímetros', style: bodyStyle),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                  const Text('Girar', style: bodyStyle),
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
                              const Text('a la izquierda/derecha', style: bodyStyle),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          tinyIconButton(color: secondaryGreen, icon: IconType.cycle),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('Iniciar un ciclo, y repetirlo', style: bodyStyle),
                                  const SizedBox(width: 8),
                                  CustomDropdown(
                                    selectedValue: null,
                                    options: const [1, 2],
                                    onChanged: (_) {},
                                    autoOpen: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text('veces', style: bodyStyle),
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
                          style: bodyStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        final dialogWidth = (size.width * (isTablet ? 0.65 : 0.75)).clamp(isTablet ? 360.0 : 300.0, 860.0);
        final scale = (dialogWidth / 360.0).clamp(1.0, 1.75);
        final paddingScale = scale.clamp(1.0, 1.3);
        final titleFontSize = 16.0 * scale.clamp(1.0, 1.6);
        final bodyFontSize = 12.0 * scale.clamp(1.0, 1.5);
        final headerGap = 35.0 * scale.clamp(1.0, 1.25);
        final sectionGap = 30.0 * scale.clamp(1.0, 1.2);

        TextStyle bodyStyle = TextStyle(
          color: neutralWhite,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          fontSize: bodyFontSize,
        );

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
            final base = isTablet ? 34.0 : 23.0;
            return SizedBox(width: base, height: base, child: FittedBox(child: btn));
        }

        return AlertDialog(
          backgroundColor: neutralDarkBlueAD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: Colors.white, width: 4.0),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? size.width * 0.07 : 40,
            vertical: isTablet ? size.height * 0.06 : 24,
          ),
          titlePadding: EdgeInsets.fromLTRB(30 * paddingScale, 10 * paddingScale, 10 * paddingScale, 0),
          contentPadding: EdgeInsets.fromLTRB(30 * paddingScale, 10 * paddingScale, 30 * paddingScale, 20 * paddingScale),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Definir parámetros',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: titleFontSize,
                    fontFamily: 'Poppins',
                    color: neutralWhite,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.close,
                  color: neutralWhite,
                  size: isTablet ? 30 : 24,
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              minWidth: dialogWidth * 0.85,
              minHeight: isTablet ? size.height * 0.25 : 0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tinyIconButton(color: primaryBlue, icon: IconType.forwardArrow),
                      const SizedBox(width: 6),
                      tinyIconButton(color: primaryBlue, icon: IconType.backwardArrow),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(child: Text('Avanzar/Retroceder', style: bodyStyle, overflow: TextOverflow.ellipsis)),
                                const SizedBox(width: 8),
                                CustomDropdown(
                                  selectedValue: null,
                                  options: const [],
                                  onChanged: (_) {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('centímetros', style: bodyStyle),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: sectionGap),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tinyIconButton(color: secondaryIconOrange, icon: IconType.rotateRight),
                      const SizedBox(width: 6),
                      tinyIconButton(color: secondaryIconOrange, icon: IconType.rotateLeft),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(child: Text('Girar', style: bodyStyle, overflow: TextOverflow.ellipsis)),
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
                            Text('a la izquierda/derecha', style: bodyStyle),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: sectionGap),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tinyIconButton(color: secondaryGreen, icon: IconType.cycle),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(child: Text('Iniciar un ciclo, y repetirlo', style: bodyStyle, overflow: TextOverflow.ellipsis)),
                                const SizedBox(width: 8),
                                CustomDropdown(
                                  selectedValue: null,
                                  options: const [1, 2],
                                  onChanged: (_) {},
                                  autoOpen: true, 
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('veces', style: bodyStyle),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: headerGap),

              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Aplicar cambios',
                      style: bodyStyle.copyWith(
                        decoration: TextDecoration.underline,
                        decorationThickness: 2,
                        decorationColor: neutralWhite,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Limpiar cambios',
                      style: bodyStyle,
                    ),
                  ),
                ],
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
