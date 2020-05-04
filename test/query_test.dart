import 'package:flutter_blog/logic/query_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<Data> queryArticles(String query, Map<String, String> dataMap) {
    List<Data> datas = [];
    for (String key in dataMap.keys) {
      final String value = dataMap[key];
      final Data data = Data(title: key);
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
        print('\nindex:$titleIndex   title:$titleList');
      }

      if (contentIndex != -1) {
        final int length = value.length;
        final List<String> contentList = [];
        const int subNum = 40;
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
        print('index:$contentIndex   content:$contentList');
      }

      if (data.titleList != null || data.contentList != null) {
        datas.add(data);
      }
    }
    return datas;
  }

  test('测试搜索', () {
    queryArticles('2019', {'2019总结': '2019'});
    queryArticles('2019', {'2019总结': 'aaaa' + '2019'});
    queryArticles('2019', {'2019总结': 'aaaa' + '2019' + 'bbbb'});
    queryArticles('2019', {'2019总结': 'aaaa' * 40 + '2019'});
    queryArticles('2019', {'2019总结': 'aaaa' * 40 + '2019' + 'bbbb'});
    queryArticles('2019', {'2019总结': 'aaaa' * 40 + '2019' + 'bbbb' * 40});
    queryArticles('2019', {'aaa2019总结': 'aaaa' * 40 + '2019' + 'bbbb' * 40});
  });
}
