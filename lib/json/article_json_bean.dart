import 'dart:convert';

import 'package:flutter/services.dart';

class ArticleJson {

  factory ArticleJson() {
    return _singleton;
  }

  ArticleJson._internal();

  static final ArticleJson _singleton = ArticleJson._internal();

  static dynamic articles;

  static Future<dynamic> loadArticles() async{
    if(articles != null) return articles;
    String json = await rootBundle.loadString('assets/config/config_all.json');
    articles = jsonDecode(json);
    return articles;
  }
}