import 'package:flutter/material.dart';
import 'package:new_web/config/all_configs.dart';
import 'package:new_web/pages/article_page.dart';
import 'package:new_web/pages/home_page.dart';

class RouteConfig {
  RouteConfig._privateConstructor();

  static final RouteConfig _instance = RouteConfig._privateConstructor();

  static RouteConfig get instance => _instance;

  static const String home = '/';
  static const String article = '/article';

  final RouteFactory onGenerateRoute = (setting) {
    final name = setting.name;
    final arguments = setting.arguments;
    Widget page = const HomePage();
    switch (name) {
      case home:
        break;
      case article:
        final args = arguments as ArticleArg?;
        page = ArticlePage(articleArg: args);
        break;
    }
    return MaterialPageRoute(
      settings: setting,
      builder: (ctx) {
        return page;
      },
    );
  };

  Future push(
    String route, {
    Object? arguments,
  }) async {
    return await Navigator.of(GlobalData.instance.context!)
        .pushNamed(route, arguments: arguments);
  }
}
