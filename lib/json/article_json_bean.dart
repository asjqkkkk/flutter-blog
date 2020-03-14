import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_blog/config/base_config.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';


class ArticleJson {

  factory ArticleJson() {
    return _singleton;
  }

  ArticleJson._internal();

  static final ArticleJson _singleton = ArticleJson._internal();

  static dynamic articles;

  static bool _isLoading = false;

  static Future<dynamic> loadArticles() async{
    if(articles != null) return articles;
    if(!_isLoading){
      _isLoading = true;
      final Response response = await http.get(
        '$baseUrl/blog_config/config_all.json',
        headers: {'Access-Control-Allow-Origin':''},
      );
      _isLoading = false;
      return json.decode(utf8.decode(response.bodyBytes));
    }
  }
}