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
                iconSize: MediaQuery.of(context).size.width * 0.06,
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
              const SizedBox(height: 15),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DefaultButtonFactory.getButton(
                      color: primaryOrange,
                      iconSize: MediaQuery.of(context).size.width * 0.06,
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
                    SizedBox(width: 15),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.width * 0.5,
                      child: Image.asset(
                        "assets/generic_atta_bot.png",
                        color: neutralWhite,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    SizedBox(width: 15),
                    DefaultButtonFactory.getButton(
                      color: primaryOrange,
                      iconSize: MediaQuery.of(context).size.width * 0.06,
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
              const SizedBox(height: 15),
              DefaultButtonFactory.getButton(
                color: primaryBlue,
                iconSize: MediaQuery.of(context).size.width * 0.06,
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
