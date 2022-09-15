import 'dart:math';

import 'package:flutter/material.dart';

class FlippableBox extends StatelessWidget {
  const FlippableBox({
    Key? key,
    this.isFlipped = false,
    this.front,
    this.back,
    this.clipRadius,
    this.duration = 1,
    this.curve = Curves.easeOut,
    this.flipVt = false,
    this.onEnd,
  }) : super(key: key);

  final double? clipRadius;
  final double duration;
  final Curve curve;
  final bool flipVt;
  final Container? front;
  final Container? back;

  final bool isFlipped;
  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: (duration * 1000).round()),
      curve: Curves.easeOut,
      tween: Tween(begin: 0.0, end: isFlipped ? 180.0 : 0.0),
      builder: (context, dynamic value, child) {
        final content = value >= 90 ? back : front;
        return Rotation3d(
          rotationY: !flipVt ? value : 0,
          rotationX: flipVt ? value : 0,
          child: Rotation3d(
            rotationY: !flipVt ? (value > 90 ? 180 : 0) : 0,
            rotationX: flipVt ? (value > 90 ? 180 : 0) : 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(clipRadius ?? 0),
              child: content,
            ),
          ),
        );
      },
      onEnd: onEnd,
    );
  }
}

class Rotation3d extends StatelessWidget {
  const Rotation3d(
      {Key? key,
      required this.child,
      this.rotationY = 0,
      this.rotationZ = 0,
      this.rotationX})
      : super(key: key);

  static const double degrees2Radians = pi / 180;

  final Widget child;
  final double? rotationX;
  final double rotationY;
  final double rotationZ;

  @override
  Widget build(BuildContext context) {
    return Transform(
        alignment: FractionalOffset.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(rotationX! * degrees2Radians)
          ..rotateY(rotationY * degrees2Radians)
          ..rotateZ(rotationZ * degrees2Radians),
        child: child);
  }
}
