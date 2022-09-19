class FontBean {

  FontBean({required this.family, required this.fonts});
  factory FontBean.fromJson(Map<String, dynamic> json) {
    return FontBean(
      family: json['family'],
      fonts: json['fonts'] != null
          ? (json['fonts'] as List).map((i) => Font.fromJson(i)).toList()
          : null,
    );
  }

  static List<FontBean> fromMapList(dynamic mapList) {
    final List<FontBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(FontBean.fromJson(mapList[i]));
    }
    return list;
  }

  final String family;
  final List<Font>? fonts;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['family'] = family;
    data['fonts'] = fonts?.map((v) => v.toJson()).toList();
    return data;
  }
}

class Font {
  Font({required this.asset});

  factory Font.fromJson(Map<String, dynamic> json) {
    return Font(
      asset: json['asset'],
    );
  }

  String asset;

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    data['asset'] = asset;
    return data;
  }
}
