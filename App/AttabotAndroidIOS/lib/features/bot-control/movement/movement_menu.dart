import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/bot-control/movement/rotation.dart';
import 'package:proyecto_tec/features/bot-control/movement/movement.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';

class MovementMenu extends StatelessWidget {
  const MovementMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Expanded(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DefaultButtonFactory.getButton(
                color: primaryBlue,
                buttonType: ButtonType.primaryIcon,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const Movement(direction: "forward");
                    },
                  );
                },
                icon: IconType.forwardArrow,
              ),
              const SizedBox(height: 10),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DefaultButtonFactory.getButton(
                      color: primaryOrange,
                      buttonType: ButtonType.primaryIcon,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const Rotation(direction: "left");
                          },
                        );
                      },
                      icon: IconType.rotateLeft,
                    ),
                    Expanded(
                      child: SizedBox(
                        child: Image.asset(
                          "assets/generic_atta_bot.png",
                          color: neutralWhite,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                    DefaultButtonFactory.getButton(
                      color: primaryOrange,
                      buttonType: ButtonType.primaryIcon,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const Rotation(direction: "right");
                          },
                        );
                      },
                      icon: IconType.rotateRight,
                    ),
                  ]),
              const SizedBox(height: 10),
              DefaultButtonFactory.getButton(
                color: primaryBlue,
                buttonType: ButtonType.primaryIcon,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const Movement(direction: "backward");
                    },
                  );
                },
                icon: IconType.backwardArrow,
              ),
            ]),
      ),
    );
  }
}
