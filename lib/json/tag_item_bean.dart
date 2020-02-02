import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_blog/json/archive_item_bean.dart';

class TagItemBean{
  String tag;
  List<YearBean> beans;

  TagItemBean({this.tag, this.beans});


  static TagItemBean fromMap(Map<String, dynamic> map) {
    TagItemBean bean = new TagItemBean();
    bean.tag = map['tag'];
    bean.beans = YearBean.fromMapList(map['beans']);
    return bean;
  }

  static List<TagItemBean> fromMapList(dynamic mapList) {
    List<TagItemBean> list = new List(mapList.length);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'tag': tag,
      'beans': List.generate(beans.length, (index){
        return beans[index].toMap();
      })
    };
  }

  static Future<List<TagItemBean>> loadAsset() async {
    String json = await rootBundle.loadString('assets/config/config_tag.json');
    return TagItemBean.fromMapList(jsonDecode(json));
  }



}