import 'package:flutter/material.dart';

class NumberBall extends StatefulWidget {
  final int number;
  final bool isCalled;
  final bool isLast;

  const NumberBall({
    super.key,
    required this.number,
    required this.isCalled,
    required this.isLast,
  });

  @override
  State<NumberBall> createState() => _NumberBallState();
}

class _NumberBallState extends State<NumberBall> with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _auraCtrl;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _auraCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    if (widget.isLast) {
      _startLastAnimations();
    }
  }

  @override
  void didUpdateWidget(covariant NumberBall oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isLast && widget.isLast) {
      _startLastAnimations();
    } else if (oldWidget.isLast && !widget.isLast) {
      _auraCtrl.stop();
      _pulseCtrl.reset();
    }
  }

  void _startLastAnimations() {
    _pulseCtrl
      ..reset()
      ..forward();
    _auraCtrl.repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _auraCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color baseColor = const Color(0xFF333333);
    Color textColor = Colors.white70;

    if (widget.isLast) {
      baseColor = Colors.red.shade700;
      textColor = Colors.white;
    } else if (widget.isCalled) {
      baseColor = Colors.teal.shade700;
      textColor = Colors.white;
    }

    final double calledScale = widget.isCalled ? 1.05 : 1.0;

    final Animation<double> lastScale = Tween<double>(
      begin: 0.7,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.elasticOut));

    return LayoutBuilder(
      builder: (context, cell) {
        final side = cell.biggest.shortestSide;
        final fontSize = side * 0.38;

        Widget aura = const SizedBox.shrink();
        if (widget.isLast) {
          aura = AnimatedBuilder(
            animation: _auraCtrl,
            builder: (context, _) {
              return Transform.rotate(
                angle: _auraCtrl.value * 6.28318,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    gradient: SweepGradient(
                      colors: [
                        Colors.red.withValues(alpha: 0.0),
                        Colors.redAccent.withValues(alpha: 0.25),
                        Colors.orangeAccent.withValues(alpha: 0.35),
                        Colors.redAccent.withValues(alpha: 0.25),
                        Colors.red.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                    ),
                  ),
                ),
              );
            },
          );
        }

        final ball = AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: baseColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:
                    widget.isLast
                        ? Colors.redAccent.withValues(alpha: 0.6)
                        : Colors.black.withValues(alpha: 0.35),
                blurRadius: widget.isLast ? 22 : 10,
                spreadRadius: widget.isLast ? 2 : 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.number.toString(),
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
          ),
        );

        final scaledBall =
            widget.isLast
                ? ScaleTransition(scale: lastScale, child: ball)
                : AnimatedScale(
                  duration: const Duration(milliseconds: 250),
                  scale: calledScale,
                  curve: Curves.easeOut,
                  child: ball,
                );

        return Stack(
          fit: StackFit.expand,
          children: [
            if (widget.isLast) aura,

            Padding(padding: const EdgeInsets.all(1.0), child: scaledBall),
          ],
        );
      },
    );
  }
}
