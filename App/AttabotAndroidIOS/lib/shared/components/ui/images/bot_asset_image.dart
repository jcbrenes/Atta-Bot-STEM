import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BotAssetImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const BotAssetImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  bool get _isSvg => assetPath.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (_isSvg) {
      return SvgPicture.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
      );
    }

    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
