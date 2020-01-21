import 'package:flutter/material.dart';

class WebBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final fontSize = width * 30 / 1440;

    return Container(
      width: size.width - 200.0,
      child: Row(
        children: <Widget>[
          FlutterLogo(
            size: 75.0 * width / 1440,
            colors: Colors.blueGrey,
          ),
          SizedBox(
            width: 30.0,
          ),
          Container(
            height: 50.0,
            width: 3.0,
            color: Color(0xff979797),
          ),
          SizedBox(
            width: 30.0,
          ),
          Text(
            "Flutter",
            style: TextStyle(fontSize: fontSize),
          ),
          Spacer(
            flex: 1,
          ),
          Text(
            "首页",
            style: TextStyle(fontSize: fontSize),
          ),
          SizedBox(
            width: getScaleSizeByWidth(width, 50.0),
          ),
          Text(
            "标签",
            style: TextStyle(fontSize: fontSize),
          ),
          SizedBox(
            width: getScaleSizeByWidth(width, 50.0),
          ),
          Text(
            "归档",
            style: TextStyle(fontSize: fontSize),
          ),
          SizedBox(
            width: getScaleSizeByWidth(width, 50.0),
          ),
          Text(
            "关于",
            style: TextStyle(fontSize: fontSize),
          ),
        ],
      ),
    );
  }

  double getScaleSizeByWidth(double width, double size) {
    return size * width / 1440;
  }
}
