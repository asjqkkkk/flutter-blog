import 'package:new_web/config/all_configs.dart';

import 'archive_item_bean.dart';

class ArticleItemBean extends Comparable {
  ArticleItemBean({
    this.articleName,
    this.createTime,
    this.lastModifiedTime,
    this.tag,
    this.summary,
    this.imageAddress,
    this.articleAddress,
    this.articleId,
    this.articlePath,
//    this.articleContent,
  });

  ///文章标题
  String? articleName;

  ///创建日期
  String? createTime;

  ///修改日期
  String? lastModifiedTime;

  ///标签
  String? tag;

  ///摘要
  String? summary;

  ///图片地址
  String? imageAddress;

  ///文章地址
  String? articleAddress;

  ///文章的分类path
  String? articlePath;

  ///文章id：截取path+文章名的md5前8位
  String? articleId;

  ///文章内容(当flutter修复rootbundle.loadString对于中文的识别问题后再去掉这个)
//  String articleContent;

  static ArticleItemBean fromMap(Map<String, dynamic> map, {String? path}) {
    final bean = ArticleItemBean();
    bean.articleName = map['articleName'];
    bean.createTime = map['createTime'];
    bean.lastModifiedTime = map['lastModifiedTime'];
    bean.tag = map['tag'];
    bean.summary = map['summary'];
    bean.imageAddress = map['imageAddress'];
    bean.articleAddress = map['articleAddress'];
    bean.articleId = map['articleId'];
    bean.articlePath = path ?? map['articlePath'];
//    bean.articleContent = map['articleContent'];
    return bean;
  }

  static List<ArticleItemBean> fromMapList(dynamic mapList, {String? path}) {
    final List<ArticleItemBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      final bean = fromMap(mapList[i], path: path);
      GlobalData.instance.addToArticleMap(bean);
      list.add(bean);
    }
    return list;
  }

  static ArticleItemBean fromYearBean(YearBean bean) {
    return ArticleItemBean(
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
      'tag': tag ?? '',
      'summary': summary ?? '',
      'imageAddress': imageAddress ?? '',
      'articleAddress': articleAddress ?? '',
      'articleId': articleId ?? '',
      'articlePath': articlePath ?? ''
//      'articleContent': articleContent ?? ""
    };
  }

  @override
  int compareTo(other) {
    return DateTime.parse(createTime!).isAfter(DateTime.parse(other.createTime))
        ? -1
        : 1;
  }

  String getDate(DateTime time) {
    final month = time.month;
    final day = time.day < 10 ? '0${time.day}' : time.day;
    final year = time.year;
    return '$month月$day日 $year';
  }

  String getCreateTime() => getDate(DateTime.tryParse(createTime!)!);
}
