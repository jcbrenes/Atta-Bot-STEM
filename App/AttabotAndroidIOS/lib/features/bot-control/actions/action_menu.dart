import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/bot-control/actions/cycle_input.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/styles/gradient_factory.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';
// import provider and service commands
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/commands/services/command_service.dart';

class ActionMenu extends StatefulWidget {
  const ActionMenu({super.key});

  @override
  State<ActionMenu> createState() => _ActionMenuState();
}

class _ActionMenuState extends State<ActionMenu> {
  String? selectedValue = "Atta-bot 1"; // Initial selected value
  bool obstacleDetection = false;
  bool initCycle = false;
  int cycleCount = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DefaultButtonFactory.getButton(
          borderWidth: 2,
          verticalPadding: 10,
          horizontalPadding: 10,
          borderRadius: 12,
          decoration: GradientFactory.getGradient(
              startColor: primaryYellow,
              endColor: primaryDarkYellow,
              direction: GradientDirection.topToBottom),
          buttonType: ButtonType.primary,
          iconSize: 25,
          onPressed: () {
            obstacleDetection = !obstacleDetection;
            if (obstacleDetection) {
              context.read<CommandService>().activateObjectDetection();
            } else {
              context.read<CommandService>().deactivateObjectDetection();
            }
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    obstacleDetection
                        ? 'Detección de obstáculos activada'
                        : 'Detección de obstáculos desactivada',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: neutralWhite,
                        fontFamily: 'Poppins'),
                  ),
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(color: neutralWhite, width: 5.0),
                  ),
                );
              },
            );
          },
          icon: IconType.obstacleDetection,
        ),
        const SizedBox(width: 10),
        DefaultButtonFactory.getButton(
          borderWidth: 2,
          verticalPadding: 10,
          horizontalPadding: 10,
          borderRadius: 12,
          decoration: GradientFactory.getGradient(
              startColor: primaryYellow,
              endColor: primaryDarkYellow,
              direction: GradientDirection.topToBottom),
          buttonType: ButtonType.primary,
          iconSize: 25,
          onPressed: () {
            initCycle = !initCycle;
            if (initCycle) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      'Repetir el ciclo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: neutralWhite),
                    ),
                    backgroundColor: primaryBlue,
                    content: CycleInput(
                      onCycleSelected: (value) {
                        setState(() {
                          cycleCount = value;
                        });
                      },
                    ),
                    actions: [
                      TextButton(
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(
                              fontFamily: 'Poppins', color: neutralWhite),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text("Aceptar",
                            style: TextStyle(
                                fontFamily: 'Poppins', color: neutralWhite)),
                        onPressed: () {
                          context.read<CommandService>().initCycle(cycleCount);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      "Fin del ciclo",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: neutralWhite),
                    ),
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: const BorderSide(color: neutralWhite, width: 5.0),
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Cancelar",
                            style: TextStyle(
                                fontFamily: 'Poppins', color: neutralWhite)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text("Aceptar",
                            style: TextStyle(
                                fontFamily: 'Poppins', color: neutralWhite)),
                        onPressed: () {
                          context.read<CommandService>().endCycle();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
          icon: IconType.cycle,
        ),
        const SizedBox(width: 25),
        DropdownButton<String>(
          dropdownColor: neutralDarkBlue,
          iconEnabledColor: neutralWhite,
          value: selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              selectedValue = newValue;
            });
          },
          style: const TextStyle(color: neutralWhite),
          underline: Container(
            color: neutralWhite,
            height: 1,
          ),
          items: <String>['Atta-bot 1', 'Atta-bot 2', 'Atta-bot 3']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(color: neutralWhite,fontSize: 20,fontFamily: 'Poppins',fontWeight: FontWeight.w500,)),  
            );
          }).toList(),
        ),
        IconButton(
          color: neutralWhite,
          onPressed: () {},
          icon: const Icon(Icons.play_arrow),
        ),
      ],
    );
  }
}
