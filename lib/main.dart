import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/home_page.dart';

void main(){

  var fontLoader = FontLoader('huawen_kt');
  fontLoader.addFont(fetchFont());
  fontLoader.load();

  runApp(MyApp());




}

Future<ByteData> fetchFont() async {
  final dio = Dio();
  final response = await Dio().get(
      'https://oldchen-blog-1256696029.cos.ap-guangzhou.myqcloud.com/huawen_kt.ttf',
      onReceiveProgress: (int count, int total) {
        print("count:$count   total:$total}");
      });

  if (response.statusCode == 200) {
    return ByteData.view(response.data);
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
      home: HolePage(),
    );
  }
}
