import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:new_web/config/path_config.dart';
import 'package:new_web/json/all_jsons.dart';
import 'package:path/path.dart' as path;
import 'package:path/path.dart' as p;

import 'file_util.dart';

class ArticleGenerator extends Generator {
  @override
  Future generatorJsonFile() async {
    ///key为文章id，value为文章内容
    final Map<String, String> result = {};

    ///key为文章所在path最后的路径，作为分类，value为路径
    final Map<String, String> pathCollection = {};
    final current = Directory.current;
    final assetPath = Directory(p.join(current.path, 'temp', 'input'));
    if (!assetPath.existsSync()) assetPath.createSync(recursive: true);
    final List<ArticleItemBean> beans = [];
    final Set<String> idSet = {};
    assetPath.listSync().forEach((fileSystemEntity) {
      if (fileSystemEntity is Directory) {
        final res = printFiles(fileSystemEntity, result, pathCollection, idSet);
        if (!fileSystemEntity.path.endsWith('topic')) beans.addAll(res);
      }
    });
    if (beans.isEmpty) {
      print('⚠️:There is no article files!⚠');
      return;
    }

    ///tag分类
    printTagFile(beans);

    ///文章归档
    printArchiveFile(beans);

    ///文章提取
    printAllArticleFile(result);

    ///json文件整合
    printJsonCollectionFile(pathCollection);
  }

  ///将node中的text添加到一起
  String addNodeText(m.Node node, String text) {
    if (node == null) return '';
    if (node is m.Text) {
      return node.text + ' ';
    } else if (node is m.Element) {
      if (node.children == null) return '';
      if (node.tag == 'img' || node.tag == 'a') return '';
      node.children!.forEach((n) {
        text += addNodeText(n, '');
      });
    }
    return text;
  }

  ///将文章列表按年份排序
  List<ArchiveItemBean> sortByYear(List<ArticleItemBean> beans) {
    final List<ArchiveItemBean> results = [];
    final map = <int, List<YearBean>>{};
    beans.sort((left, right) => left.compareTo(right));
    for (final bean in beans) {
      final data = DateTime.parse(bean.createTime!);
      if (map[data.year] == null) {
        map[data.year] = [YearBean.fromItemBean(bean)];
      } else {
        map[data.year]!.add(YearBean.fromItemBean(bean));
      }
    }
    for (final year in map.keys) {
      final ArchiveItemBean articleItemYearBean =
          ArchiveItemBean(year: year, beans: map[year]);
      results.add(articleItemYearBean);
    }
    return results;
  }

  ///将文章列表按照标签排序
  List<ArchiveItemBean> sortByTag(List<ArticleItemBean> beans) {
    final List<ArchiveItemBean> results = [];
    final map = HashMap<String?, List<YearBean>>();
    for (final bean in beans) {
      final tag = bean.tag;
      if (tag?.isEmpty ?? true) continue;
      if (map[tag] == null) {
        map[tag] = [YearBean.fromItemBean(bean)];
      } else {
        map[tag]!.add(YearBean.fromItemBean(bean));
      }
    }
    for (final tag in map.keys) {
      final tagItemBean = ArchiveItemBean(tag: tag, beans: map[tag]);
      results.add(tagItemBean);
    }
    return results;
  }

