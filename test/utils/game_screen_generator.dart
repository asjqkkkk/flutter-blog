import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_web/config/path_config.dart';
import 'package:new_web/json/game_item_json.dart';
import 'package:path/path.dart' as p;

import 'file_util.dart';

class GameScreenGenerator extends Generator {
  @override
  Future generatorJsonFile() async {
    final current = Directory.current;
    final screenDirs = await FileUtils().buildDirs([
      PathConfig.assets,
      PathConfig.gameScreenPath,
    ]);
    final Map<String, Map<String, String>> picMaps = {};
    final Map<String, Map<String, String>> thumbPicMaps = {};
    await Future.forEach<Directory>(screenDirs, (dir) {
      final path = dir.path;
      final pathSegments = p.split(path);
      if (path.endsWith(PathConfig.thumbnails)) {
        final dirName = pathSegments[pathSegments.length - 2];
        _buildMaps(dir, current, thumbPicMaps, dirName);
      } else {
        final dirName = pathSegments.last;
        _buildMaps(dir, current, picMaps, dirName);
      }
    });
    final List<GameScreenData> screenData = [];
    thumbPicMaps.forEach((key, value) {
      final valuePic = picMaps[key] ?? {};
      final List<ChildItem> children = [];
      String? gameThumb;
      String? gameBackground;
      valuePic.forEach((key2, value2) {
        final thumbPicPath = value[key2];
        if (key2.contains(PathConfig.gameThumb)) {
          gameThumb = value2;
        } else if (key2.contains(PathConfig.gameBackground)) {
          gameBackground = value2;
        } else
          children.add(ChildItem(thumbPicPath: thumbPicPath, picPath: value2));
      });
      final gameScreenData = GameScreenData(
        gameTitle: key,
        children: children,
        gameBackground: gameBackground,
        gameThumb: gameThumb,
      );
      screenData.add(gameScreenData);
    });
    final jsonMap = screenData.map((e) => jsonEncode(e.toJson())).toList();
    FileUtils().generatorJsonFile(
        jsonMap.toString(), '${PathConfig.gameScreenPath}.json');
  }

  void _buildMaps(Directory dir, Directory current,
      Map<String, Map<String, String>> thumbPicMaps, String dirName) {
    final files = dir.listSync();
    final Map<String, String> filePathMap = {};
    Future.forEach<FileSystemEntity>(files, (file) {
      if (file is File) {
        final list = p.split(file.path.replaceAll(current.path, ''));
        list.removeAt(0);
        final fileName = p.basename(file.path);
        filePathMap[fileName] = list.join('/');
      }
      thumbPicMaps[dirName] = filePathMap;
    });
  }
}
