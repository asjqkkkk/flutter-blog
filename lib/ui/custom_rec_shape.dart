import 'dart:math';

import 'package:flutter/material.dart';

class CusRecShape extends CustomPainter {
  CusRecShape({
    this.borderRadius = 4,
    this.color = Colors.grey,
    this.lineWidth,
    this.lineHeight,
    this.radius = 12,
  });

  final double borderRadius;
  final Color color;
  final double? lineWidth;
  final double? lineHeight;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
    final lw = lineWidth ?? w * 0.36;
    final lh = lineHeight ?? h / 3;

    final Path path = Path();
    path.moveTo(0, lh);
    path.lineTo(0, radius);
    // path.moveTo(radius, radius);

    final rect =
        Rect.fromCircle(center: Offset(radius, radius), radius: radius);
    path.arcTo(rect, pi, pi / 2, true);
    path.lineTo(lw, 0);

    path.moveTo(w, h - lh);
    path.lineTo(w, h - radius);
    final rect2 =
        Rect.fromCircle(center: Offset(w - radius, h - radius), radius: radius);
    path.arcTo(rect2, 0, pi / 2, true);
    path.lineTo(w - lw, h);

    if (size.width == 0 || size.height == 0) {
      canvas.drawPath(Path(), paint);
    } else
      canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
