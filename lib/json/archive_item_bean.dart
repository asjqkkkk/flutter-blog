import 'article_item_bean.dart';

class ArchiveItemBean {
  ArchiveItemBean({this.year, this.beans, this.tag});

  int? year;
  String? tag;
  List<YearBean>? beans;

  static ArchiveItemBean fromMap(Map<String, dynamic> map) {
    final bean = ArchiveItemBean();
    bean.year = map['year'];
    bean.tag = map['tag'];
    bean.beans = YearBean.fromMapList(map['beans']);
    return bean;
  }

  static List<ArchiveItemBean> fromMapList(dynamic mapList) {
    final List<ArchiveItemBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i]));
    }
    return list;
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'year': year,
      'tag': tag,
      'beans': List.generate(beans!.length, (index) {
        return beans![index].toMap();
      })
    };
  }
}

class YearBean {
  YearBean({
    this.articleName,
    this.createTime,
    this.lastModifiedTime,
    this.articleAddress,
    this.articleId,
  });

  ///文章标题
  String? articleName;

  ///创建日期
  String? createTime;

  ///修改日期
  String? lastModifiedTime;

  ///文章地址
  String? articleAddress;

  ///文章id
  String? articleId;

  static YearBean fromMap(Map<String, dynamic> map) {
    final YearBean bean = YearBean();
    bean.articleName = map['articleName'];
    bean.createTime = map['createTime'];
    bean.lastModifiedTime = map['lastModifiedTime'];
    bean.articleId = map['articleId'];
    return bean;
  }

  static List<YearBean> fromMapList(dynamic mapList) {
    final List<YearBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i]));
    }
    return list;
  }

  static YearBean fromItemBean(ArticleItemBean bean) {
    return YearBean(
      articleAddress: bean.articleAddress,
      articleName: bean.articleName,
      createTime: bean.createTime,
      lastModifiedTime: bean.lastModifiedTime,
      articleId: bean.articleId,
    );
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'articleName': articleName ?? '',
      'createTime': createTime ?? '',
      'lastModifiedTime': lastModifiedTime ?? '',
      'articleAddress': articleAddress ?? '',
      'articleId': articleId ?? ''
    };
  }
}
