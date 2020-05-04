import 'package:flutter_test/flutter_test.dart';

void main() {
  test('测试url中文转换', () {
    final name = '2019年终总结';
    final en = Uri.encodeFull(name);
    final de = Uri.decodeFull(en);
    print('转换后:$en     解码后:$de');

    final en2 = Uri.encodeComponent(name);
    final de2 = Uri.decodeComponent(en2);
    print('转换后:$en2     解码后:$de2');
  });
}
