import 'package:flutter/material.dart';
import 'package:flutter_blog/json/article_item_bean.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../widgets/common_layout.dart';
import '../logic/article_page_logic.dart';

class ArticlePage extends StatefulWidget {

  final ArticleItemBean bean;

  const ArticlePage({Key key,@required this.bean}) : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final logic = ArticlePageLogic();
  String data = "";

  @override
  void initState() {
//    logic.getText(widget.bean.articleAddress).then((v) {
//      data = v;
//      List<String> splits = data.split("---");
//      if(splits.length == 3){
//        data = splits[2];
//      }
//      setState(() {});
//    });
      List<String> splits = widget.bean.articleContent.split("---");
      if(splits.length >= 3){
        data = splits[2];
      } else {
        data = widget.bean.articleContent;
      }
      setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: CommonLayout(
        child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 70),
            child: data.isEmpty ?Center(
              child: CircularProgressIndicator(),
            ) : ListView(
              children: <Widget>[
                Container(
                  child: Text(
                    widget.bean.articleName,
                    style: theme.textTheme.headline5,
                  ),
                  alignment: Alignment.center,
                ),
                MarkdownBody(
                        fitContent: false,
                        data: data,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                            codeblockPadding:
                                EdgeInsets.fromLTRB(10, 20, 10, 20)),
                      ),
              ],
            )),
      ),
    );
  }
}
