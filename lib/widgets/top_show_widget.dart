import 'package:flutter/material.dart';

class TopAnimationShowWidget extends StatefulWidget {
  const TopAnimationShowWidget(
      {required this.child, this.duration, this.distanceY = 0});

  final Widget child;
  final Duration? duration;
  final double distanceY;
  @override
  _TopAnimationShowWidgetState createState() => _TopAnimationShowWidgetState();
}

class _TopAnimationShowWidgetState extends State<TopAnimationShowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: widget.duration ?? const Duration(seconds: 1));
    _animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.1),
      child: AnimatedBuilder(
        animation: _animation,
        child: Container(child: widget.child),
        builder: (ctx, child) {
          return Transform.translate(
            offset: Offset(0, (_animation.value - 1) * (widget.distanceY)),
            child: child,
          );
        },
      ),
    );
  }
}