  List<ArticleItemBean> printFiles(
    Directory markdownFilePath,
    Map<String, String> result,
    Map<String, String> pathCollection,
    Set<String> idSet,
  ) {
    final dirs = markdownFilePath.listSync();
    final lastPathName = markdownFilePath.path.split(p.separator).last;
    final List<ArticleItemBean> beans = [];

    for (final FileSystemEntity dir in dirs) {
      final file = File(dir.path);
      if (!file.path.endsWith('.md')) continue;
      final fileName = path.basename(file.path);
      final name = fileName.substring(0, fileName.indexOf('.'));
      String createTime = file.lastModifiedSync().toIso8601String();
      String? imageAddress;
      String? tag;
      final lastEditTime = file.lastModifiedSync().toIso8601String();

      final content = file.readAsStringSync();
      String subContent;
      if (!content.startsWith('---')) {
        subContent = content.trim();
        editMarkdown(file, content, data: createTime);
      } else {
        final index = content.indexOf('---', 2);
        subContent = content.substring(index, content.length);
        final List<String> infos =
            content.substring(0, index).split('---')[1].split('\n');
        for (final info in infos) {
          if (info.contains('date:')) {
            final date = info.substring(info.indexOf('date: ') + 6);
            final formatDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(date);
            createTime = formatDate.toIso8601String();
          }
          if (info.contains('index_img:')) {
            imageAddress = info.substring(info.indexOf('img: ') + 5).trim();
          }
          if (info.contains('tags:')) {
            tag = info.substring(info.indexOf('tags: ') + 6).trim();
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
      String sub = '';
      nodes.forEach((element) {
        sub += addNodeText(element, '');
      });
      sub = sub.substring(0, sub.length > 100 ? 100 : sub.length);
      final id = generatorId(lastPathName + name, 0, 8, idSet);
      final bean = ArticleItemBean(
        articleName: name,
        articleId: id,
        createTime: createTime,
        lastModifiedTime: lastEditTime,
        tag: tag,
        summary: sub,
        imageAddress: imageAddress,
        articlePath: lastPathName,
        articleAddress: FileUtils().getAssetFile(file.path),
      );
      beans.add(bean);
      result[id] = content;
    }
    beans.sort((left, right) => left.compareTo(right));
    final file = File(p.join(FileUtils().getJsonDir().path,
        '${PathConfig.article}_$lastPathName.json'));
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync();
    final datas = [];
    for (final bean in beans) {
      datas.add(bean.toMap());
    }
    file.writeAsStringSync(jsonEncode(datas));
    print('🎈:Json file has been created successfully!🎈 ------: ${file.path}');
    pathCollection[lastPathName] = FileUtils().getAssetFile(file.path);
    return beans;
  }

  void printTagFile(List<ArticleItemBean> beans) {
    final file = File(
        p.join(FileUtils().getJsonDir().path, '${PathConfig.articleTag}.json'));
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync();
    final tagBeans = sortByTag(beans);
    final tagDatas = [];
    for (final bean in tagBeans) {
      tagDatas.add(bean.toMap());
    }
    file.writeAsStringSync(jsonEncode(tagDatas));
    print('🎈:Json file has been created successfully!🎈 ------: ${file.path}');
  }

  void printArchiveFile(List<ArticleItemBean> beans) {
    final file = File(
        p.join(FileUtils().getJsonDir().path, '${PathConfig.articleTag}.json'));
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync();
    final archiveBeans = sortByYear(beans);
    final archiveDatas = [];
    for (final bean in archiveBeans) {
      archiveDatas.add(bean.toMap());
    }
    file.writeAsStringSync(jsonEncode(archiveDatas));
    print('🎈:Json file has been created successfully!🎈 ------: ${file.path}');
  }

  void printAllArticleFile(Map<String, String> map) {
    final file = File(
        p.join(FileUtils().getJsonDir().path, '${PathConfig.articleAll}.json'));
    if (!file.existsSync()) file.createSync();
    file.writeAsStringSync(jsonEncode(map));
    print('🎈:Json file has been created successfully!🎈 ------: ${file.path}');
  }

  void printJsonCollectionFile(Map<String, String> map) {
    final file = File(p.join(
        FileUtils().getJsonDir().path, '${PathConfig.articleCollection}.json'));
    if (!file.existsSync()) file.createSync();
    file.writeAsStringSync(jsonEncode(map));
    print('🎈:Json file has been created successfully!🎈 ------: ${file.path}');
  }

  String getHeader({String? title, required String date, String? indexImg, String? tags}) {
    const newLine = '\r\n';
    String result = '---$newLine';
    result += 'title: $title$newLine';
    result += 'date: ${_generateData(date)}$newLine';
    if (indexImg != null) result += 'index_img: $indexImg$newLine';
    if (tags != null) result += 'tags: $tags$newLine';
    result += '---$newLine';
    return result;
  }

  String _generateData(String iso8601String) {
    final time = DateTime.parse(iso8601String);
    return DateFormat('yyyy-MM-dd hh:mm:ss').format(time);
  }

  String generatorId(String input, int start, int end, Set<String> idSet) {
    String id = generateMd5(input).substring(start, end);
    if (idSet.contains(id) && end <= 32) {
      id = generatorId(input, start, end + 1, idSet);
    } else
      idSet.add(id);
    return id;
  }

  void editMarkdown(File file, String content, {String? data}) {
    final fileName = p.basename(file.path);
    final title = fileName.substring(0, fileName.indexOf('.'));
    final head =
        getHeader(title: title, date: data ?? DateTime.now().toIso8601String());
    file.writeAsStringSync(head + content);
  }
}

String generateMd5(String input) {
  return crypto.md5.convert(utf8.encode(input)).toString();
}

void main() {
  test('测试文章文件输出', () async {
    await ArticleGenerator().generatorJsonFile();
  });
}
