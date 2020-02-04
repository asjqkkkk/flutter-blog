import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_blog/json/article_item_bean.dart';
import 'package:flutter_blog/json/archive_item_bean.dart';
import 'package:flutter_blog/json/tag_item_bean.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

void main() {
  ///将文章列表按年份排序
  List<ArchiveItemBean> sortByYear(List<ArticleItemBean> beans) {
    List<ArchiveItemBean> results = [];
    final map = LinkedHashMap<int, List<YearBean>>();
    for (var bean in beans) {
      final data = DateTime.parse(bean.createTime);
      if (map[data.year] == null) {
        map[data.year] = [YearBean.fromItemBean(bean)];
      } else {
        map[data.year].add(YearBean.fromItemBean(bean));
      }
    }
    for (var year in map.keys) {
      ArchiveItemBean articleItemYearBean =
          ArchiveItemBean(year: year, beans: map[year]);
      results.add(articleItemYearBean);
    }
    return results;
  }

  ///将文章列表按照标签排序
  List<TagItemBean> sortByTag(List<ArticleItemBean> beans){
    List<TagItemBean> results = [];
    final map = HashMap<String, List<YearBean>>();
    for (var bean in beans) {
      final tag = bean.tag;
      if(tag.isEmpty) continue;
      if (map[tag] == null) {
        map[tag] = [YearBean.fromItemBean(bean)];
      } else {
        map[tag].add(YearBean.fromItemBean(bean));
      }
    }
    for (var tag in map.keys) {
      TagItemBean tagItemBean =
      TagItemBean(tag: tag, beans: map[tag]);
      results.add(tagItemBean);
    }
    return results;
  }

  List<ArticleItemBean> printFiles(
    String markdownFilePath,
    String dirPath, {
    bool outputArchivesConfig = false,
  }) {
    final current = Directory.current;
    final assetPath =
        Directory(current.path + "/$dirPath/markdowns/$markdownFilePath/");
    final dirs = assetPath.listSync();
    final List<ArticleItemBean> beans = [];

    for (FileSystemEntity dir in dirs) {
      final file = File(dir.path);
      String fileName = path.basename(file.path);
      String name = fileName.substring(0, fileName.indexOf("."));
      String createTime = file.lastModifiedSync().toIso8601String();
      String imageAdress;
      String tag;
      final lastEditTime = file.lastModifiedSync().toIso8601String();

      final content = file.readAsStringSync();
      List<String> splits = content.split("---");
      String subContent;
      if (splits.length == 1) {
        subContent = content.trim();
      } else if (splits.length >= 3) {
        subContent = splits[2].trim();
        List<String> infos = splits[1].split("\n");
        for (var info in infos) {
          if (info.contains("date:")) {
            String date = info.substring(info.indexOf("date: ") + 6);
            DateTime formatDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(date);
            createTime = formatDate.toIso8601String();
          }
          if (info.contains("index_img:")) {
            imageAdress = info.substring(info.indexOf("img: ") + 5).trim();
          }
          if (info.contains("tags:")) {
            tag = info.substring(info.indexOf("tags: ") + 6).trim();
          }
        }
      }
      subContent = subContent.substring(
          0, subContent.length > 50 ? 50 : subContent.length);
      final bean = ArticleItemBean(
        articleName: name,
        createTime: createTime,
        lastModifiedTime: lastEditTime,
        tag: tag,
        summary: subContent.replaceAll("#", ""),
        imageAddress: imageAdress,
        articleAddress: "/$dirPath/$markdownFilePath/$fileName",
        articleContent: content,
      );
      beans.add(bean);
    }
    beans.sort((left, right) => left.compareTo(right));
    File file = File(
        "${current.path + "/assets/config/config_$markdownFilePath.json"}");
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync();
    final datas = [];
    for (var bean in beans) {
      datas.add(bean.toMap());
    }
    file.writeAsStringSync(jsonEncode(datas));

    if (outputArchivesConfig) {
      File file =
          File("${current.path + "/assets/config/config_archive.json"}");
      if (file.existsSync()) {
        file.deleteSync();
      }
      file.createSync();
      List<ArchiveItemBean> archiveBeans = sortByYear(beans);
      final archiveDatas = [];
      for (var bean in archiveBeans) {
        archiveDatas.add(bean.toMap());
      }
      file.writeAsStringSync(jsonEncode(archiveDatas));
    }

    return beans;
  }

  void printTagFile(List<ArticleItemBean> beans){
    final current = Directory.current;

    File file =
    File("${current.path + "/assets/config/config_tag.json"}");
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync();
    List<TagItemBean> tagBeans = sortByTag(beans);
    final tagDatas = [];
    for (var bean in tagBeans) {
      tagDatas.add(bean.toMap());
    }
    file.writeAsStringSync(jsonEncode(tagDatas));
  }

  test('测试文件输出', () {
    printFiles("topic", "config");
    final lifeBeans = printFiles("life", "config", outputArchivesConfig: true);
    final studyBeans = printFiles("study", "config", outputArchivesConfig: true);
    List<ArticleItemBean> tagBeans = [];
    tagBeans.addAll(lifeBeans);
    tagBeans.addAll(studyBeans);
    printTagFile(tagBeans);
  });
}
