import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../config/url_launcher.dart';
import '../widgets/hover_tap_image.dart';
import '../widgets/common_layout.dart';
import '../widgets/web_bar.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isNotMobile = !PlatformType().isMobile();

    return CommonLayout(
      pageType: PageType.about,
      child: Container(
        alignment: Alignment.center,
        child: Stack(
          children: <Widget>[
            Container(
              margin: isNotMobile
                  ? EdgeInsets.only(
                      top: 80, left: width / 10, right: width / 10)
                  : const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Card(
                margin: const EdgeInsets.only(bottom: 0),
                child: Container(
                  margin: EdgeInsets.only(top: isNotMobile ? 80 : 40),
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overScroll) {
                      overScroll.disallowGlow();
                      return true;
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: <Widget>[
                        const SizedBox(
                          height: 5,
                        ),
                        Center(
                          child: Text(
                            "宅/游戏/读书/运动/学习",
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => launchURL('https://github.com/asjqkkkk'),
                              child: const HoverTapImage(
                                  image: "assets/img/github.png"),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () => launchURL('https://steamcommunity.com/id/JiangHun/'),
                              child: const HoverTapImage(
                                  image: 'assets/img/steam.png'),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.center,
                        ),
                        Container(
                          margin: isNotMobile
                              ? EdgeInsets.only(left: 40, right: 40, top: 40)
                              : EdgeInsets.all(5),
                          child: Text(
                            '这个博客是在过年期间完成的,从广东回到湖北老家,奈何正值肺炎来袭,出门不便,'
                            '百般无聊下用flutter实现了这样一个早就构想好的博客效果\n\n'
                            '目前看来，还只是一个半成品，但对于没有前端技术又想自定义一个博客的人来说,我得到了极大的满足。\n\n'
                            '后续随着flutter web的更新,我也会继续进行博客的完善\n\n'
                            '同时,希望这次疫情早点结束。加油吧！',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w100),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 40, right: 60, top: 10),
                          alignment: Alignment.bottomRight,
                          child: Text(
                            '--- 2020.2.1 中午',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w100),
                          ),
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
                      width: isNotMobile ? 160 : 100,
                      height: isNotMobile ? 160 : 100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(isNotMobile ? 80 : 50)),
                          color: Colors.primaries[
                              Random().nextInt(Colors.primaries.length)],
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/img/avatar.jpg',
                            ),
                            fit: BoxFit.cover,
                          )),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
