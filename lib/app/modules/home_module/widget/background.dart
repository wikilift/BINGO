import 'dart:math';
import 'package:flutter/material.dart';

class BingoBackground extends StatefulWidget {
  final double speedFactor;
  final bool showGrid;
  final bool vivid;

  const BingoBackground({
    super.key,
    this.speedFactor = 1.0,
    this.showGrid = true,
    this.vivid = true,
  });

  @override
  State<BingoBackground> createState() => _BingoBackgroundState();
}

class _BingoBackgroundState extends State<BingoBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Star> _stars;
  final _rng = Random(7);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _stars = List.generate(36, (i) {
      final r = 0.8 + _rng.nextDouble() * 1.8;
      final twinkle = 0.35 + _rng.nextDouble() * 0.45;
      final phase = _rng.nextDouble() * pi * 2;
      return _Star(radius: r, phase: phase, maxOpacity: twinkle);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _BGPainter(
          repaint: _ctrl,
          stars: _stars,
          speed: widget.speedFactor,
          showGrid: widget.showGrid,
          vivid: widget.vivid,
        ),
        isComplex: true,
        willChange: true,
      ),
    );
  }
}

class _Star {
  final double radius;
  final double phase;
  final double maxOpacity;
  const _Star({
    required this.radius,
    required this.phase,
    required this.maxOpacity,
  });
}

class _BGPainter extends CustomPainter {
  final Animation<double> repaint;
  final List<_Star> stars;
  final double speed;
  final bool showGrid;
  final bool vivid;

  _BGPainter({
    required this.repaint,
    required this.stars,
    required this.speed,
    required this.showGrid,
    required this.vivid,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final t = repaint.value * 2 * pi * speed;

    _paintBaseGradient(canvas, size, t);
    _paintBlobs(canvas, size, t);
    _paintAurora(canvas, size, t);
    _paintStars(canvas, size, t);
    if (showGrid) _paintParallaxGrid(canvas, size, t);
    _paintVignette(canvas, size);
  }

  void _paintBaseGradient(Canvas canvas, Size s, double t) {
    final ang = 0.2 * sin(t * 0.4);
    final paint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                vivid
                    ? const [
                      Color(0xFF0D0F12),
                      Color(0xFF10161A),
                      Color(0xFF0B0E10),
                    ]
                    : const [
                      Color(0xFF111214),
                      Color(0xFF14191C),
                      Color(0xFF0F1213),
                    ],
            stops: const [0.0, 0.6, 1.0],
            transform: GradientRotation(ang),
          ).createShader(Offset.zero & s);
    canvas.drawRect(Offset.zero & s, paint);
  }

  void _paintBlobs(Canvas canvas, Size s, double t) {
    final c = s.center(Offset.zero);
    final m = min(s.width, s.height);

    void blob(Color a, Color b, Offset pos, double r) {
      final rect = Rect.fromCircle(center: pos, radius: r);
      final p =
          Paint()
            ..shader = RadialGradient(
              colors: [a.withValues(alpha: 0.55), b.withValues(alpha: 0.0)],
              stops: const [0.0, 1.0],
            ).createShader(rect);
      canvas.drawCircle(pos, r, p);
    }

    final p1 = c + Offset(cos(t * 0.7) * m * 0.22, sin(t * 0.5) * m * 0.18);
    final p2 =
        c +
        Offset(cos(t * 0.9 + 2.1) * m * 0.26, sin(t * 0.8 + 1.3) * m * 0.20);
    final p3 =
        c +
        Offset(cos(t * 0.6 + 4.0) * m * 0.24, sin(t * 0.4 + 0.7) * m * 0.16);

    blob(Colors.tealAccent, Colors.teal, p1, m * 0.42);
    blob(Colors.purpleAccent, Colors.deepPurple, p2, m * 0.38);
    blob(Colors.orangeAccent, Colors.redAccent, p3, m * 0.36);
  }

