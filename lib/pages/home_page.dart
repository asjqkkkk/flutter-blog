import 'dart:math';

import 'package:flutter/material.dart';
import 'article_page.dart';
import '../json/article_item_bean.dart';
import '../widgets/web_bar.dart';
import '../logic/home_page_logic.dart';
import '../widgets/artical_item.dart';
import '../widgets/common_layout.dart';

class HolePage extends StatefulWidget {
  @override
  _HolePageState createState() => _HolePageState();
}

class _HolePageState extends State<HolePage> {
  final logic = HomePageLogic();

  List<ArticleItemBean> showDataList = [];

  @override
  void initState() {
    logic.getArticleData("config_life.json").then((List<ArticleItemBean> data) {
      showDataList.addAll(data);
      setState(() {});
    });
    super.initState();
  }

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
            SizedBox(
              height: 20,
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
                            fontSize: getScaleSizeByHeight(height, 90.0),
                            fontFamily: "huawen_kt"),
                      ),
                      SizedBox(
                        height: getScaleSizeByHeight(height, 80.0),
                      ),
                      Text(
                        "生活",
                        style: TextStyle(
                          fontSize: fontSizeByHeight,
                        ),
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
                        style: TextStyle(
                          fontSize: fontSizeByHeight,
                          color: Color(0xff9E9E9E),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                          top: 0.1 * height, left: 0.06 * width),
                      child: showDataList.isEmpty
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : NotificationListener<
                              OverscrollIndicatorNotification>(
                              onNotification: (overScroll) {
                                overScroll.disallowGlow();
                                return true;
                              },
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Wrap(
                                  children: List.generate(showDataList.length,
                                      (index) {
                                    return Container(
                                      margin: EdgeInsets.fromLTRB(
                                          0.02 * width,
                                          0.04 * height,
                                          0.02 * width,
                                          0.04 * height),
                                      child: GestureDetector(
                                        child: ArticleItem(
                                            bean: showDataList[index]),
                                        onTap: () {
                                          Navigator.of(context).push(
                                              new MaterialPageRoute(
                                                  builder: (ctx) {
                                            return ArticlePage(
                                              bean: showDataList[index],
                                            );
                                          }));
                                        },
                                      ),
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
