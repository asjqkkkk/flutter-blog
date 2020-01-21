import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';

class ArticlePageLogic{

  Future<String> getText(String fileName) async{
    String json = await rootBundle.loadString('assets/markdowns/$fileName');
    return json;
  }
}