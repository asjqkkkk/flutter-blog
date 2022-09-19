import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'file_util.dart';

class ChineseGenerator extends Generator {
  @override
  Future generatorJsonFile() async {
    final current = Directory.current;
    final assetPath = Directory(p.join(current.path, 'assets'));
    final libPath = Directory(p.join(current.path, 'lib'));
    final List<String> result = [];
    await _traverseDirs(result, assetPath);
    await _traverseDirs(result, libPath);
    String chinese = result.join();
    chinese += '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final outputPath = Directory(p.join(current.path, 'temp', 'output'));
    if (!outputPath.existsSync()) outputPath.createSync(recursive: true);
    final outPutFile = File(p.join(outputPath.path, 'filterChinese.json'));
    if (!outPutFile.existsSync()) outPutFile.createSync();
    outPutFile.writeAsStringSync(chinese);
    print('🎈Chinese text extraction complete! :${outPutFile.path}🎈');
  }

  Future _traverseDirs(List<String> result, Directory? directory) async {
    if (directory == null) return;
    final dirs = directory.listSync();
    if (dirs.isEmpty) return;
    await Future.forEach(dirs, (dynamic dir) {
      if (dir is Directory)
        _traverseDirs(result, dir);
      else if (dir is File &&
          (dir.path.endsWith('json') || dir.path.endsWith('dart'))) {
        final data = dir.readAsStringSync();
        final string = _allStringMatches(data, chineseChar).join();
        result.add(string);
      }
    });
  }

  Iterable<String?> _allStringMatches(String text, RegExp regExp) =>
      regExp.allMatches(text).map((m) => m.group(0));

  final RegExp chineseChar = RegExp(
      r'([\u4e00-\u9fa5]|[\u3002\uff1b\uff0c\uff1a\u201c\u201d\uff08\uff09\u3001\uff1f\u300a\u300b]|[^\x00-\xff])');
}

void main() {
  test('中文提取', () async {
    await ChineseGenerator().generatorJsonFile();
  });
}