  void _paintAurora(Canvas canvas, Size s, double t) {
    final m = min(s.width, s.height);
    final paths = <Path>[];

    Path wave(double yBase, double amp, double freq, double phase) {
      final p = Path()..moveTo(0, yBase);
      for (double x = 0; x <= s.width; x += 8) {
        final y =
            yBase + sin((x / s.width) * freq * 2 * pi + phase + t * 0.6) * amp;
        p.lineTo(x, y);
      }
      p.lineTo(s.width, s.height);
      p.lineTo(0, s.height);
      p.close();
      return p;
    }

    paths.add(wave(s.height * (0.30 + 0.02 * sin(t)), m * 0.03, 3.0, 0.0));
    paths.add(wave(s.height * (0.45 + 0.015 * cos(t)), m * 0.025, 2.0, 1.3));
    paths.add(
      wave(s.height * (0.60 + 0.02 * sin(t * 0.8)), m * 0.03, 2.8, 2.4),
    );

    final paints = [
      Paint()
        ..blendMode = BlendMode.plus
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24)
        ..shader = LinearGradient(
          colors: [
            Colors.cyanAccent.withValues(alpha: 0.12),
            Colors.tealAccent.withValues(alpha: 0.0),
          ],
        ).createShader(Offset.zero & s),
      Paint()
        ..blendMode = BlendMode.plus
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30)
        ..shader = LinearGradient(
          colors: [
            Colors.purpleAccent.withValues(alpha: 0.10),
            Colors.deepPurple.withValues(alpha: 0.0),
          ],
        ).createShader(Offset.zero & s),
      Paint()
        ..blendMode = BlendMode.plus
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26)
        ..shader = LinearGradient(
          colors: [
            Colors.orangeAccent.withValues(alpha: 0.10),
            Colors.redAccent.withValues(alpha: 0.0),
          ],
        ).createShader(Offset.zero & s),
    ];

    for (int i = 0; i < paths.length; i++) {
      canvas.drawPath(paths[i], paints[i]);
    }
  }

  void _paintStars(Canvas canvas, Size s, double t) {
    final rnd = Random(99);
    for (int i = 0; i < stars.length; i++) {
      final star = stars[i];

      final x = (s.width * ((i * 127.1) % 1000) / 1000.0);
      final y = (s.height * ((i * 379.7) % 1000) / 1000.0);
      final op =
          (0.5 + 0.5 * sin(t * 1.4 + star.phase + i * 0.35)) * star.maxOpacity;

      final paint =
          Paint()
            ..color = Colors.white.withValues(alpha: op)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(Offset(x, y), star.radius, paint);

      if (i % 7 == 0) {
        final hue = (200 + (rnd.nextDouble() * 40)) % 360;
        final c = HSVColor.fromAHSV(op * 0.6, hue, 0.4, 0.98).toColor();
        final p2 =
            Paint()
              ..color = c
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(Offset(x + 1, y + 1), star.radius * 1.6, p2);
      }
    }
  }

  void _paintParallaxGrid(Canvas canvas, Size s, double t) {
    final off = Offset(sin(t * 0.15) * 8, cos(t * 0.12) * 6);
    final paint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.028)
          ..strokeWidth = 1.0;
    const step = 56.0;

    for (double x = off.dx % step; x <= s.width + step; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, s.height), paint);
    }
    for (double y = off.dy % step; y <= s.height + step; y += step) {
      canvas.drawLine(Offset(0, y), Offset(s.width, y), paint);
    }
  }

  void _paintVignette(Canvas canvas, Size s) {
    final rect = Offset.zero & s;
    final vignette =
        Paint()
          ..shader = RadialGradient(
            center: Alignment.center,
            radius: 0.98,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.22)],
            stops: const [0.76, 1.0],
          ).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  @override
  bool shouldRepaint(covariant _BGPainter oldDelegate) =>
      oldDelegate.speed != speed ||
      oldDelegate.showGrid != showGrid ||
      oldDelegate.vivid != vivid;
}
