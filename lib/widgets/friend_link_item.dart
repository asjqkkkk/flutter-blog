import 'dart:math';

import 'package:flutter/material.dart';
import '../json/link_item_bean.dart';
import 'dart:html' as html;

class FriendLinkItem extends StatelessWidget {
  final LinkItemBean bean;

  const FriendLinkItem({Key key, @required this.bean}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.only(top: 50),
            child: Card(
              child: Container(
                margin: EdgeInsets.only(top: 50),
                width: 250,
                height: 250,
                child: Container(
                  margin: EdgeInsets.only(bottom: 50),
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overScroll) {
                      overScroll.disallowGlow();
                      return true;
                    },
                    child: ListView(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          alignment: Alignment.center,
                          child: Text(
                            bean.linkName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.all(10),
                            child: Wrap(
                              children: List.generate(
                                  bean.linkDescription.length, (index) {
                                return Container(
                                  margin: EdgeInsets.all(10),
                                  child: Text(bean.linkDescription[index],
                                      style: TextStyle(
                                        fontSize: (Random().nextInt(10) + 10)
                                            .toDouble(),
                                        color: Colors.primaries[Random()
                                            .nextInt(Colors.primaries.length)],
                                      )),
                                );
                              }),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 100,
              height: 100,
              child: ClipRRect(
                child: Image.network(
                  bean.linkAvatar,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(50.0)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: 300),
              child: FlatButton(
                color:
                    Colors.primaries[Random().nextInt(Colors.primaries.length)],
                child: Text("进入博客"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                onPressed: () {
                  html.window.open(bean.linkAddress, bean.linkName);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
