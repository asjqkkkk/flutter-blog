import 'package:flutter/material.dart';

class EmptyCircleShape extends CustomPainter {
  EmptyCircleShape({
    this.isLeft = true,
    this.emptyCircleRadius = 0,
    this.borderRadius = 0,
    this.color = Colors.black,
  });

  final bool isLeft;
  final double emptyCircleRadius;
  final double borderRadius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final circlePath = Path();
    if (!isLeft) {
      circlePath
        ..addOval(Rect.fromCircle(
            center: Offset(0, h / 2), radius: emptyCircleRadius))
        ..close();
    } else {
      circlePath
        ..addOval(Rect.fromCircle(
            center: Offset(w, h / 2), radius: emptyCircleRadius))
        ..close();
    }
    final recPath = Path();
    if (isLeft) {
      recPath.addRRect(RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, size.width, size.height),
        bottomLeft: Radius.circular(borderRadius),
        topLeft: Radius.circular(borderRadius),
      ));
    } else {
      recPath.addRRect(RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, size.width, size.height),
        topRight: Radius.circular(borderRadius),
        bottomRight: Radius.circular(borderRadius),
      ));
    }
    final path = Path.combine(
      PathOperation.difference,
      recPath,
      circlePath,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class InvertedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()
        ..addOval(Rect.fromCircle(
            center: Offset(size.width - 44, size.height - 44), radius: 40))
        ..close(),
    );
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
