import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../widgets/common_layout.dart';
import '../widgets/web_bar.dart';
import '../logic/article_page_logic.dart';

class ArticlePage extends StatefulWidget {
  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final logic = ArticlePageLogic();
  String data = "";

  @override
  void initState() {
    logic.getText("001.md").then((v) {
      setState(() {
        data = v;
      });
    });
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
        child: Stack(
          children: <Widget>[
            WebBar(),
            Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 0.1 * height),
                child: ListView(
                  children: <Widget>[
                    Container(
                      child: Text(
                        "我是标题",
                        style: theme.textTheme.display2,
                      ),
                      alignment: Alignment.center,
                    ),
                    data.isEmpty
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : MarkdownBody(
                            fitContent: false,
                            data: data,
                      styleSheet: MarkdownStyleSheet(
                        codeblockPadding: EdgeInsets.fromLTRB(10, 20, 10, 20)
                      ),
                          ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
