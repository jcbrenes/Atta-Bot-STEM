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
  late int selectedDistance;
  late int selectedAngle;
  late int selectedCycle;

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

  @override
  Widget build(BuildContext context) {
        return AlertDialog(
        backgroundColor: neutralDarkBlueAD,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: Colors.white, width: 4.0),
        ),
        contentPadding: const EdgeInsets.all(16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Definir parámetros",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                fontFamily: "Poppins",
                color: neutralWhite,
              ),
            ),
            const SizedBox(height: 20),

            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DefaultButtonFactory.getButton(
                      color: primaryBlue,
                      buttonType: ButtonType.primaryIcon,
                      icon: IconType.forwardArrow,
                      onPressed: () {},
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

            const SizedBox(height: 16),

            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DefaultButtonFactory.getButton(
                      color: secondaryIconOrange,
                      buttonType: ButtonType.primaryIcon,
                      icon: IconType.rotateRight,
                      onPressed: () {},
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

            const SizedBox(height: 16),

            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DefaultButtonFactory.getButton(
                      color: secondaryGreen,
                      buttonType: ButtonType.primaryIcon,
                      icon: IconType.cycle,
                      onPressed: () {},
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

            const SizedBox(height: 24),

            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    widget.onSetDefaults(selectedDistance, selectedAngle, selectedCycle);
                    final cmdService = context.read<CommandService>();
                    if (!cmdService.cycleActive && selectedCycle > 1) {
                      cmdService.initCycle(selectedCycle);
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Aplicar cambios",
                    style: TextStyle(
                      color: neutralWhite,
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                      decorationColor: neutralWhite,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDistance = widget.initialDistance;
                      selectedAngle = widget.initialAngle;
                      selectedCycle = widget.initialCycle;
                    });
                  },
                  child: const Text(
                    "Limpiar cambios",
                    style: TextStyle(
                      color: neutralWhite,
                      fontFamily: 'Poppins',
                      fontSize: 12,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
