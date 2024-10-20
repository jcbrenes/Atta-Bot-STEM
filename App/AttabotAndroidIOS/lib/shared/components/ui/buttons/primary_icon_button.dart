import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class PrimaryIconButton extends StatefulWidget {
  const PrimaryIconButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.color,
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.borderWidth,
    required this.borderRadius,
  });

  final Widget child;
  final VoidCallback onPressed;
  final Color color;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderWidth;
  final double borderRadius;

  @override
  State<PrimaryIconButton> createState() => _PrimaryIconButtonState();
}

class _PrimaryIconButtonState extends State<PrimaryIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: widget.verticalPadding,
            horizontal: widget.horizontalPadding),
        decoration: BoxDecoration(
          color: _isPressed ? widget.color : Colors.transparent,
          border: Border.all(
            color: neutralWhite,
            width: widget.borderWidth,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: widget.child,
      ),
    );
  }
}
