import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/primary_icon_button.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/secondary_icon_button.dart';

enum ButtonType { primaryIcon, secondaryIcon }

// Enum for the different icons
enum IconType {
  forwardArrow,
  backwardArrow,
  rotateRight,
  rotateLeft,
  obstacleDetection,
  add,
  remove,
  cycle,
  pencil,
  claw,
  cloud,
}

// Factory class to create buttons
class DefaultButtonFactory {
  static Widget getButton({
    String? text,
    IconType? icon,
    required Color color,
    required ButtonType buttonType,
    double? iconSize = 26,
    double borderWidth = 3.5,
    double verticalPadding = 16,
    double horizontalPadding = 16,
    double borderRadius = 14,
    required void Function() onPressed,
  }) {
    Widget buttonData;
    if (buttonType == ButtonType.primaryIcon) {
      if (icon != null) {
        verticalPadding = 8;
        horizontalPadding = 8;
        borderRadius = 8;
        buttonData = Image.asset(
          getIconAssetPath(icon),
          width: iconSize,
          height: iconSize,
          color: neutralWhite,
        );
      } else if (text != null) {
        horizontalPadding = 20;
        verticalPadding = 4;
        buttonData = Text(
          text,
          style: const TextStyle(
            color: neutralWhite,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        );
      } else {
        throw ArgumentError(
            'Either text or icon must be provided for the button.');
      }
    } else if (buttonType == ButtonType.secondaryIcon) {
      if (icon != null) {
        buttonData = Image.asset(
          getIconAssetPath(icon),
          width: iconSize,
          height: iconSize,
          color: color,
        );
      } else if (text != null) {
        buttonData = Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        );
      } else {
        throw ArgumentError(
            'Either text or icon must be provided for the button.');
      }
    } else {
      throw ArgumentError('Invalid button type');
    }

    Map<ButtonType, Widget> buttons = {
      // If the button type is primary
      ButtonType.primaryIcon: PrimaryIconButton(
        onPressed: onPressed,
        color: color,
        verticalPadding: verticalPadding,
        horizontalPadding: horizontalPadding,
        borderWidth: borderWidth,
        borderRadius: borderRadius,
        child: buttonData,
      ),
      // If the button type is secondary
      ButtonType.secondaryIcon: SecondaryIconButton(
        onPressed: onPressed,
        verticalPadding: verticalPadding,
        horizontalPadding: horizontalPadding,
        child: buttonData,
      ),
    };
    return buttons[buttonType]!;
  }

  static String getIconAssetPath(IconType icon) {
    switch (icon) {
      case IconType.forwardArrow:
        return 'assets/button_icons/forward_arrow.png';
      case IconType.backwardArrow:
        return 'assets/button_icons/backward_arrow.png';
      case IconType.rotateRight:
        return 'assets/button_icons/rotate_right.png';
      case IconType.rotateLeft:
        return 'assets/button_icons/rotate_left.png';
      case IconType.obstacleDetection:
        return 'assets/button_icons/obstacle_detection.png';
      case IconType.add:
        return 'assets/button_icons/add.png';
      case IconType.remove:
        return 'assets/button_icons/remove.png';
      case IconType.cycle:
        return 'assets/button_icons/cycle.png';
      case IconType.pencil:
        return 'assets/button_icons/pencil.png';
      case IconType.claw:
        return 'assets/button_icons/claw.png';
      case IconType.cloud:
        return 'assets/button_icons/cloud.png';
    }
  }
}
