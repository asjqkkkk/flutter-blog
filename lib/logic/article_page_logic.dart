import 'package:flutter/services.dart';

class ArticlePageLogic {
  Future<String> getText(String filePath) async {
    String file = "$filePath";
    String json = await rootBundle.loadString(file);
    return json;
  }
}
