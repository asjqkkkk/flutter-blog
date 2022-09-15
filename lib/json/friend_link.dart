class FriendLinkBean {
  FriendLinkBean({
    this.linkName,
    this.linkAddress,
    this.profession,
    this.linkAvatar,
    this.assetAvatar,
    this.id,
  });

  String? linkName;
  String? linkAddress;
  String? linkAvatar;
  String? assetAvatar;
  String? profession;
  String? id;

  static FriendLinkBean? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    return FriendLinkBean(
      linkName: map['linkName'],
      linkAddress: map['linkAddress'],
      profession: map['profession'],
      linkAvatar: map['linkAvatar'],
      assetAvatar: map['assetAvatar'],
      id: map['id'],
    );
  }

  Map toJson() => {
        'linkName': linkName,
        'linkAddress': linkAddress,
        'profession': profession,
        'linkAvatar': linkAvatar,
        'assetAvatar': assetAvatar,
        'id': id
      };

  static List<FriendLinkBean> fromMapList(dynamic mapList) {
    final List<FriendLinkBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      final data = fromMap(mapList[i]);
      if(data != null) list.add(data);
    }
    return list;
  }
}
