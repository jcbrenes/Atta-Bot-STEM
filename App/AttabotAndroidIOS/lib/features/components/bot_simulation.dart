import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/components/ui/images/bot_asset_image.dart';

class BotSimulation extends StatelessWidget {
  final String botImagePath;
  final double circleSize = 25;
  final double imageSize = 50;
  const BotSimulation({super.key, this.botImagePath = ''});

  Widget paintCircle(double circleSize) {
    return Container(
        width: circleSize,
        height: circleSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return botImagePath.isEmpty
        ? paintCircle(circleSize)
        : BotAssetImage(
            assetPath: botImagePath,
            width: imageSize,
            height: imageSize,
          );
  }
}
