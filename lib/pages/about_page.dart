import 'dart:ui';

import 'package:flutter/material.dart';
import '../widgets/hover_tap_image.dart';
import '../widgets/common_layout.dart';
import '../widgets/web_bar.dart';
import 'dart:html' as html;

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      body: CommonLayout(
        pageType: PageType.about,
        child: Container(
          alignment: Alignment.center,
          child: Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                    top: 80, left: width / 10, right: width / 10),
                child: Card(
                  margin: EdgeInsets.only(bottom: 0),
                  child: Container(
                    margin: EdgeInsets.only(top: 80),
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overScroll) {
                        overScroll.disallowGlow();
                        return true;
                      },
                      child: ListView(
                        padding: EdgeInsets.all(20),
                        children: <Widget>[
                          Center(
                            child: Text(
                              "Designed by Flutter Web",
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Center(
                            child: Text(
                              "宅/游戏/读书/运动/学习",
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  html.window.open(
                                      "https://github.com/asjqkkkk", "github");
                                },
                                child: HoverTapAssetImage(
                                    image: "assets/img/github.png"),
                              ),
                              SizedBox(
                                width: 10,
                              ),
//                              GestureDetector(
//                                onTap: () {
//                                  html.window.open(
//                                      "https://juejin.im/user/5badbff26fb9a05cef173bf0",
//                                      "juejin");
//                                },
//                                child: HoverTapAssetImage(
//                                    image: "assets/img/juejin.png"),
//                              ),
//                              SizedBox(
//                                width: 10,
//                              ),
                              GestureDetector(
                                onTap: () {
                                  html.window.open(
                                      "https://steamcommunity.com/id/JiangHun/",
                                      "steam");
                                },
                                child: HoverTapAssetImage(
                                    image: "assets/img/steam.png"),
                              ),
                            ],
                          ),
                          Container(
                            alignment: Alignment.center,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 40, right: 40, top: 40),
                            child: Text(
                              "这个博客是在过年期间完成的,从广东回到湖北老家,奈何正值肺炎来袭,出门不便,"
                              "百般无聊下用flutter实现了这样一个早就构想好的博客效果\n\n"
                              "目前看来，还只是一个半成品，但对于没有前端技术又想自定义一个博客的人来说,我得到了极大的满足。\n\n"
                              "后续随着flutter web的更新,我也会继续进行博客的完善\n\n"
                              "同时,希望这次疫情早点结束。加油吧！",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 40, right: 60, top: 10),
                            alignment: Alignment.bottomRight,
                            child: Text("--- 2020.2.1 中午"),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 160,
                  height: 160,
                  child: ClipRRect(
                    child: Image.asset(
                      "assets/img/avatar.jpg",
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(80)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
