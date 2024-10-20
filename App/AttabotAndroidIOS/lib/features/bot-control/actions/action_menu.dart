import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/bot-control/actions/cycle_input.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
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
  bool obstacleDetection = false;
  bool initCycle = false;
  int cycleCount = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DefaultButtonFactory.getButton(
          color: secondaryGreen,
          buttonType: ButtonType.primaryIcon,
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
        SizedBox(width: 16),
        DefaultButtonFactory.getButton(
          color: primaryYellow,
          buttonType: ButtonType.primaryIcon,
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
        SizedBox(width: 16),
        TextButton(
          style: TextButton.styleFrom(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            shape: CircleBorder(
              side: BorderSide(color: neutralWhite, width: 4.0),
            ),
            iconColor: neutralWhite,
          ),
          onPressed: () {},
          child: Image.asset(
            'assets/button_icons/play.png',
            color: neutralWhite,
            width: 27,
            height: 26,
            alignment: Alignment(1,0),
          ),
        ),
        SizedBox(width: 16),
        DefaultButtonFactory.getButton(
          color: secondaryPink,
          buttonType: ButtonType.primaryIcon,
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
          icon: IconType.pencil,
        ),
        SizedBox(width: 16),
        DefaultButtonFactory.getButton(
          color: secondaryPurple,
          buttonType: ButtonType.primaryIcon,
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
          icon: IconType.claw,
        ),
      ],
    );
  }
}
