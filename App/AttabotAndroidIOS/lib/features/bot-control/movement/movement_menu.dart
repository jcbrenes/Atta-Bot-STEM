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
                  if(simplifiedMode) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SimpleConfirmDialog(movement: "forward", value: defaultDistance);
                      },
                    );
                    
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const Movement(direction: "forward");
                      },
                    );
                  }
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
                        if(simplifiedMode) {
                          showDialog(
                            context: context, 
                            builder: (BuildContext context) {
                              return SimpleConfirmDialog(movement: "left", value: defaultAngle);
                            },
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const Rotation(direction: "left");
                            },
                          );
                        }
                      },
                      icon: IconType.rotateLeft,
                    ),
                    SizedBox(width: 15),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.width * 0.5,
                      child: Image.asset(
                        "assets/atta_bot.png",
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    SizedBox(width: 15),
                    DefaultButtonFactory.getButton(
                      color: primaryOrange,
                      iconSize: MediaQuery.of(context).size.width * 0.06,
                      buttonType: ButtonType.primaryIcon,
                      onPressed: () {
                        if(simplifiedMode) {
                          showDialog(
                            context: context, 
                            builder: (BuildContext context) {
                              return SimpleConfirmDialog(movement: "right", value: defaultAngle);
                            },
                          );
                          
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const Rotation(direction: "right");
                            },
                          );
                        }
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
                  if(simplifiedMode) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SimpleConfirmDialog(movement: "backward", value: defaultDistance);
                      },
                    );
                    
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const Movement(direction: "backward");
                      },
                    );
                  }
                },
                icon: IconType.backwardArrow,
              ),
            ]),
      ),
    );
  }
}
