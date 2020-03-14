import 'package:flutter_blog/config/base_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<dynamic> loadJsonFile(String jsonName) async {
  final url = '$baseUrl/blog_config/$jsonName.json';
  final http.Response response = await http.get(
    url,
    headers: {'Access-Control-Allow-Origin': ''},
  );
//  final dio = Dio();
//  final data = await dio.get(url, options: Options(headers: {'Access-Control-Allow-Origin': ''},));
  return jsonDecode(utf8.decode(response.bodyBytes));
}
