import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blog/widgets/hover_zoom_widget.dart';

class ArticleItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final cardWidth = 0.185 * width;
    final cardHeight = 0.65 * cardWidth;

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
              child: Image.asset("assets/images/00${Random().nextInt(3) + 1}.png",fit: BoxFit.cover,),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 0.07 * cardWidth,top: 0.015 * height),
          child: Text(
            "老人与海",
            style: TextStyle(
                fontSize: 0.017 * width,
                fontWeight: FontWeight.bold,),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 0.07 * cardWidth),
          child: Text(
            "在山的那边海的那边…",
            style: TextStyle(
              fontSize: 0.014 * width,
              color: Color(0xff8D8D8D),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }
}
