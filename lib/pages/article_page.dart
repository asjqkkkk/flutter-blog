import 'dart:math';
import 'dart:ui';

import 'dart:html' as html;
import 'package:flutter/cupertino.dart';
import 'package:flutter_blog/widgets/chewie_video_widget.dart';
import 'package:flutter/material.dart';
import '../json/article_item_bean.dart';
import '../json/article_json_bean.dart';
import '../widgets/common_layout.dart';
import '../logic/article_page_logic.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:html/dom.dart' as dom;


class ArticlePage extends StatefulWidget {
  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final logic = ArticlePageLogic();
  String data = '';
  bool hasInitialed = false;
  final _scrollController = ScrollController();

  void loadArticle(ArticleItemBean bean) {
    hasInitialed = true;
    ArticleJson.loadArticles().then((value) {
      final String content = value[bean.articleName];
      List<String> splits = content.split('---');
      if (splits.length >= 3) {
        data = splits[2];
      } else {
        data = content;
      }
      data = md.markdownToHtml(data);
      Future.delayed(Duration(milliseconds: 300), (){
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
    final ArticleData articleData = ModalRoute.of(context).settings.arguments;
    final bean = articleData.dataList[articleData.index];
    if (!hasInitialed) {
      loadArticle(bean);
    }

    return CommonLayout(
      pageType: PageType.article,
      child: Container(
          alignment: Alignment.center,
          margin:
              isNotMobile ? const EdgeInsets.all(0) : const EdgeInsets.all(20),
          child: data.isEmpty
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

    return Container(
        margin: EdgeInsets.only(top: 20),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    child: Center(
                      child: ListView.builder(
                        itemBuilder: (ctx, index) {
                          final data = articleData.dataList[index];
                          return Container(
                            alignment: Alignment.centerLeft,
                            child: FlatButton(
                              child: Text(
                                data.articleName,
                                style: TextStyle(
                                    color: index == articleData.index
                                        ? Colors.green
                                        : Colors.black,
                                    fontFamily: 'huawen_kt'),
                              ),
                              onPressed: () {
                                articleData.index = index;
                                loadArticle(articleData.dataList[index]);
                              },
                            ),
                          );
                        },
                        itemCount: articleData.dataList.length,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            )),
            Expanded(
              child: Container(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: getMarkdownCard(bean, height, width, context),
                ),
              ),
              flex: 2,
            ),
            Expanded(
                child: Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                            child: Container(
                          alignment: Alignment.center,
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
                        )),
                        Expanded(
                            child: Container(
                          alignment: Alignment.center,
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
                        )),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
            )),
          ],
        ));
  }

  Widget getMobileLayout(double width, double height, ArticleItemBean bean) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: SingleChildScrollView(
        child: Container(
          width: width,
          margin: EdgeInsets.only(top: 10, bottom: 20),
          child: getMarkdownCard(bean, height, width, context),
        ),
      ),
    );
  }

  Card getMarkdownCard(
      ArticleItemBean bean, double height, double width, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      child: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Container(
              child: Text(bean.articleName,
                  style: const TextStyle(
                    fontFamily: 'huawen_kt',
                    fontSize: 40,
                  )),
              alignment: Alignment.center,
            ),
            Html(
              data: data,
              useRichText: false,
              onLinkTap: (url) {html.window.open('$url', "image");},
              onImageTap: (url) {html.window.open('$url', "url");},
              customRender: (node, children) {
                // ignore: missing_return
                if(node is dom.Element) {

                  switch(node.localName) {
                    case "video": return CheWieVideoWidget(url: node.attributes['src'],);
                    case "img": return buildImageWidget(height, width, node.attributes['src']);
                  }
                }
                // ignore: missing_return
              },

            )
//            markdownBody(height, width, context),
          ],
        ),
      ),
    );
  }

//  MarkdownBody markdownBody(double height, double width, BuildContext context) {
//    return MarkdownBody(
//      fitContent: false,
//      data: data,
//      selectable: false,
//      onTapLink: (link) {
//        html.window.open(link, link);
//      },
//      styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
//      imageBuilder: (Uri url) {
//        return buildImageWidget(height, width, url.toString());
//      },
//      styleSheet: MarkdownStyleSheet(
//          codeblockPadding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
//          p: TextStyle(
//            color: Theme.of(context).textTheme.subtitle2.color,
//            fontFamily: "",
//          ),
//          h1: TextStyle(
//              fontSize: 25, color: Theme.of(context).textTheme.bodyText1.color),
//          h2: TextStyle(
//              fontSize: 21, color: Theme.of(context).textTheme.bodyText1.color),
//          h3: TextStyle(
//              fontSize: 18, color: Theme.of(context).textTheme.bodyText1.color),
//          h4: TextStyle(
//              fontSize: 16, color: Theme.of(context).textTheme.bodyText1.color),
//          blockSpacing: 10),
//    );
//  }

  Container buildImageWidget(double height, double width, String url) {
    return Container(
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: height / 3 * 2, maxWidth: width / 3 * 2),
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
