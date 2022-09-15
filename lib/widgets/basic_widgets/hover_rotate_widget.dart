import 'dart:math';

import 'package:flutter/material.dart';

class HoverRotateWidget extends StatefulWidget {
  const HoverRotateWidget({
    Key? key,
    required this.child,
    this.duration,
    this.origin,
    this.curve = Curves.linear,
  }) : super(key: key);

  final Widget child;
  final Duration? duration;
  final Offset? origin;
  final Curve curve;

  @override
  _HoverRotateWidgetState createState() => _HoverRotateWidgetState();
}

class _HoverRotateWidgetState extends State<HoverRotateWidget>
    with SingleTickerProviderStateMixin {
  // bool isHovering = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  int time = 1;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this,
        duration: widget.duration ?? const Duration(milliseconds: 2000));
    _animation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _controller.forward();
        if (time < 8) time++;
      }
    });
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
      onHover: (event) {},
      onEnter: (event) {
        _controller.forward();
      },
      onExit: (event) {
        _controller.reset();
        time = 1;
      },
      child: AnimatedBuilder(
        animation: _animation,
        child: widget.child,
        builder: (ctx, child) {
          final t = _animation.value + time;
          final angle = 2 * pi * (t * t);
          return Transform.rotate(
            angle: angle,
            child: child,
            origin: widget.origin ?? Offset.zero,
          );
        },
      ),
    );
  }
}
