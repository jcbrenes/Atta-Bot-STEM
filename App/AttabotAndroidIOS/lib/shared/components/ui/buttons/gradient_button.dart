import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.gradient,
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.borderWidth,
    required this.borderRadius,
  });

  final Widget child;
  final VoidCallback onPressed;
  final LinearGradient gradient;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderWidth;
  final double borderRadius;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
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
        padding: EdgeInsets.symmetric(vertical: widget.verticalPadding, horizontal: widget.horizontalPadding),
        decoration: BoxDecoration(
          gradient: _isPressed ? widget.gradient : null,
          color: _isPressed ? null : Colors.transparent,
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