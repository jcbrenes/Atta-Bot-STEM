import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';
import 'package:proyecto_tec/features/bot-control/actions/cycle_dialog.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/info_dialog.dart';
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
  bool pencilActive = false;
  bool clawActive = false;
  bool initCycle = false;

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
              CycleDialog.show(context);
            } else {
              context.read<CommandService>().endCycle();
              showInfoDialog(context, 'Se ha cerrado el ciclo');
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
              showInfoDialog(context, 'Se ha activado \nla detección \nde obstáculos');
              context.read<CommandService>().activateObjectDetection();
            } else {
              showInfoDialog(context, 'Se ha desactivado \nla detección \nde obstáculos');
              context.read<CommandService>().deactivateObjectDetection();
            }
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
            pencilActive = !pencilActive;
            if (pencilActive) {
              showInfoDialog(context, 'Se ha activado \n el lápiz');
            } else {
              showInfoDialog(context, 'Se ha desactivado \n el lápiz');
            }
          },
          icon: IconType.pencil,
        ),
        SizedBox(width: 16),
        DefaultButtonFactory.getButton(
          color: secondaryPurple,
          buttonType: ButtonType.primaryIcon,
          onPressed: () {
            clawActive = !clawActive;
            if (clawActive) {
              showInfoDialog(context, 'Se ha activado \n la garra');
            } else {
              showInfoDialog(context, 'Se ha desactivado \n la garra');
            }
          },
          icon: IconType.claw,
        ),
      ],
    );
  }
}
