import 'package:flutter/material.dart';

class ObjectSimulator extends StatefulWidget {
  final String botImagePath;
  final double size;
  final bool useImage;
  final bool penActive;
  final bool obstacleDetectionActive;

  const ObjectSimulator({
    super.key,
    this.botImagePath = '',
    this.size = 40,
    this.useImage = false,
    this.penActive = false,
    this.obstacleDetectionActive = false,
  });

  @override
  State<ObjectSimulator> createState() => _ObjectSimulatorState();
}

class _ObjectSimulatorState extends State<ObjectSimulator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowScale;
  late final Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    final curved = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );
    _glowScale = Tween<double>(begin: 0.92, end: 1.12).animate(curved);
    _glowOpacity = Tween<double>(begin: 0.75, end: 1.0).animate(curved);

    if (widget.obstacleDetectionActive) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ObjectSimulator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.obstacleDetectionActive) {
      if (!_glowController.isAnimating) {
        _glowController.repeat(reverse: true);
      }
    } else {
      if (_glowController.isAnimating) {
        _glowController.stop();
      }
      _glowController.value = 0;
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Widget _buildGlow() {
    final double glowWidth = widget.size * 3.4;
    final double glowHeight = widget.size * 3.0;
    return Align(
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Opacity(
            opacity: _glowOpacity.value,
            child: Transform.translate(
              offset: Offset(0, -widget.size * 0.8),
              child: Transform.scale(
                scale: _glowScale.value,
                child: child,
              ),
            ),
          );
        },
        child: SizedBox(
          width: glowWidth,
          height: glowHeight,
          child: CustomPaint(
            painter: FlashlightGlowPainter(
              baseColor: const Color(0xFFEEB417),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget robot = widget.useImage && widget.botImagePath.isNotEmpty
        ? Image.asset(widget.botImagePath, width: widget.size, height: widget.size)
        : CustomPaint(
            size: Size(widget.size, widget.size),
            painter: TrianglePainter(),
          );

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        if (widget.obstacleDetectionActive) _buildGlow(),
        robot,
        if (widget.penActive)
          Positioned(
            left: 0,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
        if (widget.obstacleDetectionActive)
          Positioned(
            right: 0,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint trianglePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width * 0.1, size.height);
    path.lineTo(size.width * 0.9, size.height);
    path.close();

    canvas.drawPath(path, trianglePaint);

    final Paint dotPaint = Paint()
      ..color = const Color.fromARGB(255, 38, 18, 226)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, 4), 3, dotPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class FlashlightGlowPainter extends CustomPainter {
  final Color baseColor;

  FlashlightGlowPainter({
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.86);
    path.lineTo(size.width * 0.05, size.height * 0.02);
    path.lineTo(size.width * 0.95, size.height * 0.02);
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          baseColor.withOpacity(1.0),
          baseColor.withOpacity(0.7),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(path, paint);

    final innerPath = Path();
    innerPath.moveTo(size.width * 0.5, size.height * 0.82);
    innerPath.lineTo(size.width * 0.22, size.height * 0.1);
    innerPath.lineTo(size.width * 0.78, size.height * 0.1);
    innerPath.close();

    final innerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          baseColor.withOpacity(1.0),
          baseColor.withOpacity(0.85),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant FlashlightGlowPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor;
  }
}
