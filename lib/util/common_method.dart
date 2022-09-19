import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

ImageProvider buildResizeImage(
  ImageProvider image, {
  num? w,
  num? h,
}) {
  if (w == null || h == null) return image;
  return ResizeImage(image, width: w.toInt(), height: h.toInt());
}

bool get isWindows =>
    defaultTargetPlatform == TargetPlatform.windows && !kIsWeb;


String getDate(DateTime time) {
  final month = time.month;
  final day = time.day;
  final year = time.year;
  return '$month月$day日 $year';
}

String getTime(DateTime time) {
  return DateFormat('HH:mm:ss').format(time);
}