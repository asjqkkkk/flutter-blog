import 'package:flutter/material.dart';
import 'package:new_web/config/all_configs.dart';
import 'package:new_web/items/all_items.dart';
import 'package:new_web/json/all_jsons.dart';
import 'package:new_web/widgets/all_widgets.dart';

class ArticleList extends StatelessWidget {
  const ArticleList({
    Key? key,
    this.onTap,
    this.onArticleInitial,
    required this.id,
    required this.path,
  }) : super(key: key);

  final OnArticleItemTap? onTap;
  final OnArticleInitial? onArticleInitial;
  final String? id;
  final String? path;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: GlobalData.instance.articleData,
        builder: (ctx, dynamic value, _) {
          if (value != null)
            return _ArticleList(
              articleData: value,
              id: id,
              path: path,
              onTap: onTap,
              onArticleInitial: onArticleInitial,
            );
          return buildEmptyLayout();
        });
  }
}

class _ArticleList extends StatefulWidget {
  const _ArticleList({
    Key? key,
    required this.articleData,
    required this.id,
    required this.path,
    this.onTap,
    this.onArticleInitial,
  }) : super(key: key);

  final Map<String, List<ArticleItemBean>> articleData;
  final OnArticleItemTap? onTap;
  final OnArticleInitial? onArticleInitial;
  final String? id;
  final String? path;

  @override
  __ArticleListState createState() => __ArticleListState();
}

class __ArticleListState extends State<_ArticleList> {
  final _id = ValueNotifier('');

  List<String> get keys => articleData.keys.toList();

  Map<String, List<ArticleItemBean>> get articleData => widget.articleData;

  String? get id => _id.value;

  @override
  void initState() {
    _id.value = widget.id ?? '';
    if (widget.onArticleInitial != null) {
      final article = articleData[widget.path!]!
          .where((element) => element.articleId == id)
          .first;
      widget.onArticleInitial!.call(article);
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _ArticleList oldWidget) {
    _id.value = widget.id ?? '';
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(v20, v70, v10, v50),
      width: v300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              CusInkWell(
                  child: SvgPicture.asset(
                    Svg.home,
                    height: v45,
                    color: Colors.black,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  }),
              SizedBox(width: v20),
              const DateWidget(margin: EdgeInsets.zero),
            ],
          ),
          SizedBox(height: v40),
          Text(
            '目录:',
            style: CTextStyle(fontWeight: FontWeight.bold, fontSize: v20),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: keys.length,
              itemBuilder: (ctx, index) {
                final key = keys[index];
                final articleList = widget.articleData[key]!;
                return Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    iconTheme: IconThemeData(size: v20, color: color4),
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent, colorScheme: ColorScheme.fromSwatch().copyWith(secondary: color4),
                  ),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    title: Text(
                      articleNameMap[key]!,
                      style: CTextStyle(fontSize: v14),
                    ),
                    initiallyExpanded: widget.path == key,
                    children: List.generate(articleList.length, (i) {
                      final article = articleList[i];
                      return Container(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(v5, v10, v6, v10),
                            child: ValueListenableBuilder(
                                valueListenable: _id,
                                builder: (context, dynamic value, _) {
                                  final isCur = value == article.articleId;
                                  return Text(
                                    article.articleName!,
                                    style: CTextStyle(
                                        color: isCur ? color4 : Colors.grey,
                                        fontSize: v14),
                                  );
                                }),
                          ),
                          onTap: () {
                            _id.value = article.articleId ?? '';
                            widget.onTap?.call(article);
                          },
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

typedef OnArticleItemTap = void Function(ArticleItemBean itemBean);
typedef OnArticleInitial = void Function(ArticleItemBean itemBean);
