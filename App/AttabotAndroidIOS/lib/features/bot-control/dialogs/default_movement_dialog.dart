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
  final void Function(int newDistance, int newAngle, int newCycle)
      onSetDefaults;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const DefaultMovementDialog({
    super.key,
    required this.initialDistance,
    required this.initialAngle,
    required this.initialCycle,
    required this.onSetDefaults,
    this.showCloseButton = false,
    this.onClose,
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
  List<int> cycleOptions = List.generate(5, (i) => i + 1);

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

  Widget _landscapeActionLink(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    required TextStyle style,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Text(label, style: style),
    );
  }

  Widget _landscapeMovementRow({
    required Color iconColor,
    required IconType firstIcon,
    required IconType secondIcon,
    required String title,
    required String subtitle,
    required Widget dropdown,
    required TextStyle labelStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tinyIconButton(
          color: iconColor,
          icon: firstIcon,
        ),
        const SizedBox(width: 6),
        _tinyIconButton(
          color: iconColor,
          icon: secondIcon,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Text(title, style: labelStyle),
                  dropdown,
                ],
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: labelStyle),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.shortestSide >= 600;
    final bool isLandscape = size.width > size.height;

    // Common styles for both orientations
    const modeLabelStyle = TextStyle(
      color: neutralWhite,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
      fontSize: 16,
    );
    const modeTitleStyle = TextStyle(
      color: neutralWhite,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w700,
      fontSize: 20,
    );
    const landscapeTitleStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 16,
      fontFamily: 'Poppins',
      color: neutralWhite,
    );
    const labelStyle = TextStyle(
      color: neutralWhite,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins',
      fontSize: 12,
    );


    if (isTablet && isLandscape) {

      return AlertDialog(
        backgroundColor: neutralDarkBlueAD,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: Colors.white, width: 4.0),
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.06,
        ),
        contentPadding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        content: SizedBox(
          width: (size.width * 0.50).clamp(560.0, 680.0).toDouble(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (widget.onClose != null) {
                          widget.onClose!();
                          return;
                        }
                        Navigator.of(context).pop(false);
                      },
                      child: Image.asset(
                          'assets/button_icons/left_arrow.png',
                          width: 28,
                          height: 28,
                          color: neutralWhite,
                        ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'PARÁMETROS DE MEDIDA',
                          style: TextStyle(
                            color: neutralWhite,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            const Text(
                              'Modo de uso seleccionado:',
                              style: modeLabelStyle,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Simplificado',
                              style: modeTitleStyle.copyWith(
                                decorationThickness: 2,
                                decorationColor: neutralWhite,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const SizedBox(
                              width: 300,
                              child: Text(
                                'Utiliza valores predeterminados y fijos para todos los movimientos. El entorno de ejecución se limita a los parámetros establecidos al inicio de la sesión.',
                                style: modeLabelStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Definir parámetros',
                              style: landscapeTitleStyle,
                            ),
                            const SizedBox(height: 28),
                            _landscapeMovementRow(
                              iconColor: primaryBlue,
                              firstIcon: IconType.forwardArrow,
                              secondIcon: IconType.backwardArrow,
                              title: 'Avanzar/Retroceder',
                              subtitle: 'centímetros',
                              labelStyle: labelStyle,
                              dropdown: CustomDropdown(
                                selectedValue: selectedDistance,
                                options: distanceOptions,
                                onChanged: (value) {
                                  setState(() {
                                    selectedDistance = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            _landscapeMovementRow(
                              iconColor: secondaryIconOrange,
                              firstIcon: IconType.rotateLeft,
                              secondIcon: IconType.rotateRight,
                              title: 'Girar',
                              subtitle: 'a la izquierda/derecha',
                              labelStyle: labelStyle,
                              dropdown: CustomDropdown(
                                selectedValue: selectedAngle,
                                options: angleOptions,
                                onChanged: (value) {
                                  setState(() {
                                    selectedAngle = value!;
                                  });
                                },
                                suffix: '°',
                              ),
                            ),
                            const SizedBox(height: 24),
                            _landscapeMovementRow(
                              iconColor: secondaryGreen,
                              firstIcon: IconType.cycle,
                              secondIcon: IconType.cycle,
                              title: 'Iniciar un ciclo, y repetirlo',
                              subtitle: 'veces',
                              labelStyle: labelStyle,
                              dropdown: CustomDropdown(
                                selectedValue: selectedCycle,
                                options: cycleOptions,
                                onChanged: (value) {
                                  setState(() {
                                    selectedCycle = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _landscapeActionLink(
                        context,
                        label: 'Aplicar parámetros',
                        style: labelStyle,
                        onTap: () {
                          if (selectedDistance == null ||
                              selectedAngle == null ||
                              selectedCycle == null) {
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
                                  side: const BorderSide(
                                      color: neutralWhite, width: 2),
                                ),
                                elevation: 6,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                            );
                            return;
                          }
                          final cmdService = context.read<CommandService>();
                          widget.onSetDefaults(
                              selectedDistance!, selectedAngle!, selectedCycle!);
                          if (!cmdService.cycleActive && selectedCycle! > 1) {
                            cmdService.initCycleSimplified(selectedCycle!);
                          }
                          Navigator.of(context).pop(true);
                        },
                      ),
                      const SizedBox(width: 36),
                      _landscapeActionLink(
                        context,
                        label: 'Limpiar parámetros',
                        style: labelStyle,
                        onTap: () {
                          setState(() {
                            selectedDistance = null;
                            selectedAngle = null;
                            selectedCycle = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final dialogWidth =
        (size.width * (isTablet ? 0.65 : 0.55)).clamp(360.0, 860.0);
    final scale = (dialogWidth / 360.0).clamp(1.0, 1.75);
    final paddingScale = scale.clamp(1.0, 1.3);
    final titleFontSize = 16.0 * scale.clamp(1.0, 1.6);
    final headerGap = 35.0 * scale.clamp(1.0, 1.25);
    final sectionGap = 30.0 * scale.clamp(1.0, 1.2);

    final bodyStyle = labelStyle.copyWith(
      fontSize: 12.0 * scale.clamp(1.0, 1.5),
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
              Stack(
                children: [
                  Center(
                    child: Text(
                      "Definir parámetros",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: titleFontSize,
                        fontFamily: "Poppins",
                        color: neutralWhite,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    child: GestureDetector(
                      onTap: () {
                        if (widget.onClose != null) {
                          widget.onClose!();
                          return;
                        }
                        Navigator.of(context).pop(false);
                      },
                      child: Image.asset(
                        'assets/button_icons/left_arrow.png',
                        width: 28,
                        height: 28,
                        color: neutralWhite,
                      ),
                    ),
                  ),
                ],
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
                      if (selectedDistance == null ||
                          selectedAngle == null ||
                          selectedCycle == null) {
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
                              side: const BorderSide(
                                  color: neutralWhite, width: 2),
                            ),
                            elevation: 6,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16 * paddingScale,
                                vertical: 14 * paddingScale),
                          ),
                        );
                        return;
                      }

                      final cmdService = context.read<CommandService>();
                      widget.onSetDefaults(
                          selectedDistance!, selectedAngle!, selectedCycle!);
                      if (!cmdService.cycleActive && selectedCycle! > 1) {
                        cmdService.initCycleSimplified(selectedCycle!);
                      }
                      Navigator.of(context).pop(true);
                    },
                    child: Text(
                      "Aplicar parámetros",
                      style: bodyStyle,
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
