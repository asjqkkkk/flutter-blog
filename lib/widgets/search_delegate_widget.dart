import 'package:flutter/material.dart';
import 'package:flutter_blog/pages/article_page.dart';
import '../config/base_config.dart';
import '../json/article_item_bean.dart';
import '../logic/query_logic.dart';

class SearchDelegateWidget extends SearchDelegate<String> {
  final Map dataMap;
  final logic = QueryLogic();

  SearchDelegateWidget(this.dataMap);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        if (query.isEmpty) {
          close(context, null);
        } else {
          query = '';
          showSuggestions(context);
        }
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Data> showDataList =
        logic.queryArticles(query, Map.from(dataMap));

    return showDataList.isEmpty
        ? const Center(
            child: Text(
              '😅啥也没有...',
              style: TextStyle(fontSize: 30),
            ),
          )
        : Container(
            child: ListView.builder(
              itemCount: showDataList.length,
              itemBuilder: (ctx, index) {
                final Data data = showDataList[index];
                return Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.sort),
                        title: logic.getTitle(data, query),
                        onTap: () {
                          final name = showDataList[index].title;
                          final result = Uri.encodeFull(name);
                          Navigator.of(context).pushNamed(
                            articlePage + '/$result',
                            arguments: ArticleData(
                              index,
                              List.generate(
                                showDataList.length,
                                (index) => ArticleItemBean(
                                  articleName: showDataList[index].title,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Container(
                          width: 2,
                        ),
                        title: logic.getContent(data, query),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 2,
      ),
      title: const Text('输入标题、内容进行搜索吧'),
    );
  }
}
