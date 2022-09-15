class MusicInfo {
  MusicInfo({
    this.playUrl,
    this.picUrl,
    this.author,
    this.title,
  });

  String? playUrl;
  String? picUrl;
  String? author;
  String? title;

  static MusicInfo? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    return MusicInfo(
      playUrl: map['playUrl'],
      picUrl: map['picUrl'],
      author: map['author'],
      title: map['title'],
    );
  }

  Map toJson() =>
      {'playUrl': playUrl, 'author': author, 'picUrl': picUrl, 'title': title};

  static List<MusicInfo?> fromMapList(dynamic mapList) {
    final List<MusicInfo?> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i]));
    }
    return list;
  }
}
