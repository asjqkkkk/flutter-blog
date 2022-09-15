import 'package:flutter/material.dart';
import 'package:new_web/config/all_configs.dart';
import 'package:new_web/json/article_item_bean.dart';
import 'package:new_web/ui/all_ui.dart';
import 'package:new_web/widgets/all_widgets.dart';

class ArticleItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: GlobalData.instance.articleData,
        builder: (ctx, dynamic value, _) {
          if (value == null) return buildEmptyLayout();
          return _ArticleItem(data: value);
        });
  }
}

const Map<String, String> articleNameMap = {
  'life': '生 活',
  'study': '技 术',
  'topic': '习 题',
};

class _ArticleItem extends StatefulWidget {
  const _ArticleItem({Key? key, required this.data}) : super(key: key);

  final Map<String, List<ArticleItemBean>> data;

  @override
  _ArticleItemState createState() => _ArticleItemState();
}

class _ArticleItemState extends State<_ArticleItem>
    with TickerProviderStateMixin {
  Map<String, List<ArticleItemBean>> get articleMap => widget.data;

  List<_Tab> get _tabs =>
      articleMap.keys.map((e) => _Tab(e, articleNameMap[e])).toList();

  TabController? _tabController;

  final _curIndex = ValueNotifier(0);

  int get curIndex => _curIndex.value;

  @override
  void initState() {
    _tabController = TabController(length: _tabs.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: v400 * 2 + v240,
      margin:
          EdgeInsets.only(bottom: v64, top: v65, left: v76, right: v160 - v76),
      child: buildBody(),
    );
  }

  Widget buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTabs(),
        SizedBox(height: v20),
        buildViews(),
      ],
    );
  }

  Widget buildTabs() {
    return TabBar(
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: color4,
      labelStyle: TextStyle(fontSize: v16, fontWeight: FontWeight.bold),
      unselectedLabelStyle:
          TextStyle(fontSize: v16, fontWeight: FontWeight.normal),
      unselectedLabelColor: color22,
      indicator: CusUnderlineTabIndicator(
        borderSide: BorderSide(width: v2, color: color4),
        insets: EdgeInsets.fromLTRB(v2, v4, v2, 0),
        borderHeight: v2,
      ),
      onTap: (index) {
        if (curIndex == index) return;
        _curIndex.value = index;
      },
      tabs: List.generate(
        _tabs.length,
        (index) {
          final cur = _tabs[index].tabName!;
          return Column(
            children: [
              Text(
                cur,
                style: CTextStyle(fontSize: v14),
              ),
              SizedBox(height: v4),
            ],
          );
        },
      ),
      controller: _tabController,
      isScrollable: true,
    );
  }

  Widget buildViews() {
    return Expanded(
      child: ValueListenableBuilder(
          valueListenable: _curIndex,
          builder: (context, dynamic value, _) {
            final cur = _tabs[value];
            final curList = articleMap[cur.tab];
            if (curList == null || curList.isEmpty) return buildEmptyLayout();
            final length = curList.length;
            return SelectionArea(
              child: ListView.builder(
                padding: EdgeInsets.only(top: v26),
                itemBuilder: (ctx, index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(_crossCount, (i) {
                      final isFirstInLine = i == 0;
                      final curIndex = index * _crossCount + i;
                      final isOver = curIndex + 1 > length;
                      if (isOver) {
                        return Container(
                              width: v210,
                            );
                      } else {
                        return Padding(
                              padding:
                                  EdgeInsets.only(left: isFirstInLine ? 0 : v66),
                              child: ArticleTypeItem(
                                article: curList[curIndex],
                                articlePath: cur.tab,
                              ),
                            );
                      }
                    }),
                  );
                },
                itemCount: (length / _crossCount).ceil(),
              ),
            );
          }),
    );
  }
}

const int _crossCount = 4;

class _Tab {
  _Tab(this.tab, this.tabName);

  final String tab;
  final String? tabName;
}
