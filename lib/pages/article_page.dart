import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:new_web/config/all_configs.dart';
import 'package:new_web/json/all_jsons.dart';
import 'package:new_web/widgets/all_widgets.dart';
import 'package:new_web/widgets/article_list.dart';

import '../util/launch_util.dart';

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
      if (!isInitial)
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          controller.jumpTo(index: 0);
        });
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
      child: TocListWidget(
        controller: controller,
        tocItem: (toc, isCurrent) {
          return TocItemWidget(
            isCurrent: isCurrent,
            toc: toc,
            fontSize: fontSize ?? v12,
            onTap: () {
              controller.jumpTo(index: toc.index);
            },
          );
        },
        emptyWidget: SvgPicture.asset(
          Svg.location,
          width: v30,
          height: v30,
          color: color4,
        ),
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

TextStyle _titleStyle(double fontSize) => CTextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: defaultTitleColor,
      fontFamily: siYuanFont,
    );

MarkdownWidget buildMarkdownWidget(
    String value, bool isDark, TocController controller) {
  return MarkdownWidget(
    data: value,
    controller: controller,
    styleConfig: StyleConfig(
        pConfig: PConfig(
            onLinkTap: (url) => launchUrl(Uri.tryParse(url ?? '')!),
            textStyle: defaultPStyle!
                .copyWith(fontSize: defaultFontSize, fontFamily: siYuanFont),
            linkStyle: defaultLinkStyle!
                .copyWith(fontSize: defaultFontSize, fontFamily: siYuanFont),
            strongStyle: defaultStrongStyle.copyWith(
                fontSize: defaultFontSize, fontFamily: siYuanFont),
            delStyle: defaultDelStyle.copyWith(
                fontSize: defaultFontSize, fontFamily: siYuanFont),
            emStyle: defaultEmStyle.copyWith(
                fontSize: defaultFontSize, fontFamily: siYuanFont),
            custom: (element) {
              if (element.tag == 'youtube') {
                final youtubeId = element.attributes['id'];
                return YoutubePlayer(youtubeId: youtubeId);
              }
              return Container();
            }),
        olConfig: OlConfig(
            textStyle: defaultPStyle!
                .copyWith(fontSize: defaultFontSize, fontFamily: siYuanFont)),
        ulConfig: UlConfig(
            textStyle: defaultPStyle!
                .copyWith(fontSize: defaultFontSize, fontFamily: siYuanFont)),
        codeConfig: CodeConfig(
          codeStyle: defaultCodeStyle!.copyWith(
              fontSize: defaultFontSize,
              fontFamily: siYuanFont,
              color: Colors.redAccent),
        ),
        titleConfig: TitleConfig(
          showDivider: false,
          h1: _titleStyle(v28),
          h2: _titleStyle(v26),
          h3: _titleStyle(v23),
          h4: _titleStyle(v20),
          h5: _titleStyle(v16),
          h6: _titleStyle(v14),
        ),
        imgBuilder: (url, attr) {
          double? w;
          double? h;
          if (attr['width'] != null) w = double.parse(attr['width']!);
          if (attr['height'] != null) h = double.parse(attr['height']!);
          final hasSize = w != null && h != null;
          return LayoutBuilder(builder: (context, constrains) {
            final maxW = constrains.maxWidth;
            final halfW = maxW / 2;
            final realW = hasSize ? (w ?? halfW) : halfW;
            return CusInkWell(
              onTap: () => toLaunch(url),
              child: LoadingImage(
                image: ResizeImage(NetworkImage(url),
                    width: realW.toInt(), allowUpscaling: true),
                width: realW,
                loadingWidget: buildShimmer(realW, realW),
              ),
            );
          });
        },
        blockQuoteConfig: BlockQuoteConfig(
            blockStyle: defaultBlockStyle!
                .copyWith(fontSize: defaultFontSize, fontFamily: siYuanFont)),
        tableConfig: TableConfig(
            bodyStyle: defaultPStyle!
                .copyWith(fontSize: defaultFontSize, fontFamily: siYuanFont),
            headerStyle: defaultPStyle!
                .copyWith(fontSize: defaultFontSize, fontFamily: siYuanFont)),
        preConfig: PreConfig(
          textStyle: CTextStyle(fontSize: defaultFontSize),
          preWrapper: (child, text) {
            return Stack(
              children: <Widget>[
                child,
                Container(
                  margin: EdgeInsets.only(top: v5, right: v5),
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: text));
                      ToastWidget().showToast('复制成功');
                    },
                    icon: SvgPicture.asset(Svg.copy, width: v12),
                  ),
                )
              ],
            );
          },
          language: 'dart',
        ),
        markdownTheme:
            isDark ? MarkdownTheme.darkTheme : MarkdownTheme.lightTheme),
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
