import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_web/config/path_config.dart';

import '../json/all_jsons.dart';

class GlobalData {
  GlobalData._privateConstructor();

  static final GlobalData _instance = GlobalData._privateConstructor();

  static GlobalData get instance => _instance;

  ValueNotifier<List<GameScreenData>?> gameScreenData = ValueNotifier(null);

  ValueNotifier<List<OneLineData>?> oneLineData = ValueNotifier(null);

  ValueNotifier<List<FriendLinkBean>?> friendData = ValueNotifier(null);

  ///key为分类的名字，如：life、study
  ValueNotifier<Map<String, List<ArticleItemBean>>?> articleData =
      ValueNotifier(null);

  ///key为articleId
  final Map<String?, ArticleItemBean> _articleMap = {};

  final globalKey = GlobalKey<NavigatorState>();

  BuildContext? get context => globalKey.currentContext;

  Future _initialGameScreens() async {
    final data = await loadJsonFile(PathConfig.gameScreenPath);
    final value = GameScreenData.fromMapList(data);
    gameScreenData.value = value;
  }

  Future _initialOneLine() async {
    final data = await loadJsonFile(PathConfig.oneLinePath);
    final value = OneLineData.fromMapList(data);
    oneLineData.value = value;
  }

  Future _initFriendData() async {
    final data = await loadJsonFile(PathConfig.friend);
    final value = FriendLinkBean.fromMapList(data);
    friendData.value = value;
  }

  Future _initArticleData() async {
    final Map collectionData = await loadJsonFile(PathConfig.articleCollection);
    final Map<String, List<ArticleItemBean>> articleMap = {};
    await Future.forEach(collectionData.keys, (dynamic key) async {
      final value = collectionData[key];
      final result = await rootBundle.loadString(value);
      final articleData = jsonDecode(result);
      articleMap[key] = ArticleItemBean.fromMapList(articleData, path: key);
    });
    if (articleMap.isNotEmpty) articleData.value = articleMap;
  }

  void addToArticleMap(ArticleItemBean bean) {
    _articleMap[bean.articleId] = bean;
  }

  ArticleItemBean? getArticleBean(String id) => _articleMap[id];

  void initialData() {
    _initialGameScreens();
    _initialOneLine();
    _initFriendData();
    _initArticleData();
  }
}

Future<dynamic> loadJsonFile(String jsonName) async {
  final url = 'assets/jsons/$jsonName.json';
  final result = await rootBundle.loadString(url);
  return jsonDecode(result);
}
