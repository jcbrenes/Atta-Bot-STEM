import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class PrimaryIconButton extends StatefulWidget {
  const PrimaryIconButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.color,
    this.disabled = false,
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.borderWidth,
    required this.borderRadius,
  });

  final Widget child;
  final VoidCallback onPressed;
  final Color color;
  final bool disabled;
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
      onTapUp: (_) async {
        await Future.delayed(const Duration(milliseconds: 120));
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(3), 
        decoration: BoxDecoration(
          border: _isPressed
              ? Border.all(
                  color: Colors.white, 
                  width: 2.5,
                )
              : null,
          borderRadius: BorderRadius.circular(widget.borderRadius + 6),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            vertical: widget.verticalPadding,
            horizontal: widget.horizontalPadding,
          ),
          decoration: BoxDecoration(
            color: widget.color,
            border: Border.all(
              color: neutralWhite,
              width: widget.borderWidth,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
