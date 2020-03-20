import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/base_config.dart';
import 'package:http/http.dart' as http;
import 'pages/all_pages.dart';
import 'pages/home_page.dart';

void main() {
  ///异步加载字体文件
  var fontLoader = FontLoader('huawen_kt');
  fontLoader.addFont(fetchFont());
  fontLoader.load();

  runApp(MyApp());
}

Future<ByteData> fetchFont() async {
  Map map = HashMap<String, String>();
  map['Access-Control-Allow-Origin'] = '';
  final response = await http.get(
    '$baseUrl/blog_config/huawen_kt.ttf',
    headers: map,
  );
  if (response.statusCode == 200) {
    return ByteData.view(response.bodyBytes.buffer);
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load font');
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ///强制横屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    final int curHour = DateTime.now().hour;
    return MaterialApp(
      title: '老晨子的flutter blog',
      theme: ThemeData(
        brightness:
            (curHour > 18 || curHour < 7) ? Brightness.dark : Brightness.light,
      ),
      initialRoute: homePage,
      routes: {
        homePage: (BuildContext context) => HomePage(),
        tagPage: (BuildContext context) => TagPage(),
        archivePage: (BuildContext context) => ArchivePage(),
        linkPage: (BuildContext context) => FriendLinkPage(),
        aboutPage: (BuildContext context) => AboutPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == articlePage) {
          return _pageRoute(ArticlePage(
            articleData: settings.arguments,
          ));
        } else
          return _pageRoute(HomePage());
      },
    );
  }

  MaterialPageRoute _pageRoute(Widget widget) {
    return MaterialPageRoute(builder: (ctx) => widget);
  }
}
