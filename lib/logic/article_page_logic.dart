import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';

class ArticlePageLogic{

  Future<String> getText(String fileName) async{
    String file = "assets/markdowns/$fileName";
    String json = await rootBundle.loadString(file);
    return json;
  }
}