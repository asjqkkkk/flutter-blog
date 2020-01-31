import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';

class ArticlePageLogic{

  Future<String> getText(String filePath) async{
    String file = "assets/$filePath";

//    final ByteData data = await rootBundle.load(file);
//    print("$data");

    String json = await rootBundle.loadString(file);
    return json;
  }
}