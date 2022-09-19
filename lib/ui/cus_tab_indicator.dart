// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class CusUnderlineTabIndicator extends Decoration {
  const CusUnderlineTabIndicator({
    this.borderSide = const BorderSide(width: 2.0, color: Colors.white),
    this.insets = EdgeInsets.zero,
    this.borderHeight = 2.0,
  });

  final BorderSide borderSide;

  final EdgeInsetsGeometry insets;

  final double borderHeight;

  @override
  Decoration? lerpFrom(Decoration? a, double t) {
    if (a is CusUnderlineTabIndicator) {
      return CusUnderlineTabIndicator(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        insets: EdgeInsetsGeometry.lerp(a.insets, insets, t)!,
        borderHeight: borderHeight,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration? lerpTo(Decoration? b, double t) {
    if (b is CusUnderlineTabIndicator) {
      return CusUnderlineTabIndicator(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        insets: EdgeInsetsGeometry.lerp(insets, b.insets, t)!,
        borderHeight: borderHeight,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  _UnderlinePainter createBoxPainter([VoidCallback? onChanged]) {
    return _UnderlinePainter(this, onChanged, borderHeight);
  }

  Rect _indicatorRectFor(Rect rect, TextDirection textDirection) {
    final Rect indicator = insets.resolve(textDirection).deflateRect(rect);
    return Rect.fromLTWH(
      indicator.left,
      indicator.bottom - borderSide.width,
      indicator.width,
      borderSide.width,
    );
  }

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    return Path()..addRect(_indicatorRectFor(rect, textDirection));
  }
}

class _UnderlinePainter extends BoxPainter {
  _UnderlinePainter(
    this.decoration,
    VoidCallback? onChanged,
    this.borderHeight,
  )   : super(onChanged);

  final CusUnderlineTabIndicator decoration;
  final double borderHeight;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size!;
    final TextDirection textDirection = configuration.textDirection!;
    final Rect indicator = decoration
        ._indicatorRectFor(rect, textDirection)
        .deflate(decoration.borderSide.width / 2.0);
    final Paint paint = decoration.borderSide.toPaint()
      ..strokeCap = StrokeCap.square;
    final path = Path();
    final leftPoint = indicator.bottomLeft;
    final rightPoint = Offset(
        indicator.bottomRight.dx, indicator.bottomRight.dy + borderHeight);
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromPoints(leftPoint, rightPoint),
      Radius.circular(borderHeight / 2),
    ));
    canvas.drawPath(path, paint);
    // canvas.drawLine(indicator.bottomLeft, indicator.bottomRight, paint);
  }
}
