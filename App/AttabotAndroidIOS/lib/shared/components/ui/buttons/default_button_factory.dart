import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/gradient_button.dart';

enum ButtonType { primary, secondary }

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
}

// Factory class to create buttons
class DefaultButtonFactory {
  static Widget getButton({
    String? text,
    IconType? icon,
    required LinearGradient decoration,
    required ButtonType buttonType,
    double? iconSize = 40,
    double borderWidth = 4,
    double verticalPadding = 16,
    double horizontalPadding = 16,
    double borderRadius = 16,
    required void Function() onPressed,
  }) {
    Widget buttonData;

    if (icon != null) {
      buttonData = Image.asset(
        getIconAssetPath(icon),
        width: iconSize,
        height: iconSize,
        color: neutralWhite,
      );
    } else if (text != null) {
      horizontalPadding = 40;
      verticalPadding = 6;
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

    Map<ButtonType, Widget> buttons = {
      // If the button type is primary
      ButtonType.primary: GradientButton(
        onPressed: onPressed,
        gradient: decoration,
        verticalPadding: verticalPadding,
        horizontalPadding: horizontalPadding,
        borderWidth: borderWidth,
        borderRadius: borderRadius,
        child: buttonData,
      ),
      // If the button type is secondary
      ButtonType.secondary: Container(
        child: TextButton(
          onPressed: onPressed,
          child: buttonData,
        ),
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
      default:
        throw ArgumentError('Invalid icon type');
    }
  }
}