import 'package:flutter/material.dart';

class FlipNumber extends StatefulWidget {
  final String value;
  final TextStyle style;
  final Duration duration;

  const FlipNumber({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 450),
  });

  @override
  State<FlipNumber> createState() => _FlipNumberState();
}

class _FlipNumberState extends State<FlipNumber>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _t;
  String _current = '--';
  String _next = '--';

  @override
  void initState() {
    super.initState();
    _current = widget.value;
    _next = widget.value;
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _t = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
  }

  @override
  void didUpdateWidget(covariant FlipNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _next = widget.value;
      _ctrl
        ..stop()
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, _) {
          final isFirstHalf = _t.value < 0.5;
          final localT =
              isFirstHalf ? (_t.value / 0.5) : ((_t.value - 0.5) / 0.5);

          final double angle =
              isFirstHalf
                  ? (localT * (3.141592653589793 / 2))
                  : (-(3.141592653589793 / 2) +
                      localT * (3.141592653589793 / 2));

          if (!isFirstHalf && _current != _next) {
            _current = _next;
          }

          final double scale =
              isFirstHalf ? (1.0 - 0.08 * localT) : (0.92 + 0.08 * localT);

          return Transform(
            alignment: Alignment.center,
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle)
                  ..scale(scale),
            child: Text(_current, style: widget.style),
          );
        },
      ),
    );
  }
}
