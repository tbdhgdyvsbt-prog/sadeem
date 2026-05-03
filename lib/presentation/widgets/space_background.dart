import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import 'dart:math' as math;

class SpaceBackground extends StatefulWidget {
  final Widget child;
  const SpaceBackground({super.key, required this.child});

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = List.generate(50, (index) => Star());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: SadeemColors.deepSpace),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: StarPainter(_stars, _controller.value),
              child: Container(),
            );
          },
        ),
        SizedBox.expand(child: widget.child),
      ],
    );
  }
}

class Star {
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  double size = math.Random().nextDouble() * 2;
  double opacity = math.Random().nextDouble();
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = SadeemColors.starWhite;

    for (var star in stars) {
      // Slight twinkling effect using sine wave based on animation value
      double opacity = (math.sin(animationValue * 2 * math.pi + star.x * 10) * 0.5 + 0.5) * star.opacity;
      paint.color = SadeemColors.starWhite.withOpacity(opacity);
      
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
