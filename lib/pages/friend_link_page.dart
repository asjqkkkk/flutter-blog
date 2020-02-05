import 'package:flutter/material.dart';
import 'package:flutter_blog/widgets/web_bar.dart';
import '../widgets/friend_link_item.dart';
import '../widgets/common_layout.dart';
import '../json/link_item_bean.dart';

class FriendLinkPage extends StatelessWidget {
  final List<LinkItemBean> beans = [
    LinkItemBean(
        linkName: "冷石的博客",
        linkAddress: "https://coldstone.fun/",
        linkDescription: ["前端开发", "顺便写写flutter", "全栈", "炒粉大师！"],
        linkAvatar:
            "https://avatars2.githubusercontent.com/u/18013127?s=460&v=4"),
    LinkItemBean(
        linkName: "ColMugX的博客",
        linkAddress: "https://colmugx.github.io/",
        linkDescription: ["前端开发", "权限洁癖", "有一说一","猛男落泪", "掌握对象高级编程"],
        linkAvatar:
            "https://avatars2.githubusercontent.com/u/21327913?s=460&v=4"),
    LinkItemBean(
        linkName: "公瑾的博客",
        linkAddress: "https://www.yuque.com/levy/blog",
        linkDescription: ["大佬","一开始，我是拒绝的","我不要你觉得","东野圭吾爱好者"],
        linkAvatar:
        "https://avatars3.githubusercontent.com/u/9384365?s=460&v=4"),
    LinkItemBean(
        linkName: "senfangblog",
        linkAddress: "https://senfangblog.cn/",
        linkDescription: ["和平主义者","后端开发","摸鱼宗师","王者手速"],
        linkAvatar:
        "https://oldchen-blog-1256696029.cos.ap-guangzhou.myqcloud.com/senfangblog.jpeg"),
  ];

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
