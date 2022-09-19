class OneLineData {
  OneLineData({
    this.content,
    this.title,
    this.itemContent,
    this.cardInfo,
    this.type = OneLineType.text,
  });

  String? content;
  String? title;
  OneLineType type;
  CardInfo? cardInfo;
  _ItemContent? itemContent;

  Map toJson() => {
        'content': content,
        'title': title,
        'itemContent': itemContent?.toJson(),
        'cardInfo': cardInfo?.toJson(),
        'type': _oneLineTypeToInt(type),
      };

  static OneLineData? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    final content = map['content'];
    final title = map['title'];
    final itemContent = map['itemContent'];
    final cardInfo = CardInfo.fromMap(map['cardInfo']);
    final type = OneLineType.values[map['type'] ?? 0];
    return OneLineData(
      content: content,
      title: title,
      itemContent: _ItemContent.fromJsonByType(type, itemContent),
      cardInfo: cardInfo,
      type: type,
    );
  }

  static List<OneLineData> fromMapList(dynamic mapList) {
    final List<OneLineData> list = [];
    for (int i = 0; i < mapList.length; i++) {
      final data = fromMap(mapList[i]);
      if(data != null) list.add(data);
    }
    return list;
  }
}

abstract class _ItemContent {
  _ItemContent();

  Map toJson();

  static _ItemContent? fromJsonByType(
      OneLineType type, Map<String, dynamic>? map) {
    if (map == null) return null;
    _ItemContent? result;
    switch (type) {
      case OneLineType.text:
        break;
      case OneLineType.poetry:
        result = PoetryItemContent.fromJson(map);
        break;
      case OneLineType.internet:
        result = InternetItemContent.fromJson(map);
        break;
    }
    return result;
  }
}

class PoetryItemContent extends _ItemContent {
  PoetryItemContent(this.author);

  PoetryItemContent.fromJson(Map<String, dynamic> map) {
    author = map['author'];
  }

  String? author;

  @override
  Map toJson() => {'author': author};
}

class InternetItemContent extends _ItemContent {
  InternetItemContent(this.source, this.sourceLink);

  InternetItemContent.fromJson(Map<String, dynamic> map) {
    source = map['source'];
    sourceLink = map['sourceLink'];
  }

  String? source;
  String? sourceLink;

  @override
  Map toJson() => {'source': source, 'sourceLink': sourceLink};
}

class CardInfo {
  CardInfo({
    this.weather,
    this.location,
    this.date,
    this.ipAddress,
  });

  final String? weather;
  final String? location;
  final int? date;
  final String? ipAddress;

  Map toJson() => {
        'weather': weather,
        'location': location,
        'date': date,
        'ipAddress': ipAddress,
      };

  static CardInfo? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    final weather = map['weather'];
    final location = map['location'];
    final date = map['date'];
    final ipAddress = map['ipAddress'];
    return CardInfo(
      weather: weather,
      location: location,
      date: date,
      ipAddress: ipAddress,
    );
  }
}

enum OneLineType {
  text,
  poetry,
  internet,
}

int _oneLineTypeToInt(OneLineType? type) {
  if (type == null) return 0;
  int result = 0;
  switch (type) {
    case OneLineType.text:
      result = 0;
      break;
    case OneLineType.poetry:
      result = 1;
      break;
    case OneLineType.internet:
      result = 2;
      break;
  }
  return result;
}
