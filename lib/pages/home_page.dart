import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blog/widgets/web_bar.dart';

import 'article_page.dart';
import '../widgets/artical_item.dart';
import '../widgets/common_layout.dart';

class HolePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final fontSize = width * 30 / 1440;
    final fontSizeByHeight = height * 30 / 1200;
    print("Size:${size.width}   ${size.height}");

    return Scaffold(
      body: CommonLayout(
        child: Stack(
          children: <Widget>[
            WebBar(),
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
                            fontSize: getScaleSizeByHeight(height, 90.0)),
                      ),
                      SizedBox(
                        height: getScaleSizeByHeight(height, 80.0),
                      ),
                      Text(
                        "生活",
                        style: TextStyle(
                            fontSize: fontSizeByHeight,
                            color: Color(0xff9E9E9E)),
                      ),
                      SizedBox(
                        height: getScaleSizeByHeight(height, 80.0),
                      ),
                      Text(
                        "学习",
                        style: TextStyle(
                            fontSize: fontSizeByHeight,
                            color: Color(0xff9E9E9E)),
                      ),
                      SizedBox(
                        height: getScaleSizeByHeight(height, 80.0),
                      ),
                      Text(
                        "游戏",
                        style: TextStyle( fontSize: fontSizeByHeight),
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
                                child: GestureDetector(child: ArticleItem(),onTap: (){
                                  Navigator.of(context).push(new MaterialPageRoute(builder: (ctx){
                                      return ArticlePage();
                                  }));
                                },),
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
    return size * width / 1600;
  }

  double getScaleSizeByHeight(double height, double size) {
    return size * height / 1200;
  }
}
