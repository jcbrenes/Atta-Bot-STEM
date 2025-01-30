import 'package:flutter/material.dart';

class SecondaryIconButton extends StatefulWidget {
  const SecondaryIconButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.verticalPadding,
    required this.horizontalPadding,
  });

  final Widget child;
  final VoidCallback onPressed;
  final double horizontalPadding;
  final double verticalPadding;

  @override
  State<SecondaryIconButton> createState() => _SecondaryIconButtonState();
}

class _SecondaryIconButtonState extends State<SecondaryIconButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (_) {
        setState(() {});
        widget.onPressed();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: widget.verticalPadding,
            horizontal: widget.horizontalPadding),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: widget.child,
      ),
    );
  }
}
