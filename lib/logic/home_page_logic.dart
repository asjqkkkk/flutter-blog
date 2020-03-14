
import 'dart:convert';

import 'package:flutter_blog/json/article_item_bean.dart';
import 'package:flutter_blog/json/json_loader.dart';

class HomePageLogic{



  Future<List<ArticleItemBean>> getArticleData(String fileName) async{
    final configJson = await loadJsonFile(fileName);
    List<ArticleItemBean> data = ArticleItemBean.fromMapList(configJson);
    return data;
  }

}