import 'dart:convert';

import 'package:flutter/services.dart';

class ArticleItemBean {
  ///文章标题
  String articleName;

  ///创建日期
  String createTime;

  ///修改日期
  String lastModifiedTime;

  ///标签
  String tag;

  ///摘要
  String summary;

  ///图片地址
  String imageAddress;

  ///文章地址
  String articleAddress;

  ArticleItemBean({
    this.articleName,
    this.createTime,
    this.lastModifiedTime,
    this.tag,
    this.summary,
    this.imageAddress,
    this.articleAddress,
  });

  static ArticleItemBean fromMap(Map<String, dynamic> map) {
    ArticleItemBean bean = new ArticleItemBean();
    bean.articleName = map['articleName'];
    bean.createTime = map['createTime'];
    bean.lastModifiedTime = map['lastModifiedTime'];
    bean.tag = map['tag'];
    bean.summary = map['summary'];
    bean.imageAddress = map['imageAddress'];
    bean.articleAddress = map['articleAddress'];
    return bean;
  }


  static List<ArticleItemBean> fromMapList(dynamic mapList) {
    List<ArticleItemBean> list = new List(mapList.length);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }

  static Future<List<ArticleItemBean>> loadAsset() async {
    String json = await rootBundle.loadString('assets/config/config.json');
    return ArticleItemBean.fromMapList(jsonDecode(json));
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'articleName': articleName ?? "",
      'createTime': createTime ?? "",
      'lastModifiedTime': lastModifiedTime ?? "",
      'tag': tag ?? "",
      'summary': summary ?? "",
      'imageAddress': imageAddress ?? "",
      'articleAddress': articleAddress ?? ""
    };
  }


}
