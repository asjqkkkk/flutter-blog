import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/config/style_config.dart';
import '../config/url_launcher.dart';
import '../widgets/toc_item.dart';
import '../json/article_item_bean.dart';
import '../json/article_json_bean.dart';
import '../widgets/common_layout.dart';
import '../logic/article_page_logic.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown_widget/config/highlight_themes.dart' as theme;

class ArticlePage extends StatefulWidget {
  final ArticleData articleData;
  final String name;

  const ArticlePage({Key key, this.articleData, @required this.name})
      : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final logic = ArticlePageLogic();
  String markdownData = '';
  ArticleItemBean bean;
  ArticleData articleData;
  final TocController controller = TocController();

  @override
  void initState() {
    final name = Uri.decodeFull(widget.name);
    if (widget.articleData == null) {
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
      if (content.startsWith('---')) {
        final index = content.indexOf('---', 2);
        markdownData = content.substring(index + 3, content.length);
      } else {
        markdownData = content;
      }
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isNotMobile = !PlatformType().isMobile();

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
    final isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

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
                                            : (isDark ? Colors.grey : null),
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
              child: getBodyCard(bean, height, width, context),
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
                        if (controller.scrollController.isAttached)
                          controller.scrollController.jumpTo(index: 0);
                      },
                    ),
                  ),
                  Expanded(
                    child: TocListWidget(
                      controller: controller,
                      tocItem: (toc, isCurrent) {
                        return TocItemWidget(
                          isCurrent: isCurrent,
                          toc: toc,
                          onTap: () {
                            controller.jumpTo(index: toc.index);
                          },
                        );
                      },
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
                        if (controller.isAttached)
                          controller.jumpTo(index: controller.endIndex);
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
      child: Container(
        padding: EdgeInsets.all(4),
        child: getMarkdownBody(height, width, context),
      ),
    );
  }

  Widget getBodyCard(ArticleItemBean bean, double height, double width,
      BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(20),
        child: getMarkdownBody(height, width, context),
      ),
    );
  }

  Widget getMarkdownBody(double height, double width, BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    return MarkdownWidget(
      data: markdownData,
      controller: controller,
      styleConfig: StyleConfig(
        pConfig: PConfig(
          onLinkTap: (url) => launchURL(url),
        ),
        titleConfig: TitleConfig(
          showDivider: false,
          commonStyle: TextStyle(color: Theme.of(context).textSelectionColor),
        ),
        imgBuilder: (url, attr) {
          double w;
          double h;
          if (attr['width'] != null) w = double.parse(attr['width']);
          if (attr['height'] != null) h = double.parse(attr['height']);
          return GestureDetector(
            onTap: () => launchURL(url),
            child: Card(
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/img/loading.gif',
                image: url ?? '',
                height: h,
                width: w,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
        markdownTheme: isDark ? MarkdownTheme.darkTheme : MarkdownTheme.lightTheme
      ),

    );
  }

  void refresh() {
    if (mounted) setState(() {});
  }

}

class ArticleData {
  int index;
  List<ArticleItemBean> dataList;

  ArticleData(this.index, this.dataList);
}
