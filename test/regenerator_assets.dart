import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_web/config/all_configs.dart';
import 'package:path/path.dart' as p;

import 'beans/font_bean.dart';

void main() {
  test('修改build产物的json文件', () async {
    final current = Directory.current;
    final fontManifestFile = File(p.join(current.path, PathConfig.build, PathConfig.web, PathConfig.assets, PathConfig.fontManifest));
    if (!fontManifestFile.existsSync()) {
      print('⚠ file:${fontManifestFile.path}  not exist! ⚠');
      return;
    }
    final data = fontManifestFile.readAsStringSync();
    final fb = FontBean.fromMapList(jsonDecode(data));
    final List<Map<String, dynamic>> list = [];
    for (final o in fb) {
      if(o.family != 'siyuan') continue;
      list.add(o.toJson());
    }
    fontManifestFile.writeAsStringSync(jsonEncode(list));
    print('🎈 file:${fontManifestFile.path} was refreshed! 🎈');

  });
}