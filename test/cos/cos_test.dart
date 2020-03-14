
import 'package:path/path.dart' as p;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'tencent_cos.dart';

void main(){

  test('测试put数据', () async{
    
    TencentCos cos = TencentCos.get();
    final current = Directory.current;
    final configDir = Directory(p.join(current.path,'config','json'));
    final dirs = configDir.listSync();
    for (FileSystemEntity dir in dirs) {
      final file = File(dir.path);
      await cos.putObject('/blog_config/',file);
    }

    File jsFile = File(p.join(current.path, 'build', 'web', 'main.dart.js'));
    await cos.putObject('/blog_config/',jsFile);
  });
}