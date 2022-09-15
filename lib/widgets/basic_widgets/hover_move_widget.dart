import 'package:flutter/material.dart';

class HoverMoveWidget extends StatefulWidget {
  const HoverMoveWidget({
    Key? key,
    required this.child,
    this.offset = const Offset(0, -30),
    this.duration,
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  final Widget child;
  final Offset offset;
  final Duration? duration;
  final Curve curve;

  @override
  _HoverMoveWidgetState createState() => _HoverMoveWidgetState();
}

class _HoverMoveWidgetState extends State<HoverMoveWidget>
    with SingleTickerProviderStateMixin {
  // bool isHovering = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this,
        duration: widget.duration ?? const Duration(milliseconds: 200));
    _animation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        _controller.forward();
      },
      onExit: (event) {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _animation,
        child: widget.child,
        builder: (ctx, child) {
          final value = _animation.value;
          final off = widget.offset;
          return Transform.translate(
            offset: Offset(off.dx * value, off.dy * value),
            child: child,
          );
        },
      ),
    );
  }
}
