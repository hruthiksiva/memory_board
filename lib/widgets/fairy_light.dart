import 'package:flutter/material.dart';
import 'dart:math';

class FairyLights extends StatefulWidget {
  const FairyLights({Key? key}) : super(key: key);

  @override
  _FairyLightsState createState() => _FairyLightsState();
}

class _FairyLightsState extends State<FairyLights> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Color> _lightColors = [
    Colors.amber,
    Colors.yellow,
    Colors.orange,
    Colors.amber.shade300,
    Colors.yellow.shade600,
  ];
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: FairyLightsPainter(
            animation: _controller,
            lightColors: _lightColors,
          ),
          size: Size(MediaQuery.of(context).size.width, 60),
        );
      },
    );
  }
}

class FairyLightsPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> lightColors;
  final Random random = Random();
  
  FairyLightsPainter({
    required this.animation,
    required this.lightColors,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    const int lightsCount = 12;
    
    // Paint for the string
    final stringPaint = Paint()
      ..color = Colors.brown[300]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    // Draw string in wave pattern
    final path = Path();
    path.moveTo(0, height * 0.5);
    
    for (int i = 0; i < 4; i++) {
      path.cubicTo(
        width * (i * 0.25 + 0.125), height * 0.2,
        width * (i * 0.25 + 0.125), height * 0.8,
        width * (i + 1) * 0.25, height * 0.5,
      );
    }
    
    canvas.drawPath(path, stringPaint);
    
    // Draw lights
    for (int i = 0; i < lightsCount; i++) {
      final t = i / (lightsCount - 1);
      final x = width * t;
      
      // Calculate y position based on wave pattern
      final waveHeight = height * 0.3;
      final waveCount = 2.0;
      final y = height * 0.5 + sin(t * pi * waveCount) * waveHeight;
      
      // Light color cycling based on animation and position
      final colorIndex = (i + (animation.value * lightColors.length).floor()) % lightColors.length;
      final color = lightColors[colorIndex];
      
      // Brightness pulsing effect
      final brightness = 0.5 + 0.5 * sin(animation.value * 2 * pi + i);
      final adjustedColor = HSLColor.fromColor(color)
          .withLightness((HSLColor.fromColor(color).lightness + brightness * 0.3).clamp(0.0, 1.0))
          .toColor();
      
      // Draw glow
      final glowPaint = Paint()
        ..color = adjustedColor.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      
      canvas.drawCircle(
        Offset(x, y),
        10 * (0.7 + animation.value * 0.3),
        glowPaint,
      );
      
      // Draw light bulb
      final lightPaint = Paint()
        ..color = adjustedColor
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(x, y),
        6,
        lightPaint,
      );
      
      // Draw highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(x - 2, y - 2),
        2,
        highlightPaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}