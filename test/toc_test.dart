import 'dart:io';

import 'package:flutter_blog/config/markdown_toc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;



void main() {

  test('测试TOC目录生成', () {
    final current = Directory.current;
    File file =
        File(p.join(current.path, 'config', 'markdowns', 'study', 'Handler源码分析.md'));
    final data = file.readAsStringSync();
//    print(data.split('\n'));
//    print(getNodes(data).length);
    parseToList(data).forEach((e) => print(e.toString()));
  });
}
