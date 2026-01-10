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
    final double glowWidth = widget.size * 5.8;
    final double glowHeight = widget.size * 2.2;
    return Align(
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Opacity(
            opacity: _glowOpacity.value,
            child: Transform.translate(
              offset: Offset(0, -widget.size * 0.55),
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
    final softColor = Color.lerp(baseColor, const Color(0xFFFFF2C0), 0.45)!;
    final haloRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.98),
      width: size.width * 0.78,
      height: size.height * 0.52,
    );
    final haloPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0.7),
        radius: 1.1,
        colors: [
          baseColor.withOpacity(0.55),
          softColor.withOpacity(0.25),
          softColor.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 0.78, 1.0],
      ).createShader(haloRect)
      ..blendMode = BlendMode.plus
      ..isAntiAlias = true
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);

    canvas.drawOval(haloRect, haloPaint);

    final outerPath = Path();
    outerPath.moveTo(size.width * 0.5, size.height * 1.04);
    outerPath.lineTo(size.width * -0.14, size.height * 0.45);
    outerPath.lineTo(size.width * 1.14, size.height * 0.45);
    outerPath.close();

    final outerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          softColor.withOpacity(0.3),
          softColor.withOpacity(0.18),
          softColor.withOpacity(0.1),
          softColor.withOpacity(0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 0.7, 0.9, 1.0],
      ).createShader(rect)
      ..blendMode = BlendMode.plus
      ..isAntiAlias = true
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawPath(outerPath, outerPaint);

    final softBeamPath = Path();
    softBeamPath.moveTo(size.width * 0.5, size.height * 0.96);
    softBeamPath.lineTo(size.width * -0.2, size.height * 0.22);
    softBeamPath.lineTo(size.width * 1.2, size.height * 0.22);
    softBeamPath.close();

    final softBeamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          baseColor.withOpacity(0.5),
          softColor.withOpacity(0.26),
          softColor.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 0.78, 1.0],
      ).createShader(rect)
      ..blendMode = BlendMode.plus
      ..isAntiAlias = true
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);

    canvas.drawPath(softBeamPath, softBeamPaint);

    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.94);
    path.quadraticBezierTo(
      size.width * 0.22,
      size.height * 0.6,
      size.width * 0.04,
      size.height * 0.28,
    );
    path.lineTo(size.width * 0.96, size.height * 0.28);
    path.quadraticBezierTo(
      size.width * 0.78,
      size.height * 0.6,
      size.width * 0.5,
      size.height * 0.94,
    );
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          baseColor.withOpacity(0.78),
          softColor.withOpacity(0.52),
          softColor.withOpacity(0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 0.78, 1.0],
      ).createShader(rect)
      ..isAntiAlias = true
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    canvas.drawPath(path, paint);

    final innerPath = Path();
    innerPath.moveTo(size.width * 0.5, size.height * 0.9);
    innerPath.quadraticBezierTo(
      size.width * 0.28,
      size.height * 0.62,
      size.width * 0.14,
      size.height * 0.34,
    );
    innerPath.lineTo(size.width * 0.86, size.height * 0.34);
    innerPath.quadraticBezierTo(
      size.width * 0.72,
      size.height * 0.62,
      size.width * 0.5,
      size.height * 0.9,
    );
    innerPath.close();

    final innerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          baseColor.withOpacity(0.7),
          softColor.withOpacity(0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(rect)
      ..isAntiAlias = true
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant FlashlightGlowPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor;
  }
}
