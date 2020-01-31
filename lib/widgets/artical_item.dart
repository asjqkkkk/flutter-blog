import 'dart:math';

import 'package:flutter/material.dart';
import '../json/article_item_bean.dart';
import '../widgets/hover_zoom_widget.dart';

class ArticleItem extends StatelessWidget {
  final ArticleItemBean bean;

  const ArticleItem({Key key, @required this.bean}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final cardWidth = 0.18 * width;
    final cardHeight = 0.6 * cardWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        HoverZoomWidget(
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            child: Container(
              width: cardWidth,
              height: cardHeight,
              color: Color(Random().nextInt(0xffffffff)),
              child: bean.imageAddress.isEmpty
                  ? Container(
                      margin: EdgeInsets.all(10),
                      child: Text(
                        bean.articleContent,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : Image.asset(
                      "assets${bean.imageAddress}",
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          scale: 1.1,
        ),
        Container(
          width: 0.86 * cardWidth,
          margin: EdgeInsets.only(left: 0.07 * cardWidth, top: 0.015 * height),
          child: Text(
            bean.articleName,
            style: TextStyle(
              fontSize: 0.015 * width,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 0.07 * cardWidth),
          width: 0.86 * cardWidth,
          child: Text(
            bean.summary.replaceAll("\n", " "),
            style: TextStyle(
              fontSize: 0.012 * width,
              color: Color(0xff8D8D8D),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }
}
