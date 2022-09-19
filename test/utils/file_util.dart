import 'dart:io';
import 'package:new_web/config/path_config.dart';
import 'package:path/path.dart' as p;

class FileUtils {
  factory FileUtils() {
    return _singleton;
  }

  FileUtils._internal();

  static final FileUtils _singleton = FileUtils._internal();

  Future<List<Directory>> buildAssetDirs() async {
    final current = Directory.current;
    final assetPath = Directory(p.join(current.path, PathConfig.assets));
    if (!assetPath.existsSync()) assetPath.createSync(recursive: true);
    final List<Directory> result = [];
    await _traverseDirs(result, assetPath);
    return result;
  }

  Directory getJsonDir() {
    final current = Directory.current;
    final jsonPath = Directory(p.join(
      current.path,
      PathConfig.assets,
      PathConfig.jsons,
    ));
    return jsonPath;
  }

  Future<List<Directory>> buildDirs(List<String> paths) async {
    final current = Directory.current;
    final List<String> copyPath = [];
    copyPath.insert(0, current.path);
    copyPath.insertAll(1, paths);
    final assetPath = Directory(p.joinAll(copyPath));
    if (!assetPath.existsSync()) assetPath.createSync(recursive: true);
    final List<Directory> result = [];
    await _traverseDirs(result, assetPath);
    return result;
  }

  Future _traverseDirs(List<Directory> result, Directory? directory) async {
    if (directory == null) return;
    final dirs = directory.listSync();
    if (dirs.isEmpty) {
      result.add(directory);
      return;
    }
    int fileNum = 0;
    Future.forEach(dirs, (dynamic dir) {
      if (dir is Directory)
        _traverseDirs(result, dir);
      else
        fileNum++;
    });
    if (fileNum != 0) result.add(directory);
  }

  Future autoDeclareAssetPath() async {
    final current = Directory.current;
    final yamlFile = File(p.join(current.path, 'pubspec.yaml'));
    if (!yamlFile.existsSync()) throw 'Can\'t find pubspec.yaml file';
    final data = yamlFile.readAsLinesSync();
    int firstAssetLine = -1;
    int lastAssetLine = -1;
    const assetStart = '   - assets';
    for (var i = 0; i < data.length; ++i) {
      final cur = data[i];
      if (cur.startsWith(assetStart)) {
        if (firstAssetLine < 0) firstAssetLine = i;
        lastAssetLine = i;
      }
    }
    final assetDirs = await buildAssetDirs();
    final assetPaths =
        assetDirs.map((e) => e.path.replaceFirst(current.path, '')).toList();
    final transPaths = assetPaths.map((e) {
      final asset = e.startsWith('/') ? e.replaceFirst('/', '') : e;
      final result =
          '   - ${asset.replaceFirst(r'\', '').replaceAll(r'\', '/')}/';
      return result;
    }).toList();
    if (firstAssetLine < 0 || lastAssetLine < 0) {
      final flutterIndex = data.indexOf('flutter:');
      if (flutterIndex > 0) {
        transPaths.insert(0, '  assets:');
        data.insertAll(flutterIndex + 1, transPaths);
      }
    } else
      data.replaceRange(firstAssetLine, lastAssetLine + 1, transPaths);
    final replaceString = data.map((e) => '$e\n').join();
    replaceString.replaceFirst('\n', '');
    yamlFile.writeAsStringSync(replaceString);
    print('🎈:Declare Assetpath into pubspec.yaml successfully! 🎈');
  }

  Future generatorJsonFile(String json, String name) async {
    final current = Directory.current;
    final assetPath =
        Directory(p.join(current.path, PathConfig.assets, PathConfig.jsons));
    if (!assetPath.existsSync()) assetPath.createSync(recursive: true);
    final file = File(p.join(assetPath.path, name));
    if (!file.existsSync()) file.createSync();
    file.writeAsStringSync(json);
    print('🎈:Json file has been created successfully! 🎈------:${file.path}');
  }

  String getAssetFile(String filePath) {
    final current = Directory.current;
    final list = p.split(filePath.replaceAll(current.path, ''));
    list.removeAt(0);
    return list.join('/');
  }
}

abstract class Generator {
  Future generatorJsonFile();
}
