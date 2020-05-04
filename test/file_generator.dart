import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_blog/json/article_item_bean.dart';
import 'package:flutter_blog/json/archive_item_bean.dart';
import 'package:flutter_blog/json/friend_link_bean.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:markdown/markdown.dart' as m;

import 'package:path/path.dart' as p;

import 'config/generate_head.dart';

void main() {
  ///将node中的text添加到一起
  String addNodeText(m.Node node, String text) {
    if (node == null) return '';
    if (node is m.Text) {
      return node.text + ' ';
    } else if (node is m.Element) {
      if (node.children == null) return '';
      if (node.tag == 'img' || node.tag == 'a') return '';
      node.children.forEach((n) {
        text += addNodeText(n, '');
      });
    }
    return text;
  }

  ///将文章列表按年份排序
  List<ArchiveItemBean> sortByYear(List<ArticleItemBean> beans) {
    List<ArchiveItemBean> results = [];
    final map = LinkedHashMap<int, List<YearBean>>();
    beans.sort((left, right) => left.compareTo(right));
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
  List<ArchiveItemBean> sortByTag(List<ArticleItemBean> beans) {
    List<ArchiveItemBean> results = [];
    final map = HashMap<String, List<YearBean>>();
    for (var bean in beans) {
      final tag = bean.tag;
      if (tag?.isEmpty ?? true) continue;
      if (map[tag] == null) {
        map[tag] = [YearBean.fromItemBean(bean)];
      } else {
        map[tag].add(YearBean.fromItemBean(bean));
      }
    }
    for (var tag in map.keys) {
      ArchiveItemBean tagItemBean = ArchiveItemBean(tag: tag, beans: map[tag]);
      results.add(tagItemBean);
    }
    return results;
  }

  List<ArticleItemBean> printFiles(
      String markdownFilePath, String dirPath, Map<String, String> result) {
    final current = Directory.current;
    final assetPath = Directory(
        p.join(current.path, '$dirPath', 'markdowns', '$markdownFilePath'));
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
      String subContent;
      if (!content.startsWith('---')) {
        subContent = content.trim();
        editMarkdown(file, content, data: createTime);
      } else {
        final index = content.indexOf('---', 2);
        subContent = content.substring(index, content.length);
        List<String> infos =
            content.substring(0, index).split('---')[1].split("\n");
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
          0, subContent.length > 100 ? 100 : subContent.length);
      final m.Document document = m.Document(
        extensionSet: m.ExtensionSet.gitHubFlavored,
        encodeHtml: false,
      );
      final nodes = document.parseLines(subContent.split(RegExp(r'\r?\n')));
      String sub = "";
      nodes.forEach((m.Node element) {
        sub += addNodeText(element, '');
      });
      sub = sub.substring(0, sub.length > 50 ? 50 : sub.length);
      final bean = ArticleItemBean(
        articleName: name,
        createTime: createTime,
        lastModifiedTime: lastEditTime,
        tag: tag,
        summary: sub,
        imageAddress: imageAdress,
        articleAddress: '$dirPath/markdowns/$markdownFilePath/$fileName',
      );
      beans.add(bean);
      result[name] = content;
    }
    beans.sort((left, right) => left.compareTo(right));
    File file = File(p.join(
        current.path, 'assets', 'json', 'config_$markdownFilePath.json'));
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync();
    final datas = [];
    for (var bean in beans) {
      datas.add(bean.toMap());
    }
    file.writeAsStringSync(jsonEncode(datas));
    return beans;
  }

  void printTagFile(List<ArticleItemBean> beans) {
    final current = Directory.current;

    File file = File(p.join(current.path, 'assets', 'json', 'config_tag.json'));
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync();
    List<ArchiveItemBean> tagBeans = sortByTag(beans);
    final tagDatas = [];
    for (var bean in tagBeans) {
      tagDatas.add(bean.toMap());
    }
    file.writeAsStringSync(jsonEncode(tagDatas));
  }

  void printFontFile(List<ArticleItemBean> beans) {
    final current = Directory.current;
    File file =
        File(p.join(current.path, 'config', 'fontData', 'config_font.json'));
    if (file.existsSync()) {
      file.deleteSync();
    }
    if (!file.parent.existsSync()) {
      file.parent.createSync();
    }
    file.createSync();
    String result = '我的博客 首页 标签 归档 友链 关于 学习 生活 习题 进入博客';
    for (var bean in beans) {
      result += bean.articleName;
      result += bean.tag ?? '';
    }

    for (var bean in FriendLinkBean().beans) {
      result += bean.linkName;
      for (var des in bean.linkDescription) {
        result += des;
      }
    }
//    result.replaceAll(RegExp(r'\d'), "").replaceAll(RegExp('[a-zA-Z]'), "");
    file.writeAsStringSync(result);
  }

  void printArchiveFile(List<ArticleItemBean> beans) {
    final current = Directory.current;
    File file =
        File(p.join(current.path, 'assets', 'json', 'config_archive.json'));
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

  void printAllArticleFile(Map<String, String> map) {
    final current = Directory.current;
    File file = File(p.join(current.path, 'assets', 'json', 'config_all.json'));
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync();
    file.writeAsStringSync(jsonEncode(map));
  }

  test('测试文件输出', () {
    final Map<String, String> result = {};
    final List<ArticleItemBean> topicBeans =
        printFiles("topic", "config", result);
    final List<ArticleItemBean> lifeBeans = printFiles(
      "life",
      "config",
      result,
    );
    final List<ArticleItemBean> studyBeans =
        printFiles("study", "config", result);
    List<ArticleItemBean> tagBeans = [];
    tagBeans.addAll(lifeBeans);
    tagBeans.addAll(studyBeans);

    ///tag分类
    printTagFile(tagBeans);
    tagBeans.addAll(topicBeans);

    ///字体截取
    printFontFile(tagBeans);

    ///文章归档
    List<ArticleItemBean> archiveBeans = [];
    archiveBeans.addAll(lifeBeans);
    archiveBeans.addAll(studyBeans);
    printArchiveFile(archiveBeans);

    ///文章提取
    printAllArticleFile(result);
  });

  //运行命令，编译文件：flutter test test/file_generator.dart
}
