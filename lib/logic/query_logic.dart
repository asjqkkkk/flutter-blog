import 'package:flutter/material.dart';
import 'package:new_web/config/all_configs.dart';

class QueryLogic {
  List<Data> queryArticles(String query, Map? dataMap) {
    if (query.isEmpty) return [];
    final List<Data> dataList = [];
    for (final key in dataMap!.keys) {
      final String value = _filterString(dataMap[key]);
      final bean = GlobalData.instance.getArticleBean(key)!;
      final title = bean.articleName!;
      final Data data = Data(
        title: title,
        content: value.trim(),
        id: bean.articleId,
        path: bean.articlePath,
      );
      final int titleIndex = title.indexOf(query);
      final int contentIndex = value.indexOf(query);
      if (titleIndex != -1) {
        final int length = title.length;
        final List<String> titleList = [];
        titleList.add(title.substring(0, titleIndex));
        titleList.add(title.substring(titleIndex, titleIndex + query.length));
        if (titleIndex + query.length < length) {
          titleList.add(title.substring(titleIndex + query.length, length));
        }
        data.titleList = titleList;
      }

      if (contentIndex != -1) {
        final int length = value.length;
        final List<String> contentList = [];
        const int subNum = 50;
        final int start = contentIndex - subNum;
        final int end = contentIndex + subNum + query.length;
        if (start > 0) {
          contentList.add('...');
          contentList.add(value.substring(start, contentIndex));
        } else {
          contentList.add(value.substring(0, contentIndex));
        }
        contentList
            .add(value.substring(contentIndex, contentIndex + query.length));

        if (end < length) {
          contentList.add(value.substring(contentIndex + query.length, end));
          contentList.add('...');
        } else {
          contentList.add(value.substring(contentIndex + query.length, length));
        }
        data.contentList = contentList;
      }

      if (data.titleList != null || data.contentList != null) {
        dataList.add(data);
      }
    }
    return dataList;
  }

  String _filterString(String content) {
    final splits = content.split('---');
    if (splits.length >= 3) {
      return splits[2];
    } else {
      return content;
    }
  }

  Widget getTitle(Data data, String query) {
    if (data.titleList != null)
      return Text.rich(
        TextSpan(
          children: List.generate(
            data.titleList!.length,
            (index) {
              final text = data.titleList![index];
              return TextSpan(
                text: text,
                style: CTextStyle(
                    color: text == query ? Colors.redAccent : null,
                    fontSize: v14),
              );
            },
          ),
        ),
        style: CTextStyle(fontWeight: FontWeight.bold, fontSize: v14),
      );
    else
      return Text(
        data.title!,
        style: CTextStyle(fontWeight: FontWeight.bold, fontSize: v14),
      );
  }

  Widget getContent(Data data, String query) {
    if (data.contentList != null)
      return Text.rich(
        TextSpan(
          children: List.generate(
            data.contentList!.length,
            (index) {
              final String text = data.contentList![index];
              return TextSpan(
                  text: text,
                  style: CTextStyle(
                    color: text == query ? Colors.redAccent : null,
                    fontSize: v14,
                  ));
            },
          ),
        ),
      );
    else
      return Text(subStringText(data.content!));
  }

  String subStringText(String content) {
    return content.length > 100 ? content.substring(0, 100) : content;
  }
}

class Data {
  Data({this.title, this.content, this.id, this.path});

  String? id;
  String? path;
  String? title;
  List<String>? titleList;
  List<String>? contentList;
  String? content;
}
