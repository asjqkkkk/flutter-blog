import 'dart:math';
import 'dart:ui';

import 'dart:html' as html;
import 'package:flutter/cupertino.dart';
import 'package:flutter_blog/config/markdown_toc.dart';
import 'package:flutter_blog/widgets/chewie_video_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog/widgets/toc_widget.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../json/article_item_bean.dart';
import '../json/article_json_bean.dart';
import '../widgets/common_layout.dart';
import '../logic/article_page_logic.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:html/dom.dart' as dom;

class ArticlePage extends StatefulWidget {
  final ArticleData articleData;
  final String name;

  const ArticlePage({Key key, this.articleData, @required this.name}) : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final logic = ArticlePageLogic();
  String markdownData = '';
  String htmlData = '';
  bool showHtml = false;
  final _scrollController = ScrollController();
  ArticleItemBean bean;
  ArticleData articleData;

  @override
  void initState() {
    final name = Uri.decodeFull(widget.name);
    print('获取到的name:${widget.name}   转换后的name:$name');
    if(widget.articleData == null){
      bean = ArticleItemBean(articleName: name);
      articleData = ArticleData(0, [bean]);
    } else {
      bean = widget.articleData.dataList[widget.articleData.index];
      articleData = widget.articleData;
    }
    loadArticle(bean);
    super.initState();
  }


  void loadArticle(ArticleItemBean bean) {
    ArticleJson.loadArticles().then((value) {
      final String content = value[bean.articleName];
      List<String> splits = content.split('---');
      if (splits.length >= 3) {
        markdownData = splits[2];
      } else {
        markdownData = content;
      }
      if (markdownData.contains('<video')) {
        htmlData = md.markdownToHtml(markdownData);
        showHtml = true;
      } else {
        showHtml = false;
      }
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isNotMobile = !PlatformDetector().isMobile();

    return CommonLayout(
      pageType: PageType.article,
      child: Container(
          alignment: Alignment.center,
          margin:
              isNotMobile ? const EdgeInsets.all(0) : const EdgeInsets.all(20),
          child: markdownData.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overScroll) {
                    overScroll.disallowGlow();
                    return true;
                  },
                  child: isNotMobile
                      ? getWebLayout(width, articleData, height, context)
                      : getMobileLayout(width, height, bean),
                )),
    );
  }

  Widget getWebLayout(double width, ArticleData articleData, double height,
      BuildContext context) {
    final bean = articleData.dataList[articleData.index];
    final isDark = Theme.of(context).brightness == Brightness.dark ? true : false;

    return Container(
        margin: EdgeInsets.only(top: 20),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(20, 50, 10, 50),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Text(
                        '文章目录:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: ListView.builder(
                          itemCount: articleData.dataList.length,
                          itemBuilder: (ctx, index) {
                            final data = articleData.dataList[index];
                            return Container(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(5, 10, 6, 10),
                                  child: Text(
                                    data.articleName,
                                    style: TextStyle(
                                        color: index == articleData.index
                                            ? Colors.green
                                            :  (isDark ? Colors.grey : null),
                                        fontSize: 14,
                                        fontFamily: 'huawen_kt'),
                                  ),
                                ),
                                onTap: () {
                                  articleData.index = index;
                                  loadArticle(articleData.dataList[index]);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: getBodyCard(bean, height, width, context, false),
              flex: 3,
            ),
            Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(top: 50, left: 20),
                        child: IconButton(
                          icon: Transform.rotate(
                            child: Icon(
                              Icons.arrow_drop_down_circle,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            angle: pi,
                          ),
                          onPressed: () {
                            _scrollController.animateTo(0.0,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.ease);
                          },
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: TocWidget(
                            nodes: parseToDataList(markdownData),
                            markdownController: _scrollController,
                            useListView: true,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(bottom: 50, left: 20),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_drop_down_circle,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          onPressed: () {
                            _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.ease);
                          },
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ));
  }

  Widget getMobileLayout(double width, double height, ArticleItemBean bean) {
    return Container(
      width: width,
      child: getBodyCard(bean, height, width, context, true),
    );
  }

  Widget getBodyCard(
      ArticleItemBean bean, double height, double width, BuildContext context, bool isMobile) {
    return Card(
      margin: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 4 : 20),
        child: showHtml ? getHtmlBody(height, width) : getMarkdownBody(height, width, context),
      ),
    );
  }

  Widget getHtmlBody(double height, double width) {
    return SingleChildScrollView(
      child: Html(
        data: htmlData,
        useRichText: false,
        onLinkTap: (url) {
          html.window.open('$url', "image");
        },
        onImageTap: (url) {
          html.window.open('$url', "url");
        },
        customRender: (node, children) {
          if (node is dom.Element) {
            switch (node.localName) {
              case "video":
                return Card(
                    child: CheWieVideoWidget(
                  url: node.attributes['src'],
                ));
              case "img":
                return buildImageWidget(height, width, node.attributes['src']);
            }
          }
        },
      ),
    );
  }

  Widget getMarkdownBody(
      double height, double width, BuildContext context) {
    final titleColor = Theme.of(context).textSelectionColor;
    final isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    final codeBgColor = isDark
        ? Color.fromRGBO(85, 85, 85, 1)
        : Color.fromRGBO(246, 248, 250, 1);
    final codeColor = isDark
        ? Colors.grey
        : Color.fromRGBO(58, 60, 70, 1);
    final blockColor = isDark
        ? Color.fromRGBO(100, 100, 100, 1)
        : Color.fromRGBO(113, 123, 138, 1);
    final blockBgColor = isDark
        ? Color.fromRGBO(100, 100, 100, 1)
        : Color.fromRGBO(223, 226, 229, 1);
    final textColor = isDark
        ? Colors.grey
        : Theme.of(context).textTheme.subtitle2.color;

    return Markdown(
      data: markdownData,

      selectable: false,
      controller: _scrollController,
      onTapLink: (link) {
        html.window.open(link, link);
      },
      styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
      imageBuilder: (Uri url) {
        return buildImageWidget(height, width, url.toString());
      },
      styleSheet: MarkdownStyleSheet(
        codeblockPadding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
        p: TextStyle(
          color: textColor,
          fontFamily: "",
        ),
        h1: TextStyle(
            fontSize: 25, fontWeight: FontWeight.bold, color: titleColor),
        h2: TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: titleColor),
        h3: TextStyle(
            fontSize: 19, fontWeight: FontWeight.bold, color: titleColor),
        h4: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: titleColor),
        h5: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: titleColor),
        blockSpacing: 10,
        code: TextStyle(
          fontWeight: FontWeight.w200,
          color: codeColor,
          backgroundColor: codeBgColor,
          fontSize: 13,
        ),
        blockquote: TextStyle(color: blockColor),
        blockquoteDecoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            left: BorderSide(
              color: blockBgColor,
              width: 4,
            ),
          ),
        ),
        codeblockDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            color: codeBgColor),
      ),
    );
  }

  Container buildImageWidget(double height, double width, String url) {
    return Container(
      margin: const EdgeInsets.all(10),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: height / 3 * 2, maxWidth: width / 3 * 2),
        child: GestureDetector(
          onTap: () {
            html.window.open('$url', "image");
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
  }
}

class ArticleData {
  int index;
  List<ArticleItemBean> dataList;

  ArticleData(this.index, this.dataList);
}
