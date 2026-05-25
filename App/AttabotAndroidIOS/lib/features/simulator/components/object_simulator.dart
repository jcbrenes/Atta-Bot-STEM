import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/components/ui/images/bot_asset_image.dart';

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
    _glowScale = Tween<double>(begin: 0.95, end: 1.2).animate(curved);
    _glowOpacity = Tween<double>(begin: 0.85, end: 1.0).animate(curved);

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
    final double glowWidth = widget.size * 7.4;
    final double glowHeight = widget.size * 3.6;
    return Align(
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Opacity(
            opacity: _glowOpacity.value,
            child: Transform.translate(
              offset: Offset(0, -widget.size * 0.95),
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
        ? BotAssetImage(
            assetPath: widget.botImagePath,
            width: widget.size,
            height: widget.size,
          )
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
    final rect = Offset.zero & size;
    final warmColor = Color.lerp(baseColor, const Color(0xFFFFF2B0), 0.45)!;
    final paleColor = Color.lerp(baseColor, const Color(0xFFFFF9DE), 0.72)!;

    final outerBeam = Path()
      ..moveTo(size.width * 0.5, size.height * 0.98)
      ..lineTo(size.width * -0.16, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.08,
        size.height * 0.18,
        size.width * 0.5,
        size.height * 0.08,
      )
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height * 0.18,
        size.width * 1.16,
        size.height * 0.42,
      )
      ..close();

    final outerBeamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          baseColor.withValues(alpha: 0.68),
          warmColor.withValues(alpha: 0.34),
          paleColor.withValues(alpha: 0.14),
          Colors.transparent,
        ],
        stops: const [0.0, 0.38, 0.72, 1.0],
      ).createShader(rect)
      ..blendMode = BlendMode.plus
      ..isAntiAlias = true
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawPath(outerBeam, outerBeamPaint);

    final innerBeam = Path()
      ..moveTo(size.width * 0.5, size.height * 0.98)
      ..lineTo(size.width * 0.06, size.height * 0.46)
      ..quadraticBezierTo(
        size.width * 0.19,
        size.height * 0.24,
        size.width * 0.5,
        size.height * 0.14,
      )
      ..quadraticBezierTo(
        size.width * 0.81,
        size.height * 0.24,
        size.width * 0.94,
        size.height * 0.46,
      )
      ..close();

    final innerBeamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          baseColor.withValues(alpha: 0.92),
          warmColor.withValues(alpha: 0.56),
          paleColor.withValues(alpha: 0.22),
          Colors.transparent,
        ],
        stops: const [0.0, 0.34, 0.7, 1.0],
      ).createShader(rect)
      ..blendMode = BlendMode.plus
      ..isAntiAlias = true
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(innerBeam, innerBeamPaint);

    final hotspotRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.28),
      width: size.width * 0.86,
      height: size.height * 0.34,
    );
    final hotspotPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0),
        radius: 0.95,
        colors: [
          paleColor.withValues(alpha: 0.5),
          warmColor.withValues(alpha: 0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.58, 1.0],
      ).createShader(hotspotRect)
      ..blendMode = BlendMode.plus
      ..isAntiAlias = true
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawOval(hotspotRect, hotspotPaint);

  }

  @override
  bool shouldRepaint(covariant FlashlightGlowPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor;
  }
}
