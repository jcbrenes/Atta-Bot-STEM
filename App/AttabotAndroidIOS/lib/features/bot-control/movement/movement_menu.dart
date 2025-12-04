import 'package:flutter/material.dart';
import 'package:proyecto_tec/features/bot-control/movement/rotation.dart';
import 'package:proyecto_tec/features/bot-control/movement/movement.dart';
import 'package:proyecto_tec/features/bot-control/movement/simplified_movement.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/default_button_factory.dart';


class MovementMenu extends StatelessWidget {
  final bool simplifiedMode;
  final int defaultDistance;
  final int defaultAngle;
  const MovementMenu({super.key, required this.simplifiedMode, required this.defaultDistance, required this.defaultAngle});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        final double iconSize = isLandscape ? (w * 0.09).clamp(24, 36) : (w * 0.11).clamp(28, 40);
        final double imageSide = isLandscape ? (w * 0.36).clamp(96, 190) : (w * 0.40).clamp(110, 220);
        const double vGap = 15;
        const double hGap = 15;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DefaultButtonFactory.getButton(
                color: primaryBlue,
                iconSize: iconSize,
                buttonType: ButtonType.primaryIcon,
                onPressed: () {
                  if (simplifiedMode) {
                    showDialog(
                      context: context,
                      useRootNavigator: !isLandscape,
                      builder: (BuildContext context) {
                        return SimpleConfirmDialog(movement: "forward", value: defaultDistance);
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      useRootNavigator: !isLandscape,
                      builder: (BuildContext context) {
                        return const Movement(direction: "forward");
                      },
                    );
                  }
                },
                icon: IconType.forwardArrow,
              ),
              const SizedBox(height: vGap),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DefaultButtonFactory.getButton(
                      color: primaryOrange,
                      iconSize: iconSize,
                      buttonType: ButtonType.primaryIcon,
                      onPressed: () {
                        if (simplifiedMode) {
                          showDialog(
                            context: context,
                            useRootNavigator: !isLandscape,
                            builder: (BuildContext context) {
                              return SimpleConfirmDialog(movement: "left", value: defaultAngle);
                            },
                          );
                        } else {
                          showDialog(
                            context: context,
                            useRootNavigator: !isLandscape,
                            builder: (BuildContext context) {
                              return const Rotation(direction: "left");
                            },
                          );
                        }
                      },
                      icon: IconType.rotateLeft,
                    ),
                    const SizedBox(width: hGap),
                    SizedBox(
                      width: imageSide,
                      height: imageSide,
                      child: Image.asset(
                        "assets/atta_bot.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: hGap),
                    DefaultButtonFactory.getButton(
                      color: primaryOrange,
                      iconSize: iconSize,
                      buttonType: ButtonType.primaryIcon,
                      onPressed: () {
                        if (simplifiedMode) {
                          showDialog(
                            context: context,
                            useRootNavigator: !isLandscape,
                            builder: (BuildContext context) {
                              return SimpleConfirmDialog(movement: "right", value: defaultAngle);
                            },
                          );
                        } else {
                          showDialog(
                            context: context,
                            useRootNavigator: !isLandscape,
                            builder: (BuildContext context) {
                              return const Rotation(direction: "right");
                            },
                          );
                        }
                      },
                      icon: IconType.rotateRight,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: vGap),
              DefaultButtonFactory.getButton(
                color: primaryBlue,
                iconSize: iconSize,
                buttonType: ButtonType.primaryIcon,
                onPressed: () {
                  if (simplifiedMode) {
                    showDialog(
                      context: context,
                      useRootNavigator: !isLandscape,
                      builder: (BuildContext context) {
                        return SimpleConfirmDialog(movement: "backward", value: defaultDistance);
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      useRootNavigator: !isLandscape,
                      builder: (BuildContext context) {
                        return const Movement(direction: "backward");
                      },
                    );
                  }
                },
                icon: IconType.backwardArrow,
              ),
            ],
          ),
        );
      },
    );
  }
}
