import 'dart:ui';
import 'dart:math';

import '../widgets/web_bar.dart';
import '../config/url_launcher.dart';
import 'package:flutter/material.dart';
import '../widgets/common_layout.dart';
import '../widgets/hover_tap_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
                      top: 60, left: width / 10, right: width / 10)
                  : const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Card(
                margin: const EdgeInsets.only(bottom: 0),
                child: Container(
                  margin: EdgeInsets.only(top: isNotMobile ? 60 : 40),
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
                        Center(child: Text("宅/游戏/读书/运动/学习")),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () =>
                                  launchURL('https://github.com/asjqkkkk'),
                              child: const HoverTapImage(
                                  image: "assets/img/github.png"),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () => launchURL(
                                  'https://steamcommunity.com/id/JiangHun/'),
                              child: const HoverTapImage(
                                  image: 'assets/img/steam.png'),
                            ),
                          ],
                        ),
                        Container(
                          margin: isNotMobile
                              ? EdgeInsets.only(left: 40, right: 40, top: 5)
                              : EdgeInsets.all(5),
                          child: Column(
                            children: <Widget>[
                              FlatButton(
                                child: RichText(
                                    text: TextSpan(
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                        ),
                                        children: [
                                      TextSpan(text: '求职中：'),
                                      TextSpan(
                                          text: '📃在线简历',
                                          style: TextStyle(
                                            color: Colors.blue,
                                          )),
                                    ])),
                                onPressed: () => launchURL(
                                    'https://oldchen-blog-1256696029.cos.ap-guangzhou.myqcloud.com/%E7%AE%80%E5%8E%86-2020.pdf'),
                              ),
                              Text('😊有好的内推机会请务必砸向我'),
                              Text('联系方式如下'),
                              Image.asset(
                                'assets/img/wechat.png',
                                width: isNotMobile ? 200 : null,
                              ),
                              FlatButton(
                                child: Text(
                                  'agedchen@gmail.com',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                onPressed: () =>
                                    launchURL('mailto:agedchen@gmail.com'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: isNotMobile ? 120 : 80,
                height: isNotMobile ? 120 : 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(isNotMobile ? 60 : 40)),
                    color: Colors
                        .primaries[Random().nextInt(Colors.primaries.length)],
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/img/head.png',
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

  Shader getShader() => RadialGradient(
          colors: <Color>[randomColor, randomColor],
          center: Alignment.topLeft,
          radius: 1.0,
          tileMode: TileMode.mirror)
      .createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  Color get randomColor =>
      Colors.primaries[Random().nextInt(Colors.primaries.length)];

  TextSpan getSpan(String text) {
    return TextSpan(text: text, style: TextStyle(color: randomColor));
  }
}
