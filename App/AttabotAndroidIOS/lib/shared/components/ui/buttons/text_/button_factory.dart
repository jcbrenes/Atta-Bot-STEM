import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

enum TextButtonType { raised, filled, outline, text }

class TextButtonFactory {
  static Widget getButton({
    required TextButtonType type,
    required String text,
    required Function() handleButtonPress,
    bool disabled = false,
    Color? textColor,
    Color? borderColor,
    Color? backgroundColor,
  }) {
    Text buttonText = Text(text);

    if (Platform.isIOS) {
      switch (type) {
        case TextButtonType.text:
          return CupertinoButton(
            onPressed: disabled ? null : handleButtonPress,
            color: backgroundColor,
            child: buttonText,
          );
        default:
          return CupertinoButton.filled(
            onPressed: disabled ? null : handleButtonPress,
            child: buttonText,
          );
      }
    } else {
      ButtonStyle materialButtonStyle = ButtonStyle(
        backgroundColor: backgroundColor != null
            ? MaterialStateProperty.all<Color>(backgroundColor)
            : null,
        foregroundColor: textColor != null
            ? MaterialStateProperty.all<Color>(textColor)
            : null,
        side: borderColor != null
            ? MaterialStateProperty.all<BorderSide>(
                BorderSide(color: borderColor))
            : null,
      );

      switch (type) {
        case TextButtonType.raised:
          return ElevatedButton(
              onPressed: disabled ? null : handleButtonPress,
              style: materialButtonStyle,
              child: buttonText);
        case TextButtonType.filled:
          return FilledButton(
              onPressed: disabled ? null : handleButtonPress,
              style: materialButtonStyle,
              child: buttonText);
        case TextButtonType.outline:
          return OutlinedButton(
              onPressed: disabled ? null : handleButtonPress,
              style: materialButtonStyle,
              child: buttonText);
        case TextButtonType.text:
          return TextButton(
              onPressed: disabled ? null : handleButtonPress,
              style: materialButtonStyle,
              child: buttonText);
      }
    }
  }
}
