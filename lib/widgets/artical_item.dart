import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import '../json/article_item_bean.dart';
import '../widgets/hover_zoom_widget.dart';
import '../config/platform.dart';

class ArticleItem extends StatelessWidget {
  final ArticleItemBean bean;

  const ArticleItem({Key key, @required this.bean}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isNotMobile = !PlatformDetector().isMobile();
    final cardWidth = isNotMobile
        ? (0.18 * width < 260 ? 260 : 0.18 * width)
        : (width - 100 < 260 ? 260 : width - 80);
    final cardHeight = 0.6 * cardWidth;

    return Container(
      height: cardHeight * 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          HoverZoomWidget(
            child: Container(
              margin: const EdgeInsets.all(10),
              width: cardWidth,
              height: cardHeight,
              child: Stack(
                children: <Widget>[
                  Container(
                    width: cardWidth,
                    height: cardHeight,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30.0)),
                        color: Colors
                            .primaries[Random().nextInt(Colors.primaries.length)],),
                    child: Container(),
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20.0)),
                        image: bean.imageAddress.isEmpty
                            ? null
                            : DecorationImage(
                                image: AssetImage('assets${bean.imageAddress}'),
                                fit: BoxFit.cover,
                              ),),
                    child: bean.imageAddress.isEmpty
                        ? Container(
                            width: cardWidth,
                            height: cardHeight,
                            alignment: Alignment.center,
                            child: Text(
                              'Leecode',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isNotMobile ? 0.02 * width : 30,
                                  color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : Container(),
                  ),
                ],
              ),
            ),
            scale: isNotMobile ? 1.1 : 1.0,
          ),
          Container(
            width: isNotMobile ? 0.86 * cardWidth : 0.95 * cardWidth,
            margin: EdgeInsets.only(
                left: bean.articleName.startsWith(RegExp(r'\d'))
                    ? (isNotMobile ? 0.09 * cardWidth : 0.03 * cardWidth)
                    : (isNotMobile ? 0.07 * cardWidth : 0.02 * cardWidth),
                top: 0.015 * height),
            child: Text(
              bean.articleName,
              style: const TextStyle(
                fontSize: 25,
                fontFamily: 'huawen_kt',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                left: isNotMobile ? 0.07 * cardWidth : 0.02 * cardWidth),
            width: isNotMobile ? 0.86 * cardWidth : 0.95 * cardWidth,
            child: Text(
              bean.summary.replaceAll('\n', ''),
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xff8D8D8D),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }

  MaterialColor priRandomColor() {
    return Colors.primaries[Random().nextInt(Colors.primaries.length)];
  }

  MaterialAccentColor accentRandomColor() {
    return Colors.accents[Random().nextInt(Colors.accents.length)];
  }
}
