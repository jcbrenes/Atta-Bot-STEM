import 'package:flutter/material.dart';

enum GradientDirection {
  topToBottom,
  leftToRight,
}

// A factory for creating gradient decorations
class GradientFactory {
  // Returns a gradient decoration with the specified start and end colors and direction
  static LinearGradient getGradient({
    required Color startColor,
    required Color endColor,
    required GradientDirection direction,
  }) {
    // Default values for start and end
    Alignment start = Alignment.topCenter;
    Alignment end = Alignment.bottomCenter;

    // Only two directions are defined since the start and end colors are interchangeable
    if (direction == GradientDirection.topToBottom) {
      start = Alignment.topCenter;
      end = Alignment.bottomCenter;
    } else if (direction == GradientDirection.leftToRight) {
      start = Alignment.centerLeft;
      end = Alignment.centerRight;
    }

    return LinearGradient(
      begin: start,
      end: end,
      colors: [startColor, endColor],
    );
  }
}
