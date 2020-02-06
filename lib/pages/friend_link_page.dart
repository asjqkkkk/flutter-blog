import 'package:flutter/material.dart';
import 'package:flutter_blog/json/friend_link_bean.dart';
import 'package:flutter_blog/widgets/web_bar.dart';
import '../widgets/friend_link_item.dart';
import '../widgets/common_layout.dart';
import '../json/link_item_bean.dart';

class FriendLinkPage extends StatelessWidget {

  final beans = FriendLinkBean().beans;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonLayout(
        pageType: PageType.link,
        child: Container(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overScroll) {
              overScroll.disallowGlow();
              return true;
            },
            child: SingleChildScrollView(
              child: Wrap(
                children: List.generate(beans.length, (index) {
                  return FriendLinkItem(
                    bean: beans[index],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
