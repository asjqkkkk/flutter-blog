import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_blog/json/article_item_bean.dart';

class ArchiveItemBean {
  int year;
  List<YearBean> beans;

  ArchiveItemBean({this.year, this.beans});

  static ArchiveItemBean fromMap(Map<String, dynamic> map) {
    ArchiveItemBean bean = new ArchiveItemBean();
    bean.year = map['year'];
    bean.beans = YearBean.fromMapList(map['beans']);
    return bean;
  }

  static List<ArchiveItemBean> fromMapList(dynamic mapList) {
    List<ArchiveItemBean> list = new List(mapList.length);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'year': year,
      'beans': List.generate(beans.length, (index){
        return beans[index].toMap();
      })
    };
  }

  static Future<List<ArchiveItemBean>> loadAsset() async {
    String json = await rootBundle.loadString('assets/config/config_archive.json');
    return ArchiveItemBean.fromMapList(jsonDecode(json));
  }

}

class YearBean {
  ///文章标题
  String articleName;

  ///创建日期
  String createTime;

  ///修改日期
  String lastModifiedTime;

  ///文章地址
  String articleAddress;

  YearBean({
    this.articleName,
    this.createTime,
    this.lastModifiedTime,
    this.articleAddress,
  });

  static YearBean fromMap(Map<String, dynamic> map) {
    YearBean bean = new YearBean();
    bean.articleName = map['articleName'];
    bean.createTime = map['createTime'];
    bean.lastModifiedTime = map['lastModifiedTime'];
    return bean;
  }

  static List<YearBean> fromMapList(dynamic mapList) {
    List<YearBean> list = new List(mapList.length);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }

  static YearBean fromItemBean(ArticleItemBean bean){
    return YearBean(
      articleAddress: bean.articleAddress,
      articleName: bean.articleName,
      createTime: bean.createTime,
      lastModifiedTime: bean.lastModifiedTime,
    );
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'articleName': articleName ?? "",
      'createTime': createTime ?? "",
      'lastModifiedTime': lastModifiedTime ?? "",
      'articleAddress': articleAddress ?? ""
    };
  }

}
