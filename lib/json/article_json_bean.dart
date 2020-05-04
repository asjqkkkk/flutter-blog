import 'dart:convert';

import 'package:flutter/services.dart';

class ArticleJson {
  factory ArticleJson() {
    return _singleton;
  }

  ArticleJson._internal();

  static final ArticleJson _singleton = ArticleJson._internal();

  static dynamic articles;

  static bool _isLoading = false;

  static Future<dynamic> loadArticles() async {
    if (articles != null) return articles;
    if (!_isLoading) {
      _isLoading = true;
      final result = await rootBundle.loadString('assets/json/config_all.json');
      _isLoading = false;
      return json.decode(result);
//      final Response response = await http.get(
//        '$baseUrl/blog_config/config_all.json',
//        headers: {'Access-Control-Allow-Origin':''},
//      );
//      _isLoading = false;
//      return json.decode(utf8.decode(response.bodyBytes));
    }
  }
}
