import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blog/widgets/artical_item.dart';

class HolePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final fontSize = width * 30 / 1440;
    final fontSizeByHeight = height * 30 / 1024;
    print("Size:${size.width}   ${size.height}");

    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(
            left: 0.07 * width, right: 0.07 * width, top: 0.05 * height),
        child: Stack(
          children: <Widget>[
            Container(
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
                    style: TextStyle(fontFamily: "HuaWen", fontSize: fontSize),
                  ),
                  SizedBox(
                    width: getScaleSizeByWidth(width, 50.0),
                  ),
                  Text(
                    "标签",
                    style: TextStyle(fontFamily: "HuaWen", fontSize: fontSize),
                  ),
                  SizedBox(
                    width: getScaleSizeByWidth(width, 50.0),
                  ),
                  Text(
                    "归档",
                    style: TextStyle(fontFamily: "HuaWen", fontSize: fontSize),
                  ),
                  SizedBox(
                    width: getScaleSizeByWidth(width, 50.0),
                  ),
                  Text(
                    "关于",
                    style: TextStyle(fontFamily: "HuaWen", fontSize: fontSize),
                  ),
                ],
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "我的\n博客",
                        style: TextStyle(
                            fontFamily: "HuaWen",
                            fontSize: getScaleSizeByHeight(height, 90.0)),
                      ),
                      SizedBox(
                        height: getScaleSizeByHeight(height, 80.0),
                      ),
                      Text(
                        "生活",
                        style: TextStyle(
                            fontFamily: "HuaWen",
                            fontSize: fontSizeByHeight,
                            color: Color(0xff9E9E9E)),
                      ),
                      SizedBox(
                        height: getScaleSizeByHeight(height, 80.0),
                      ),
                      Text(
                        "学习",
                        style: TextStyle(
                            fontFamily: "HuaWen",
                            fontSize: fontSizeByHeight,
                            color: Color(0xff9E9E9E)),
                      ),
                      SizedBox(
                        height: getScaleSizeByHeight(height, 80.0),
                      ),
                      Text(
                        "游戏",
                        style: TextStyle(
                            fontFamily: "HuaWen", fontSize: fontSizeByHeight),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                          top: 0.1 * height, left: 0.06 * width),
                      child: NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (overScroll) {
                          overScroll.disallowGlow();
                          return true;
                        },
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Wrap(
                            children: List.generate(20, (index) {
                              return Container(
                                margin: EdgeInsets.fromLTRB(0.02 * width,0.04 * height, 0.02 * width,0.04 * height),
                                child: ArticleItem(),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  double getScaleSizeByWidth(double width, double size) {
    return size * width / 1440;
  }

  double getScaleSizeByHeight(double height, double size) {
    return size * height / 1024;
  }
}
