import 'package:flutter_blog/config/base_config.dart';

import 'link_item_bean.dart';

class FriendLinkBean {
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
        linkDescription: ["前端开发", "权限洁癖", "有一说一", "猛男落泪", "掌握对象高级编程"],
        linkAvatar:
            "https://avatars2.githubusercontent.com/u/21327913?s=460&v=4"),
    LinkItemBean(
        linkName: "公瑾的博客",
        linkAddress: "https://www.yuque.com/levy/blog",
        linkDescription: ["大佬", "我不要你觉得", "东野圭吾爱好者", "一开始，我是拒绝的"],
        linkAvatar:
            "https://avatars3.githubusercontent.com/u/9384365?s=460&v=4"),
    LinkItemBean(
        linkName: "senfangblog",
        linkAddress: "https://senfangblog.cn/",
        linkDescription: ["和平主义者", "后端开发", "摸鱼宗师", "王者手速"],
        linkAvatar: "$baseUrl/senfangblog.jpeg"),
    LinkItemBean(
        linkName: "EVILLT的博客",
        linkAddress: "https://evila.me/#/",
        linkDescription: ["哲学大师", "有猫", "前端开发", "Github社区爱好者"],
        linkAvatar:
            "https://avatars2.githubusercontent.com/u/19513289?s=460&v=4"),
    LinkItemBean(
        linkName: "老涛子的博客",
        linkAddress: "http://www.sporoka.com/",
        linkDescription: [
          "有猫",
          "前端开发",
          "新晋渣男",
          "狮子狗",
        ],
        linkAvatar: "$baseUrl/old_tao.jpg"),
  ];
}
