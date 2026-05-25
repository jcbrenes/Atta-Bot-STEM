import 'package:flutter/material.dart';
import 'package:proyecto_tec/shared/components/ui/images/bot_asset_image.dart';

class ObjectSimulator extends StatefulWidget {
  final String botImagePath;
  final double size;
  final bool useImage;
  final bool penActive;
  final bool obstacleDetectionActive;
  final double rotationRadians;

  const ObjectSimulator({
    super.key,
    this.botImagePath = '',
    this.size = 40,
    this.useImage = false,
    this.penActive = false,
    this.obstacleDetectionActive = false,
    this.rotationRadians = 0,
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
    _glowScale = Tween<double>(begin: 1, end: 1).animate(curved);
    _glowOpacity = Tween<double>(begin: 1, end: 1).animate(curved);

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
    final double glowWidth = widget.size * 2.2;
    final double glowHeight = widget.size * 1.12;
    final double glowExtent = widget.size * 4.8;
    return OverflowBox(
      maxWidth: glowExtent,
      maxHeight: glowExtent,
      child: SizedBox(
        width: glowExtent,
        height: glowExtent,
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Opacity(
              opacity: _glowOpacity.value,
              child: CustomPaint(
                size: Size(glowExtent, glowExtent),
                painter: FlashlightGlowPainter(
                  baseColor: const Color(0xFFEEB417),
                  beamWidth: glowWidth * _glowScale.value,
                  beamHeight: glowHeight * _glowScale.value,
                  rotationRadians: widget.rotationRadians,
                ),
              ),
            );
          },
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
        Transform.rotate(
          angle: widget.rotationRadians,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
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
  final double beamWidth;
  final double beamHeight;
  final double rotationRadians;

  FlashlightGlowPainter({
    required this.baseColor,
    required this.beamWidth,
    required this.beamHeight,
    required this.rotationRadians,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final beamSize = Size(beamWidth, beamHeight);
    final beamOrigin = Offset(-beamWidth / 2, -beamHeight);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotationRadians);
    canvas.translate(beamOrigin.dx, beamOrigin.dy);

    final rect = Offset.zero & beamSize;
    const strongYellow = Color(0xFFFFC400);
    const softYellow = Color(0xFFFFD93D);

    final outerBeam = Path()
      ..moveTo(beamSize.width * 0.5, beamSize.height * 0.98)
      ..lineTo(beamSize.width * -0.16, beamSize.height * 0.42)
      ..quadraticBezierTo(
        beamSize.width * 0.08,
        beamSize.height * 0.18,
        beamSize.width * 0.5,
        beamSize.height * 0.08,
      )
      ..quadraticBezierTo(
        beamSize.width * 0.92,
        beamSize.height * 0.18,
        beamSize.width * 1.16,
        beamSize.height * 0.42,
      )
      ..close();

    final outerBeamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          strongYellow.withValues(alpha: 0.86),
          strongYellow.withValues(alpha: 0.58),
          softYellow.withValues(alpha: 0.34),
          Colors.transparent,
        ],
        stops: const [0.0, 0.42, 0.74, 1.0],
      ).createShader(rect)
      ..isAntiAlias = true
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawPath(outerBeam, outerBeamPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FlashlightGlowPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor ||
        oldDelegate.beamWidth != beamWidth ||
        oldDelegate.beamHeight != beamHeight ||
        oldDelegate.rotationRadians != rotationRadians;
  }
}
