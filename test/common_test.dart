import 'package:flutter_test/flutter_test.dart';
import 'package:new_web/items/one_line_items.dart';

void main() {
  test('queue test', () {
    print(getRandomNumList(0, 0));
    print(getRandomNumList(0, 1));
    print(getRandomNumList(1, 0));
    print(getRandomNumList(1, 1));
    print(getRandomNumList(2, 1));
    print(getRandomNumList(2, 2));
    print(getRandomNumList(3, 1));
    print(getRandomNumList(3, 2));
    print(getRandomNumList(0, 2));
    print(getRandomNumList(10, 3));
    print(getRandomNumList(10, 3));
    print(getRandomNumList(10, 3));
    print(getRandomNumList(10, 3));
  });

  test('add all', () {
    final List<int> list = [];
    list.addAll([1, 2, 3]);
    print(list);
    list.addAll([1, 2, 3]);
    print(list);
  });
}
