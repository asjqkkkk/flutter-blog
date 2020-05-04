import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:markdown/markdown.dart' as m;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('测试markdown', () {
    final current = Directory.current;
    File file = File(
        p.join(current.path, 'config', 'markdowns', 'study', 'Handler源码分析.md'));
    final data = file.readAsStringSync();
    final m.Document document = m.Document(
      extensionSet: m.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
    );
    final List<String> lines = data.split(RegExp(r'\r?\n'));
    final nodes = document.parseLines(lines);
    nodes.forEach((node) {
      if (node is m.Element) {
        print(
            'tag:${node.tag}  chidren:${node.children}  text:${node.textContent}');
      }
    });
  });
}
