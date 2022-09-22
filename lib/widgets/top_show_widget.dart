import 'dart:async';

import 'package:flutter/material.dart';

class TopAnimationShowWidget extends StatefulWidget {
  const TopAnimationShowWidget(
      {required this.builder, this.duration});

  final Duration? duration;
  final VWidgetBuilder<FutureCallback> builder;

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
        vsync: this, duration: widget.duration ?? const Duration(milliseconds: 800));
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
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      color: Colors.black.withOpacity(0.1),
      child: AnimatedBuilder(
        animation: _animation,
        child: Container(child: widget.builder.call(context, () async{
          return await _controller.reverse();
        })),
        builder: (ctx, child) {
          return Transform.translate(
            offset: Offset(0, (_animation.value - 1) * (size.height)),
            child: child,
          );
        },
      ),
    );
  }
}

typedef VWidgetBuilder<T> = Widget Function(BuildContext context, T value);
typedef FutureCallback = Future<void> Function();
