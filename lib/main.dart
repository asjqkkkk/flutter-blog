import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blog/config/platform.dart';
import 'package:flutter_blog/pages/about_page.dart';
import 'package:flutter_blog/pages/archive_page.dart';
import 'package:flutter_blog/pages/friend_link_page.dart';
import 'package:flutter_blog/pages/tag_page.dart';
import 'package:http/http.dart' as http;
import 'pages/home_page.dart';


void main() {
//  if(inProduction){
//    ///异步加载字体文件
//    var fontLoader = FontLoader('huawen_kt');
//    fontLoader.addFont(fetchFont());
//    fontLoader.load();
//  }

  runApp(MyApp());
}

Future<ByteData> fetchFont() async {
  Map map = HashMap<String, String>();
  map['Access-Control-Allow-Origin'] = '';
  final http.Response response = await http.get(
    'https://oldchen-blog-1256696029.cos.ap-guangzhou.myqcloud.com/huawen_kt.ttf',
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
      title: 'old🍊blog',
      theme: ThemeData(
          brightness: (curHour > 18 || curHour < 7)
              ? Brightness.dark
              : Brightness.light),
      initialRoute: '/home',
      routes: {
        '/home': (BuildContext context) => HomePage(),
        "/tag": (BuildContext context) => TagPage(),
        '/archive': (BuildContext context) => ArchivePage(),
        "/link": (BuildContext context) => FriendLinkPage(),
        "/about": (BuildContext context) => AboutPage(),
      },
      home: HomePage(),
    );
  }
}
