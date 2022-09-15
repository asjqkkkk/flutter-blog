import 'dart:math';

import 'package:flutter/material.dart';

class RandomSizeUtil {
  factory RandomSizeUtil() {
    _instance ??= RandomSizeUtil._internal();
    return _instance!;
  }

  RandomSizeUtil._internal();

  static RandomSizeUtil? _instance;

  final List<List<Item>> itemList = [];

  bool _hasInitial = false;

  double? initialSize;

  void initial({double? size, int? length, int? maxCount, int? minCount}) {
    if (_hasInitial) return;
    initialSize = size;
    itemList.addAll(
      buildLists(size, length,
          maxCount: maxCount,
          limitTypes: [
            ItemType.ratio,
            ItemType.halfRatio,
            ItemType.specificRatio,
          ],
          limitSpecificRatios: [
            0.25,
            0.35,
            0.45,
            0.55,
          ],
          shuffleList: true,
          minCount: minCount),
    );
    _hasInitial = true;
  }
}

List<Item> generatorSizes(
  double? width, {
  required int maxCount,
  int? minCount = 1,
  ItemType type = ItemType.ratio,
  bool shuffleList = false,
  double? specificRatio,
}) {
  void calculateForRandom(int realCount, double? width, List<Item> result) {
    int count = realCount;
    int randomRest = 100;
    int rest = randomRest;
    while (count > 0) {
      randomRest = count == 1 ? rest : Random().nextInt(rest);
      rest = rest - randomRest;
      final w = width! * (randomRest / 100);
      result.add(Item(w, type: type));
      count--;
    }
  }

  assert(maxCount != null && minCount != null && width != null);
  assert(() {
    final noError = (maxCount >= minCount!) && (minCount >= 0) && (width! >= 0.0);
    if (!noError)
      throw FlutterError(
          '$type    maxCount:$maxCount   minCount:$minCount  width:$width   【Wrong value】');
    return true;
  }());
  final List<Item> result = [];
  if (maxCount == 0) return result;
  final tempCount = 1 + Random().nextInt(maxCount);
  final int? realCount = tempCount < minCount! ? minCount : tempCount;
  final halfWidth = width! / 2;
  if (realCount == 1) {
    result.add(Item(width, isFirst: true, isLast: true, type: type));
    return result;
  }
  switch (type) {
    case ItemType.ratio:
      result.addAll(List.generate(
          realCount!, (index) => Item(width / realCount, type: type)));
      break;
    case ItemType.halfRatio:
      if (realCount! > 1)
        result.addAll(List.generate(realCount - 1,
            (index) => Item(halfWidth / (realCount - 1), type: type)));
      result.insert(0, Item(halfWidth, type: type));
      break;
    case ItemType.halfRandom:
      calculateForRandom(realCount! - 1, halfWidth, result);
      result.insert(0, Item(halfWidth, type: type));
      break;
    case ItemType.random:
      calculateForRandom(realCount!, width, result);
      break;
    case ItemType.specificRatio:
      specificRatio ??= 0.5;
      assert(specificRatio > 0 && specificRatio < 1);
      if (maxCount < 2) {
        result.add(Item(width, type: type, ratio: 1));
      } else {
        result.add(Item(width * specificRatio,
            type: type, ratio: max(specificRatio, 1 - specificRatio)));
        result.add(Item(width * (1 - specificRatio),
            type: type, ratio: max(specificRatio, 1 - specificRatio)));
      }
      break;
  }
  assert(() {
    double sum = 0;
    result.forEach((e) {
      sum += e.itemSize!;
    });
    if (sum.round() != width.round())
      throw FlutterError(
          '$type    count:$realCount   width:$width  result:$result   calculate a wrong result');
    return true;
  }());
  if (shuffleList) result.shuffle();
  result.first.isFirst = true;
  result.last.isLast = true;
  return result;
}

List<List<Item>> buildLists(
  double? width,
  int? length, {
  required int? maxCount,
  int? minCount = 1,
  List<ItemType>? limitTypes,
  bool shuffleList = false,
  List<double>? limitSpecificRatios,
}) {
  final size = length ?? 0;
  final List<List<Item>> results = [];
  if (size <= 0) return results;
  int restSize = size;
  final List<ItemType> types = [];
  final List<double> ratios = [];
  if (limitTypes == null || limitTypes.isEmpty) types.add(ItemType.ratio);
  if (limitSpecificRatios == null || limitSpecificRatios.isEmpty)
    ratios.add(0.5);
  types.addAll(limitTypes ?? []);
  ratios.addAll(limitSpecificRatios ?? []);
  int typeIndex = 0;
  int ratioIndex = 0;
  while (restSize > 0) {
    final realMaxCount = maxCount! > restSize ? restSize : maxCount;
    final int? realMinCount = minCount! > realMaxCount ? realMaxCount : minCount;
    final curType = types[typeIndex % types.length];
    final curRatio = ratios[ratioIndex % ratios.length];
    final list = generatorSizes(
      width,
      maxCount: realMaxCount,
      minCount: realMinCount,
      type: curType,
      shuffleList: shuffleList,
      specificRatio: curRatio,
    );
    results.add(list);
    restSize = restSize - list.length;
    typeIndex++;
    if (curType == ItemType.specificRatio) ratioIndex++;
  }
  return results;
}

ItemType randomType() {
  final random = Random().nextInt(4);
  if (random == 0) return ItemType.random;
  if (random == 1) return ItemType.halfRandom;
  if (random == 2) return ItemType.ratio;
  return ItemType.halfRatio;
}

enum ItemType {
  ratio,
  halfRatio,
  halfRandom,
  random,

  ///only works for two num
  specificRatio,
}

class Item {
  Item(
    this.itemSize, {
    this.isFirst = false,
    this.isLast = false,
    this.ratio,
    required this.type,
  });

  double? itemSize;
  bool isFirst;
  bool isLast;
  ItemType type;
  double? ratio;

  @override
  String toString() {
    return 'Item{itemSize: $itemSize, isFirst: $isFirst, isLast: $isLast, type: $type}';
  }
}
