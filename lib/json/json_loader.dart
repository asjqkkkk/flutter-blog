import 'package:flutter/services.dart';
import 'dart:convert';

Future<dynamic> loadJsonFile(String jsonName) async {
  final url = 'assets/json/$jsonName.json';
  final result = await rootBundle.loadString(url);
  return jsonDecode(result);
}
