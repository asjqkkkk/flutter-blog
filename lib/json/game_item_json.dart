class GameScreenData {
  GameScreenData({
    this.gameTitle = 'Dark Souls',
    this.children,
    this.gameBackground,
    this.gameThumb,
  });

  final String? gameTitle;
  final String? gameBackground;
  final String? gameThumb;
  final List<ChildItem>? children;

  Map toJson() => {
        'gameTitle': gameTitle,
        'gameBackground': gameBackground,
        'gameThumb': gameThumb,
        'children': children?.map((e) => e.toJson()).toList(),
      };

  static GameScreenData? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    final gameTitle = map['gameTitle'];
    final gameBackground = map['gameBackground'];
    final gameThumb = map['gameThumb'];
    final children = (map['children'] as List? ?? [])
        .map((e) => ChildItem.fromMap(e))
        .toList();
    return GameScreenData(
      gameTitle: gameTitle,
      children: children,
      gameBackground: gameBackground,
      gameThumb: gameThumb,
    );
  }

  static List<GameScreenData> fromMapList(dynamic mapList) {
    final List<GameScreenData> list = [];
    for (int i = 0; i < mapList.length; i++) {
      final data = fromMap(mapList[i]);
      if (data != null) list.add(data);
    }
    return list;
  }
}

class ChildItem {
  ChildItem({
    this.type = 0,
    this.extraData,
    this.thumbPicPath,
    this.picPath,
  });

  final int? type;
  final Map? extraData;
  final String? thumbPicPath;
  final String? picPath;

  ChildItemType get itemType => ChildItemType.values[type!];

  Map toJson() => {
        'type': type,
        'extraData': extraData,
        'picPath': picPath,
        'thumbPicPath': thumbPicPath,
      };

  static ChildItem fromMap(Map<String, dynamic> map) {
    final type = map['type'];
    final extraData = map['extraData'];
    final thumbPicPath = map['thumbPicPath'];
    final picPath = map['picPath'];
    return ChildItem(
      type: type,
      extraData: extraData,
      thumbPicPath: thumbPicPath,
      picPath: picPath,
    );
  }
}

enum ChildItemType { image, video, music }
