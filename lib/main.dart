import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/app_routers.dart';
import 'config/base_config.dart';
import 'package:http/http.dart' as http;
import 'pages/all_pages.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main() {
  ///异步加载字体文件
  var fontLoader = FontLoader('huawen_kt');
  fontLoader.addFont(fetchFont());
  fontLoader.load();

  runApp(ModularApp(module: AppModule(),));
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


