import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_blog/json/article_item_bean.dart';
import 'package:flutter_blog/widgets/loading_image.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../widgets/common_layout.dart';
import '../logic/article_page_logic.dart';
import 'dart:html' as html;

class ArticlePage extends StatefulWidget {
  final ArticleItemBean bean;

  const ArticlePage({Key key, @required this.bean}) : super(key: key);

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
    if (splits.length >= 3) {
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
            child: data.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView(
                    children: <Widget>[
                      Container(
                        child: Text(widget.bean.articleName,
                            style: TextStyle(
                                fontFamily: "huawen_kt",
                                fontSize: 40,)),
                        alignment: Alignment.center,
                      ),
                      MarkdownBody(
                        fitContent: false,
                        data: data,
                        selectable: false,
                        onTapLink: (link) {
                          html.window.open(link, link);
                        },
                        styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
                        imageBuilder: (Uri url) {
                          return Container(
                            margin: EdgeInsets.all(10),
                            alignment: Alignment.center,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxHeight: height / 3 * 2,
                                  maxWidth: width / 3 * 2),
                              child: GestureDetector(
                                onTap: () {
                                  html.window.open("$url", "image");
                                },
                                child: Card(
                                  child: Image.network(
                                    "$url",
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        styleSheet: MarkdownStyleSheet(
                            codeblockPadding:
                                EdgeInsets.fromLTRB(10, 20, 10, 20),
                            p: TextStyle(
                              fontSize: 18,
                              color:
                                  Theme.of(context).textTheme.subtitle2.color,
                              fontFamily: "",
                            ),
                            h1: Theme.of(context).textTheme.headline4,
                            h2: Theme.of(context).textTheme.headline3,
                            h3: Theme.of(context).textTheme.headline2,
                            h4: Theme.of(context).textTheme.headline1,
                            blockSpacing: 10),
                      ),
                    ],
                  )),
      ),
    );
  }
}
