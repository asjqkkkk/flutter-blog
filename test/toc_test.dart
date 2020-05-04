import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main(List<String> argument) {
  print('参数:$argument');
  test('测试TOC目录生成', () {
    final current = Directory.current;
    File file = File(
        p.join(current.path, 'config', 'markdowns', 'study', 'Handler源码分析.md'));
    final data = file.readAsStringSync();
    print(data.split('\n'));
  });
}
