// ignore_for_file: prefer_const_declarations

import 'dart:math' as math;
import 'package:flutter/material.dart';

class StepRing extends StatelessWidget {
  final double progress; // 0..1
  final int steps;
  final int goal;

  const StepRing({
    super.key,
    required this.progress,
    required this.steps,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0, 1)),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return AspectRatio(
          aspectRatio: 1.3,
          child: Column(
            children: [
              SizedBox(
                height: 240,
                child: CustomPaint(
                  painter: _RingPainter(progress: v, scheme: Theme.of(context).colorScheme),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$steps', style: Theme.of(context).textTheme.displaySmall),
                        const SizedBox(height: 4),
                        Text('of $goal steps', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final ColorScheme scheme;
  _RingPainter({required this.progress, required this.scheme});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 20.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2 - stroke;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFF2A2D38);

    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 1.5 * math.pi,
      colors: [
        scheme.primary,
        scheme.secondary,
        scheme.primary,
      ],
      stops: const [0.0, .6, 1.0],
    );

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));

    // Background circle
    canvas.drawCircle(center, radius, bg);

    // Progress arc
    final sweep = 2 * math.pi * progress;
    final start = -math.pi / 2;
    final rectCircle = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rectCircle, start, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress || old.scheme != scheme;
}
