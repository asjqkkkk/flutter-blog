import 'package:flutter/material.dart';

class HoverScaleWidget extends StatefulWidget {
  const HoverScaleWidget({
    Key? key,
    required this.child,
    this.scale = 1.2,
    this.duration,
    this.alignment = Alignment.center,
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  final Widget child;
  final double scale;
  final Duration? duration;
  final Curve curve;
  final AlignmentGeometry alignment;

  @override
  _HoverScaleWidgetState createState() => _HoverScaleWidgetState();
}

class _HoverScaleWidgetState extends State<HoverScaleWidget>
    with SingleTickerProviderStateMixin {
  // bool isHovering = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this,
        duration: widget.duration ?? const Duration(milliseconds: 300));
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
          final scale = widget.scale;
          final diff = scale - 1;

          return Transform.scale(
            scale: diff * _animation.value + 1,
            alignment: widget.alignment,
            child: child,
          );
        },
      ),
    );
  }
}
