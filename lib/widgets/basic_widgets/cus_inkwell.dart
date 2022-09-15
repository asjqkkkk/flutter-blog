import 'package:flutter/material.dart';
import 'package:new_web/config/all_configs.dart';

class CusInkWell extends StatelessWidget {
  const CusInkWell({
    Key? key,
    this.onTap,
    this.onTapDown,
    this.borderRadius,
    required this.child,
  }) : super(key: key);

  final GestureTapCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final BorderRadius? borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onTapDown: onTapDown,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      borderRadius: borderRadius ?? BorderRadius.circular(v12),
      child: child,
    );
  }
}
