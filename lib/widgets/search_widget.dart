import 'package:flutter/material.dart';
import 'package:new_web/config/all_configs.dart';

import '../logic/query_logic.dart';
import '../pages/article_page.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({Key? key}) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final logic = QueryLogic();
  String query = '';
  final TextEditingController _controller = TextEditingController();
  Map? dataMap;

  List<Data> get showDataLis => logic.queryArticles(query, dataMap);

  bool get hasData => dataMap != null && dataMap!.isNotEmpty;

  @override
  void initState() {
    loadArticles(returnAll: true).then((value) {
      dataMap = Map.from(value);
      refresh();
    });
    _controller.addListener(() {
      query = _controller.text;
      refresh();
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            alignment: Alignment.topCenter,
            width: size.width,
            height: size.height,
            child: Container(
              margin: EdgeInsets.fromLTRB(0, v100, 0, 0),
              width: size.width / 2 < 300 ? 300 : size.width / 2,
              height: showDataLis.isEmpty ? 150 : size.height - 200,
              alignment: Alignment.topCenter,
              child: Card(
                color: Theme.of(context).cardColor.withOpacity(0.9),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: v30, right: v30),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: '输入标题、内容进行搜索吧',
                          hintStyle: CTextStyle(
                            fontSize: v18,
                            color: color12,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      height: v2,
                      margin: EdgeInsets.only(left: v30, right: v30),
                      color: color12,
                    ),
                    Expanded(child: getLoadingWidget(showDataLis)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLoadingWidget(List<Data> showDataList) {
    if (query.isEmpty)
      return Center(
        child: Icon(
          Icons.article,
          size: v30,
          color: color12,
        ),
      );
    if (showDataList.isEmpty)
      return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(v20),
        child: Text(
          '啥也没有...',
          style: TextStyle(fontSize: v30),
        ),
      );
    else
      return ListView.builder(
        itemCount: showDataList.length,
        itemBuilder: (ctx, index) {
          final Data data = showDataList[index];
          return Container(
            margin: EdgeInsets.only(top: v20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.sort, size: v26),
                  title: logic.getTitle(data, query),
                  onTap: () {
                    RouteConfig.instance.push(RouteConfig.article,
                        arguments: ArticleArg(data.id, data.path));
                  },
                ),
                ListTile(
                  leading: Container(width: v2),
                  title: logic.getContent(data, query),
                ),
              ],
            ),
          );
        },
      );
  }
}
