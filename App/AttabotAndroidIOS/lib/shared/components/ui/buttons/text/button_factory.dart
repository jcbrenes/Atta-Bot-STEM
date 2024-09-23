import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

enum TextButtonType { raised, filled, outline, text, warning }

/// A factory for creating text buttons. returns a Material or Cupertino button based on the platform.
class TextButtonFactory {
  /// Returns a button with the specified [type], [text], and [handleButtonPress].
  ///
  /// The button is disabled if [disabled] is true.
  /// The button's text color is [textColor], the border color is [borderColor],
  /// and the background color is [backgroundColor].
  ///
  /// If [textColor], [borderColor], or [backgroundColor] is null, the button
  /// will use the default color for that property.
  ///
  /// [textColor], [borderColor], [backgroundColor], [textSize] are only used on Android.
  static Widget getButton({
    required TextButtonType type,
    required String text,
    required Function() handleButtonPress,
    bool disabled = false,
    double? textSize,
    Color? textColor,
    Color? borderColor,
    Color? backgroundColor,
  }) {
    Text buttonText = Text(text);

    if (Platform.isIOS) {
      return type == TextButtonType.text
          ? CupertinoButton(
              onPressed: disabled ? null : handleButtonPress,
              color: backgroundColor,
              child: buttonText,
              
            )
          : CupertinoButton.filled(
              onPressed: disabled ? null : handleButtonPress,
              child: buttonText,
            );
    } else {
      ButtonStyle materialButtonStyle = ButtonStyle(
        backgroundColor: backgroundColor != null
            ? WidgetStateProperty.all<Color>(backgroundColor)
            : null,
        foregroundColor: textColor != null
            ? WidgetStateProperty.all<Color>(textColor)
            : null,
        side: borderColor != null
            ? WidgetStateProperty.all<BorderSide>(
                BorderSide(color: borderColor))
            : null,
        textStyle: textSize != null
            ? WidgetStateProperty.all<TextStyle>(
                TextStyle(fontSize: textSize))
            : null,
      );
      ButtonStyle warningButtonStyle = ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      );
      Map<TextButtonType, Widget> buttons = {
        TextButtonType.raised: ElevatedButton(
          onPressed: disabled ? null : handleButtonPress,
          style: materialButtonStyle,
          child: buttonText,
        ),
        TextButtonType.filled: FilledButton(
          onPressed: disabled ? null : handleButtonPress,
          style: materialButtonStyle,
          child: buttonText,
        ),
        TextButtonType.outline: OutlinedButton(
          onPressed: disabled ? null : handleButtonPress,
          style: materialButtonStyle,
          child: buttonText,
        ),
        TextButtonType.text: TextButton(
          onPressed: disabled ? null : handleButtonPress,
          style: materialButtonStyle,
          child: buttonText,
        ),
        TextButtonType.warning: ElevatedButton(
          onPressed: disabled ? null : handleButtonPress,
          style: warningButtonStyle,
          child: buttonText,
        ),
      };

      return buttons[type]!;
    }
  }
}
