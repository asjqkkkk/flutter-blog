import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart';

String getHeader({String title, String date, String index_img, String tags}) {
  final newLine = '\r\n';
  String result = '---$newLine';
  result += 'title: $title$newLine';
  result += 'date: ${_generateData(date)}$newLine';
  if (index_img != null) result += 'index_img: $index_img$newLine';
  if (tags != null) result += 'tags: $tags$newLine';
  result += '---$newLine';
  return result;
}

String _generateData(String iso8601String) {
  DateTime time = DateTime.parse(iso8601String);
  return DateFormat('yyyy-MM-dd hh:mm:ss').format(time);
}

void editMarkdown(File file, String content, {String data}) {
  String fileName = basename(file.path);
  String title = fileName.substring(0, fileName.indexOf("."));
  String head =
      getHeader(title: title, date: data ?? DateTime.now().toIso8601String());
  file.writeAsStringSync(head + content);
}
