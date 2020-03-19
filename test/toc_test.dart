import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

class TocNode {
  double percent;
  String name;
  int deep;

  TocNode(this.percent, this.name, this.deep);

  @override
  String toString() {
    return 'TocNode{percent: $percent, name: $name, deep: $deep}';
  }
}

enum FilterType { before, start, mid, end }

void main() {
  List<TocNode> getNodes(String input) {
    FilterType type = FilterType.before;
    int deep = 0;
    double percent = 0.0;
    String name = '';
    final List<TocNode> nodes = [];
    for (var i = 0; i < input.length; ++i) {
      var c = input[i];

      if (i == 0 && c == '#') {
        deep++;
        type = FilterType.start;
        continue;
      }

      switch (type) {
        case FilterType.before:
          if (c == '#' &&
              i > 0 &&
              (input[i - 1] == '\r' || input[i - 1] == '\n')) {
            percent = i / input.length;
            deep++;
            type = FilterType.start;
          }
          break;
        case FilterType.start:
          if (c == '#') {
            deep++;
          } else if (c == ' ') {
            type = FilterType.mid;
          } else {
            deep = 0;
            name = '';
            type = FilterType.before;
          }
          break;
        case FilterType.mid:
          if (c == ' ' || c == '\n' || c == '\r') {
            deep = 0;
            name = '';
            type = FilterType.before;
          } else {
            name += c;
            type = FilterType.end;
          }
          break;
        case FilterType.end:
          if ((c == '\n' || c == '\r') && name.isNotEmpty) {
            nodes.add(TocNode(percent, name, deep));
            deep = 0;
            name = '';
            type = FilterType.before;
          } else if ((c == '\n' || c == '\r') && name.isEmpty) {
            deep = 0;
            name = '';
            type = FilterType.before;
          } else {
            name += c;
          }
          break;
      }
    }
    return nodes;
  }

  test('测试TOC目录生成', () {
    final current = Directory.current;
    File file =
        File(p.join(current.path, 'config', 'markdowns', 'study', 'Handler源码分析.md'));
    final data = file.readAsStringSync();
//    print(data.split('\n'));
//    print(getNodes(data).length);
    getNodes(data).forEach((e) => print(e.toString()));
  });
}
