import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import '../json/article_item_bean.dart';
import '../widgets/hover_zoom_widget.dart';
import '../config/platform_type.dart';

class ArticleItem extends StatelessWidget {
  final ArticleItemBean bean;

  const ArticleItem({Key key, @required this.bean}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isNotMobile = !PlatformType().isMobile();
    final cardWidth = isNotMobile
        ? (0.18 * width < 260 ? 260 : 0.18 * width)
        : (width - 100 < 260 ? 260 : width - 80);
    final cardHeight = 0.6 * cardWidth;

    return Column(
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
                    borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                    color: Colors
                        .primaries[Random().nextInt(Colors.primaries.length)],
                  ),
                  child: Container(),
                ),
                Container(
                  alignment: Alignment.center,
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    image: bean.imageAddress.isEmpty
                        ? null
                        : DecorationImage(
                            image: AssetImage('assets${bean.imageAddress}'),
                            fit: BoxFit.cover,
                          ),
                  ),
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
          child: Text(
            bean.articleName,
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'huawen_kt',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        dateWidget(isNotMobile, cardWidth),
        if (isNotMobile)
          Expanded(child: summaryWidget(isNotMobile, cardWidth))
        else
          summaryWidget(isNotMobile, cardWidth),
      ],
    );
  }

  Widget summaryWidget(bool isNotMobile, num cardWidth) {
    return Container(
      margin: EdgeInsets.only(top: 4),
      width: isNotMobile ? 0.86 * cardWidth : 0.95 * cardWidth,
      child: Text(
        bean.summary + '...',
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xff8D8D8D),
        ),
        overflow: TextOverflow.clip,
      ),
    );
  }

  Container dateWidget(bool isNotMobile, num cardWidth) {
    return Container(
      width: isNotMobile ? 0.86 * cardWidth : 0.95 * cardWidth,
      margin: EdgeInsets.only(top: 4),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.date_range,
            color: Color(0xff8D8D8D),
            size: 18,
          ),
          Container(
            margin: EdgeInsets.only(left: 5),
            child: Text(
              getDate(DateTime.parse(bean.createTime)),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xff8D8D8D),
              ),
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

  String getDate(DateTime time) {
    return '${time.year}.${time.month}.${time.day}';
  }
}
