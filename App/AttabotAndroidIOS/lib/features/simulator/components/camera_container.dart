import 'dart:async';
import 'package:flutter/material.dart';

class CameraContainer extends StatefulWidget {
  final Widget child;
  final double focusX;
  final double focusY;
  final double areaWidth;
  final double areaHeight;
  final double viewWidth;
  final double viewHeight;

  const CameraContainer({
    super.key,
    required this.child,
    required this.focusX,
    required this.focusY,
    required this.areaWidth,
    required this.areaHeight,
    required this.viewWidth,
    required this.viewHeight,
  });

  @override
  State<CameraContainer> createState() => _CameraContainerState();
}

class _CameraContainerState extends State<CameraContainer> {
  double _currentOffsetX = 0.0;
  double _currentOffsetY = 0.0;
  double _targetOffsetX = 0.0;
  double _targetOffsetY = 0.0;
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _updateTargetOffset();
    _startAnimation();
  }

  @override
  void didUpdateWidget(covariant CameraContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTargetOffset();
  }

  void _updateTargetOffset() {
    _targetOffsetX = (widget.focusX - widget.viewWidth / 2)
        .clamp(0.0, widget.areaWidth - widget.viewWidth);
    _targetOffsetY = (widget.focusY - widget.viewHeight / 2)
        .clamp(0.0, widget.areaHeight - widget.viewHeight);
  }

  void _startAnimation() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final dx = _targetOffsetX - _currentOffsetX;
      final dy = _targetOffsetY - _currentOffsetY;

      if (dx.abs() < 0.1 && dy.abs() < 0.1) {
        return;
      }

      setState(() {
        _currentOffsetX += dx * 0.1;
        _currentOffsetY += dy * 0.1;
      });
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        width: widget.viewWidth,
        height: widget.viewHeight,
        child: Stack(
          children: [
            Transform.translate(
              offset: Offset(-_currentOffsetX, -_currentOffsetY),
              child: SizedBox(
                width: widget.areaWidth,
                height: widget.areaHeight,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
