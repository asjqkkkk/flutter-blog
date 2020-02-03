import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'pages/home_page.dart';

const bool inProduction = const bool.fromEnvironment("dart.vm.product");

void main() {

  if(inProduction){
    ///异步加载字体文件
    var fontLoader = FontLoader('huawen_kt');
    fontLoader.addFont(fetchFont());
    fontLoader.load();
  }

  runApp(MyApp());




}

Future<ByteData> fetchFont() async {
  Map map = HashMap<String,String>();
  map["Access-Control-Allow-Origin"] = "";
  final response = await http.get(
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

    return MaterialApp(
      title: 'old🍊blog',
      theme: ThemeData(fontFamily: "huawen_kt"),
      home: HomePage(),
    );
  }
}
