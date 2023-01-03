import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/config/markdown_generator.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:new_web/config/all_configs.dart';
import 'package:new_web/json/all_jsons.dart';
import 'package:new_web/widgets/all_widgets.dart';
import 'package:new_web/widgets/article_list.dart';

import '../config/video.dart';

class ArticleArg {
  ArticleArg(this.id, this.path);

  final String? id;
  final String? path;
}

class ArticlePage extends StatefulWidget {
  const ArticlePage({Key? key, required this.articleArg}) : super(key: key);

  final ArticleArg? articleArg;

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final _markdownData = ValueNotifier('');
  final ValueNotifier<ArticleItemBean?> _article = ValueNotifier(null);
  String? id;
  String? path;
  final TocController controller = TocController();

  String? get markdownData => _markdownData.value;

  @override
  void initState() {
    id = widget.articleArg?.id;
    path = widget.articleArg?.path;
    loadArticle();
    super.initState();
  }

  void loadArticle({bool isInitial = true}) {
    loadArticles(id: id).then((content) {
      if (content.startsWith('---')) {
        final index = content.indexOf('---', 2);
        _markdownData.value = content.substring(index + 3, content.length);
      } else {
        _markdownData.value = content;
      }
    });
    if (!isInitial)
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        controller.jumpToIndex(0);
      });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: buildBody(width, height, context),
    );
  }

  Widget buildBody(double width, double height, BuildContext context) {
    return Center(
        child: NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overScroll) {
        overScroll.disallowIndicator();
        return true;
      },
      child: getWebLayout(width, height, context),
    ));
  }

  Widget getWebLayout(double width, double height, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        buildArticleList(),
        buildArticleBody(height, width, context),
        buildTocListWidget(),
      ],
    );
  }

  Widget buildArticleList() => ArticleList(
        id: id,
        path: path,
        onTap: (article) {
          id = article.articleId;
          loadArticle(isInitial: false);
          _article.value = article;
        },
        // onArticleInitial: (article) {
        //   if (article != null) _article.value = article;
        // },
      );

  Widget buildTocListWidget({double? fontSize}) {
    return Container(
      width: v300,
      padding: EdgeInsets.only(top: v140, left: v20),
      child: TocWidget(
        controller: controller,
        itemBuilder: (data) {
          return TocItemWidget(
            isCurrent: data.index == data.currentIndex,
            toc: data.toc,
            fontSize: fontSize ?? v12,
            onTap: () {
              data.refreshIndexCallback.call(data.toc.widgetIndex);
              controller.jumpToIndex(data.toc.widgetIndex);
            },
          );
        },
      ),
    );
  }

  Widget getMobileLayout(double width, double height, ArticleItemBean bean) {
    return Container(
      width: width,
      padding: EdgeInsets.only(left: v4, right: v4),
      child: getMarkdownBody(height, width, context),
    );
  }

  Widget buildArticleBody(double height, double width, BuildContext context) {
    return Container(
      width: v400 * 2 + v240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ValueListenableBuilder<ArticleItemBean>(
          //   valueListenable: _article,
          //   builder: (ctx, value, _) {
          //     if (value == null) return const SizedBox();
          //     return Text(
          //       value.articleName,
          //       style: CTextStyle(
          //         fontSize: v30,
          //       ),
          //     );
          //   },
          // ),
          WebBar(),
          SizedBox(
            height: v30,
          ),
          Expanded(child: getMarkdownBody(height, width, context)),
        ],
      ),
    );
  }

  Widget getMarkdownBody(double height, double width, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<String?>(
        valueListenable: _markdownData,
        builder: (context, value, _) {
          if (value?.isEmpty ?? true) return buildEmptyLayout();
          return buildMarkdownWidget(value!, isDark, controller);
        });
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}

double get defaultFontSize => v18.ceilToDouble();

MarkdownWidget buildMarkdownWidget(
    String value, bool isDark, TocController controller) {
  return MarkdownWidget(
    data: value,
    tocController: controller,
    config: MarkdownConfig(configs: [
      PreConfig(textStyle: CTextStyle(fontSize: defaultFontSize)),
      PConfig(textStyle: CTextStyle(fontSize: defaultFontSize)),
      CodeConfig(
          style: CTextStyle(
              fontSize: defaultFontSize, backgroundColor: const Color(0xffeff1f3))),
    ]),
    markdownGeneratorConfig: MarkdownGeneratorConfig(
        generators: [videoGeneratorWithTag, youtubeGenerator],
        textGenerator: (node, config, visitor) =>
            CustomTextNode(node.textContent, config, visitor)),
  );
}

Future<String> getText(String filePath) async {
  return await rootBundle.loadString(filePath);
}

Future<dynamic> loadArticles({String? id, bool returnAll = false}) async {
  if (_articles != null)
    return returnAll ? _articles : (_articles[id] ?? _articles.values.first);
  if (!_isLoading) {
    _isLoading = true;
    final result = await rootBundle.loadString(
        '${PathConfig.assets}/${PathConfig.jsons}/${PathConfig.articleAll}.json');
    _isLoading = false;
    _articles = jsonDecode(result);
    return returnAll ? _articles : (_articles[id] ?? _articles.values.first);
  }
}

dynamic _articles;
bool _isLoading = false;

class ArticleData {
  ArticleData(this.index, this.dataList);

  int index;
  List<ArticleItemBean> dataList;
}
