import 'package:flutter/material.dart';

enum SeparatorType { item, context }

class SeparatorFactory {

  static const double itemSpace = 15;
  static const double contextSpace = 50;

  static Widget getSeparator({required SeparatorType type}) {
     const Map<SeparatorType, SizedBox> separators = {
      SeparatorType.item: SizedBox.square(dimension: itemSpace),
      SeparatorType.context: SizedBox.square(dimension: contextSpace),
    };

    return separators[type]!;
  }
}
