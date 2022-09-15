import 'dart:math';

import 'package:flutter/material.dart';

class AutoRotateWidget extends StatefulWidget {
  const AutoRotateWidget({
    Key? key,
    required this.child,
    this.callBack,
  }) : super(key: key);
  final Widget child;
  final AnimationCallBack? callBack;

  @override
  _AutoRotateWidgetState createState() => _AutoRotateWidgetState();
}

class _AutoRotateWidgetState extends State<AutoRotateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 30));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    widget.callBack?._initial(start, stop);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(AutoRotateWidget oldWidget) {
    widget.callBack?._initial(start, stop);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.callBack?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void stop() => _controller.stop(canceled: false);

  void start() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (ctx, child) {
        final angle = 2 * pi * _animation.value;
        return Transform.rotate(
          angle: angle,
          child: child,
          origin: Offset.zero,
        );
      },
    );
  }
}

class AnimationCallBack {
  VoidCallback? _startCallback;
  VoidCallback? _stopCallback;

  void _initial(VoidCallback startCallback, VoidCallback stopCallback) {
    _startCallback = startCallback;
    _stopCallback = stopCallback;
  }

  void dispose() {
    _startCallback = null;
    _stopCallback = null;
  }

  void onStartCall() {
    _startCallback?.call();
  }

  void onStopCall() {
    _stopCallback?.call();
  }
}
