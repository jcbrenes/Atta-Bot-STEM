import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/dropdown_button.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart'; // for default cycles

class DefaultMovementDialog extends StatefulWidget {
  final int initialDistance;
  final int initialAngle;
  final int initialCycle;
  final void Function(int newDistance, int newAngle, int newCycle) onSetDefaults;

  const DefaultMovementDialog({
    super.key,
    required this.initialDistance,
    required this.initialAngle,
    required this.initialCycle,
    required this.onSetDefaults,
  });

  @override
  State<DefaultMovementDialog> createState() => _DefaultMovementDialogState();
}

class _DefaultMovementDialogState extends State<DefaultMovementDialog> {
  late int? selectedDistance;
  late int? selectedAngle;
  late int? selectedCycle;

  List<int> distanceOptions = List.generate(20, (i) => (i + 1) * 5); 
  List<int> angleOptions = [45, 90, 180, 270, 360];
  List<int> cycleOptions = List.generate(10, (i) => i + 1);

  @override
  void initState() {
    super.initState();
    selectedDistance = widget.initialDistance;
    selectedAngle = widget.initialAngle;
    selectedCycle = widget.initialCycle;
  }

  Widget _tinyIconButton({
    required Color color,
    required IconType icon,
    VoidCallback? onPressed,
  }) {
    final btn = DefaultButtonFactory.getButton(
      color: color,
      buttonType: ButtonType.primaryIcon,
      icon: icon,
      onPressed: onPressed ?? () {},
    );

    final size = MediaQuery.of(context).size;
    final bool isTablet = size.shortestSide >= 600;
    final base = isTablet ? 34.0 : 23.0;
    return SizedBox(
      width: base,
      height: base,
      child: FittedBox(child: btn),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.shortestSide >= 600;
    final bool isLandscape = size.width > size.height;

    if (!isTablet && isLandscape) {
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
              const Text(
                "Definir parámetros",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  fontFamily: "Poppins",
                  color: neutralWhite,
                ),
              ),
              const SizedBox(height: 35),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _tinyIconButton(
                        color: primaryBlue,
                        icon: IconType.forwardArrow,
                      ),
                      const SizedBox(width: 6),
                      _tinyIconButton(
                        color: primaryBlue,
                        icon: IconType.backwardArrow,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Avanzar/Retroceder",
                                style: TextStyle(
                                  color: neutralWhite,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              CustomDropdown(
                                selectedValue: selectedDistance,
                                options: distanceOptions,
                                onChanged: (value) {
                                  setState(() {
                                    selectedDistance = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "centímetros",
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
                      _tinyIconButton(
                        color: secondaryIconOrange,
                        icon: IconType.rotateRight,
                      ),
                      const SizedBox(width: 6),
                      _tinyIconButton(
                        color: secondaryIconOrange,
                        icon: IconType.rotateLeft,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Girar",
                                style: TextStyle(
                                  color: neutralWhite,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              CustomDropdown(
                                selectedValue: selectedAngle,
                                options: angleOptions,
                                onChanged: (value) {
                                  setState(() {
                                    selectedAngle = value!;
                                  });
                                },
                                suffix: '°',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "a la izquierda/derecha",
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
                      _tinyIconButton(
                        color: secondaryGreen,
                        icon: IconType.cycle,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Iniciar un ciclo, y repetirlo",
                                style: TextStyle(
                                  color: neutralWhite,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              CustomDropdown(
                                selectedValue: selectedCycle,
                                options: cycleOptions,
                                onChanged: (value) {
                                  setState(() {
                                    selectedCycle = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "veces",
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
                    onTap: () {
                      if (selectedDistance == null || selectedAngle == null || selectedCycle == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: neutralDarkBlueAD,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Por favor selecciona todos los parámetros',
                                    style: TextStyle(
                                      color: neutralDarkBlueAD,
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: neutralGray,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: neutralWhite, width: 2),
                            ),
                            elevation: 6,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        );
                        return;
                      }
                      final cmdService = context.read<CommandService>();
                      widget.onSetDefaults(selectedDistance!, selectedAngle!, selectedCycle!);
                      if (!cmdService.cycleActive && selectedCycle! > 1) {
                        cmdService.initCycle(selectedCycle!);
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Aplicar cambios",
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
                    onTap: () {
                      setState(() {
                        selectedDistance = null;
                        selectedAngle = null;
                        selectedCycle = null;
                      });
                    },
                    child: const Text(
                      "Limpiar cambios",
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
    }

    final dialogWidth = (size.width * (isTablet ? 0.65 : 0.55)).clamp(360.0, 860.0);
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
      contentPadding: EdgeInsets.all(16 * paddingScale),
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
              Text(
                "Definir parámetros",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: titleFontSize,
                  fontFamily: "Poppins",
                  color: neutralWhite,
                ),
              ),
              SizedBox(height: headerGap),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _tinyIconButton(
                        color: primaryBlue,
                        icon: IconType.forwardArrow,
                      ),
                      const SizedBox(width: 6),
                      _tinyIconButton(
                        color: primaryBlue,
                        icon: IconType.backwardArrow,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Avanzar/Retroceder",
                                style: bodyStyle,
                              ),
                              const SizedBox(width: 8),
                              CustomDropdown(
                                selectedValue: selectedDistance,
                                options: distanceOptions,
                                onChanged: (value) {
                                  setState(() {
                                    selectedDistance = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "centímetros",
                            style: bodyStyle,
                          ),
                        ],
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
                    children: [
                      _tinyIconButton(
                        color: secondaryIconOrange,
                        icon: IconType.rotateRight,
                      ),
                      const SizedBox(width: 6),
                      _tinyIconButton(
                        color: secondaryIconOrange,
                        icon: IconType.rotateLeft,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Girar",
                                style: bodyStyle,
                              ),
                              const SizedBox(width: 8),
                              CustomDropdown(
                                selectedValue: selectedAngle,
                                options: angleOptions,
                                onChanged: (value) {
                                  setState(() {
                                    selectedAngle = value!;
                                  });
                                },
                                suffix: '°',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "a la izquierda/derecha",
                            style: bodyStyle,
                          ),
                        ],
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
                    children: [
                      _tinyIconButton(
                        color: secondaryGreen,
                        icon: IconType.cycle,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Iniciar un ciclo, y repetirlo",
                                style: bodyStyle,
                              ),
                              const SizedBox(width: 8),
                              CustomDropdown(
                                selectedValue: selectedCycle,
                                options: cycleOptions,
                                onChanged: (value) {
                                  setState(() {
                                    selectedCycle = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "veces",
                            style: bodyStyle,
                          ),
                        ],
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
                    onTap: () {
                      if (selectedDistance == null || selectedAngle == null || selectedCycle == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: neutralDarkBlueAD,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Por favor selecciona todos los parámetros',
                                    style: TextStyle(
                                      color: neutralDarkBlueAD,
                                      fontFamily: 'Poppins',
                                      fontSize: 13 * scale.clamp(1.0, 1.3),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: neutralGray,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(16 * paddingScale),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: neutralWhite, width: 2),
                            ),
                            elevation: 6,
                            padding: EdgeInsets.symmetric(horizontal: 16 * paddingScale, vertical: 14 * paddingScale),
                          ),
                        );
                        return;
                      }

                      final cmdService = context.read<CommandService>();
                      widget.onSetDefaults(selectedDistance!, selectedAngle!, selectedCycle!);
                      if (!cmdService.cycleActive && selectedCycle! > 1) {
                        cmdService.initCycle(selectedCycle!);
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Aplicar cambios",
                      style: bodyStyle.copyWith(
                        decoration: TextDecoration.underline,
                        decorationThickness: 2,
                        decorationColor: neutralWhite,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDistance = null;
                        selectedAngle = null;
                        selectedCycle = null;
                      });
                    },
                    child: Text(
                      "Limpiar cambios",
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
  }
}
