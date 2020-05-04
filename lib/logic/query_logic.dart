import 'package:flutter/material.dart';

class QueryLogic {
  List<Data> queryArticles(String query, Map<String, String> dataMap) {
    if (query.isEmpty) return [];
    List<Data> datas = [];
    for (String key in dataMap.keys) {
      final String value = _filterString(dataMap[key]);
      final Data data = Data(title: key, content: value.trim());
      final int titleIndex = key.indexOf(query);
      final int contentIndex = value.indexOf(query);
      if (titleIndex != -1) {
        final int length = key.length;
        final List<String> titleList = [];
        titleList.add(key.substring(0, titleIndex));
        titleList.add(key.substring(titleIndex, titleIndex + query.length));
        if (titleIndex + query.length < length) {
          titleList.add(key.substring(titleIndex + query.length, length));
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
        datas.add(data);
      }
    }
    return datas;
  }

  String _filterString(String content) {
    List<String> splits = content.split('---');
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
            data.titleList.length,
            (index) {
              final text = data.titleList[index];
              return TextSpan(
                text: text,
                style: TextStyle(
                  color: text == query ? Colors.redAccent : null,
                ),
              );
            },
          ),
        ),
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    else
      return Text(
        data.title,
        style: TextStyle(fontWeight: FontWeight.bold),
      );
  }

  Widget getContent(Data data, String query) {
    if (data.contentList != null)
      return Text.rich(
        TextSpan(
          children: List.generate(
            data.contentList.length,
            (index) {
              final String text = data.contentList[index];
              return TextSpan(
                  text: text,
                  style: TextStyle(
                      color: text == query ? Colors.redAccent : null));
            },
          ),
        ),
      );
    else
      return Text(subStringText(data.content));
  }

  String subStringText(String content) {
    return content.length > 100 ? content.substring(0, 100) : content;
  }
}

class Data {
  Data({this.title, this.content});

  String title;
  List<String> titleList;
  List<String> contentList;
  String content;
}
