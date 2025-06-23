import 'package:flutter/material.dart';

class ItemSeparator extends StatelessWidget {
  final double dimension = 10;

  const ItemSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: dimension,
    );
  }
}
