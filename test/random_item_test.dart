import 'package:flutter_test/flutter_test.dart';
import 'package:new_web/util/random_size.dart';

void main() {
  void testFun(int times, int maxCount, double maxWidth, int minCount) {
    ItemType type = ItemType.ratio;
    for (var i = 0; i < times; ++i) {
      final res = generatorSizes(maxWidth,
          maxCount: maxCount, type: ItemType.ratio, minCount: minCount);
      print('$type    count:${res.length}  $res');
    }
    for (var i = 0; i < times; ++i) {
      type = ItemType.random;
      final res = generatorSizes(maxWidth,
          maxCount: maxCount, type: type, minCount: minCount);
      print('$type    count:${res.length}  $res');
    }
    for (var i = 0; i < times; ++i) {
      type = ItemType.halfRatio;
      final res = generatorSizes(maxWidth,
          maxCount: maxCount, type: type, minCount: minCount);
      print('$type    count:${res.length}  $res');
    }
    for (var i = 0; i < times; ++i) {
      type = ItemType.halfRandom;
      final res = generatorSizes(maxWidth,
          maxCount: maxCount, type: type, minCount: minCount);
      print('$type    count:${res.length}  $res');
    }
    print('\n\n');
  }

  void testFun2(
      int times, int length, int maxCount, double maxWidth, int minCount) {
    ItemType type = ItemType.ratio;
    for (var i = 0; i < times; ++i) {
      final res = buildLists(maxWidth, length,
          maxCount: maxCount, limitTypes: [type], minCount: minCount);
      print('$type    count:${res.length}  $res');
    }
    for (var i = 0; i < times; ++i) {
      type = ItemType.random;
      final res = buildLists(maxWidth, length,
          maxCount: maxCount, limitTypes: [type], minCount: minCount);
      print('$type    count:${res.length}  $res');
    }
    for (var i = 0; i < times; ++i) {
      type = ItemType.halfRatio;
      final res = buildLists(maxWidth, length,
          maxCount: maxCount, limitTypes: [type], minCount: minCount);
      print('$type    count:${res.length}  $res');
    }
    for (var i = 0; i < times; ++i) {
      type = ItemType.halfRandom;
      final res = buildLists(maxWidth, length,
          maxCount: maxCount, limitTypes: [type], minCount: minCount);
      print('$type    count:${res.length}  $res');
    }
    print('\n\n');
  }

  test('item', () {
    testFun(10, 3, 1000, 1);
  });

  test('items', () {
    testFun2(1, 3, 3, 100, 1);
  });

  test('shuffle', () {
    final items = ['1', '2', '3', '4'];
    items.shuffle();
    print(items);
  });

  test('divide', () {
    const i = 11;
    print(i / 2);
  });
}
