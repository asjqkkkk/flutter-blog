import 'package:flutter/material.dart';
import 'package:new_web/config/all_configs.dart';
import 'package:new_web/config/values.dart';

import '../all_widgets.dart';

Widget buildEmptyLayout({double? size, double? strokeWidth}) => Center(
      child: SizedBox(
        width: size ?? v40,
        height: size ?? v40,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth ?? v10,
        ),
      ),
    );

Widget buildShimmer(double width, double height) {
  return Shimmer(
    baseColor: Colors.grey,
    highlightColor: Colors.white,
    // duration: const Duration(seconds: 3),
    child: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(color: Colors.grey)),
  );
}
