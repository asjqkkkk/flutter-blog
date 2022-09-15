import 'dart:math';

import 'package:flutter/material.dart';

Color get randomColor =>
    Colors.accents[Random().nextInt(Colors.accents.length)];

const color1 = Color(0xffD8D8D8);
const color2 = Color(0xff1F1F24);
const color3 = Color(0xff5A7588);
const color4 = Color(0xff546BFF);
const color5 = Color(0xff6F8393);
const color6 = Color(0xffECF0F3);
const color7 = Color(0xffCFD8FF);
const color8 = Color(0xffF4F7F9);
const color9 = Color(0xff3D5CE3);
const color10 = Color(0xff607B8B);
const color11 = Color(0xffF2F4F8);
const color12 = Color(0xff909FAE);
const color13 = Color(0xffF1F5EC);
const color14 = Color(0xffD57474);
const color15 = Color(0xffF4F5EE);
const color16 = Color(0xff245160);
const color17 = Color(0xff878B90);
const color18 = Color(0xff3BC3F3);
const color19 = Color(0xff3E3E40);
const color20 = Color(0xffC8986F);
const color21 = Color(0xffE9A56A);
const color22 = Color(0xffCACBD3);
const color23 = Color(0xff8C8D92);
const color24 = Color(0xff656B76);
const color25 = Color(0xff88B17C);
const color26 = Color(0xff899284);

const colors1 = [Color(0xff009000), Color(0xff71DA05)];
const colors2 = [Color(0xff021E49), Color(0xff0097BC)];
const colors3 = [Color(0xffBE2D1B), Color(0xffFFA095)];
const colors4 = [Color(0xff424242), Color(0xff8F8F8F)];
const colors5 = [Color(0xff133B88), Color(0xff50A9F7)];
const colors6 = [Color(0xff095A9D), Color(0xff41D0FD)];

final boxShadows = [
  BoxShadow(
      color: const Color(0xffE2E5E9).withOpacity(0.45),
      offset: const Offset(0, -2),
      blurRadius: 10),
  BoxShadow(
      color: const Color(0xffE2E5E9).withOpacity(0.45),
      offset: const Offset(0, 20),
      blurRadius: 16,
      spreadRadius: 5),
];

final boxShadows2 = [
  BoxShadow(
      color: const Color(0xff000000).withOpacity(0.25),
      offset: const Offset(2, 4),
      blurRadius: 20),
];

const Gradient cusGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xff9AB0C3),
      Color(0xffB2C4D0),
    ]);
