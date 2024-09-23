import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/bot-control/movement/rotation.dart';
import 'package:proyecto_tec/features/bot-control/movement/movement.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/styles/gradient_factory.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';

class MovementMenu extends StatelessWidget {
  const MovementMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(children: [
        DefaultButtonFactory.getButton(
          decoration: GradientFactory.getGradient(
              startColor: primaryDarkBlue,
              endColor: primaryBlue,
              direction: GradientDirection.topToBottom),
          buttonType: ButtonType.primary,
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
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          DefaultButtonFactory.getButton(
            decoration: GradientFactory.getGradient(
                startColor: primaryDarkOrange,
                endColor: primaryOrange,
                direction: GradientDirection.leftToRight),
            buttonType: ButtonType.primary,
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
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Image.asset(
                'assets/generic_atta_bot.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          DefaultButtonFactory.getButton(
            decoration: GradientFactory.getGradient(
                startColor: primaryOrange,
                endColor: primaryDarkOrange,
                direction: GradientDirection.leftToRight),
            buttonType: ButtonType.primary,
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
        DefaultButtonFactory.getButton(
          decoration: GradientFactory.getGradient(
              startColor: primaryBlue,
              endColor: primaryDarkBlue,
              direction: GradientDirection.topToBottom),
          buttonType: ButtonType.primary,
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
    );
  }
}
