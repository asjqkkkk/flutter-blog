import 'dart:convert';
import 'dart:io';

import 'package:flutter_blog/json/article_item_bean.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

void main() {



  Map<String, dynamic> toStringMap(ArticleItemBean bean) {
    return {
      '\"articleName\"': "\"${bean.articleName ?? ""}\"",
      '\"createTime\"': "\"${bean.createTime ?? ""}\"",
      '\"lastModifiedTime\"': "\"${bean.lastModifiedTime ?? ""}\"",
      '\"tag\"': "\"${bean.tag ?? ""}\"",
      '\"summary\"': "\"${bean.summary ?? ""}\"",
      '\"imageAddress\"': "\"${bean.imageAddress ?? ""}\"",
      '\"articleAddress\"': "\"${bean.articleAddress ?? ""}\""
    };
    //把list转换为string的时候不要直接使用tostring，要用jsonEncode
  }


  void printFiles(String markdownFilePath){

    final current = Directory.current;
    final assetPath = Directory(current.path + "/assets/markdowns/$markdownFilePath/");
    final dirs = assetPath.listSync();
    final List<ArticleItemBean> beans = [];

    for (FileSystemEntity dir in dirs) {
      final file = File(dir.path);
      String fileName = path.basename(file.path);
      String name = fileName.substring(0,fileName.indexOf("."));
      String createTime = file.lastModifiedSync().toIso8601String();
      String imageAdress;
      String tag;
      final lastEditTime = file.lastModifiedSync().toIso8601String();

      final content = file.readAsStringSync();
      List<String> splits = content.split("---");
      String subContent;
      if(splits.length == 1){
        subContent = content.trim();
      } else if(splits.length == 3) {
        subContent = splits[2].trim();
        List<String> infos = splits[1].split("\n");
        for (var info in infos) {
          if(info.contains("date:")){
            String date = info.substring(info.indexOf("date: ") + 6);
            DateTime formatDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(date);
            createTime = formatDate.toIso8601String();
          }
          if(info.contains("index_img:")){
            imageAdress = info.substring(info.indexOf("img: ") + 5).trim();
          }
          if(info.contains("tags:")){
            tag = info.substring(info.indexOf("tags: ") + 6).trim();
          }
        }
      }
      subContent = subContent.substring(0, subContent.length > 50 ? 50 : subContent.length);
      final bean = ArticleItemBean(
        articleName: name,
        createTime: createTime,
        lastModifiedTime: lastEditTime,
        tag: tag,
        summary: subContent.replaceAll("#", ""),
        imageAddress: imageAdress,
        articleAddress: "/markdowns/$markdownFilePath/$fileName",
        articleContent: content,
      );
      beans.add(bean);
    }
    File file = File("${current.path + "/assets/config/config_$markdownFilePath.json"}");
    if(file.existsSync()){
      file.deleteSync();
    }
    file.createSync();
    final datas = [];
    for (var bean in beans) {
      datas.add(bean.toMap());
    }
    print(datas);
    file.writeAsStringSync(jsonEncode(datas));
    print(file.readAsStringSync());
//    List<Map<String, dynamic>> jsons = List.generate(beans.length, (index){
//      return toStringMap(beans[index]);
//    });
//    print(jsons);
  }


  test('测试文件输出', () {
    printFiles("study");
    printFiles("life");
  });



}
