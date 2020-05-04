import '../pages/article_page.dart';

import '../config/base_config.dart';
import '../config/platform_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../json/article_json_bean.dart';
import '../json/article_item_bean.dart';
import '../logic/home_page_logic.dart';
import '../widgets/artical_item.dart';
import '../widgets/common_layout.dart';
import '../widgets/search_delegate_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final logic = HomePageLogic();
  ArticleType type = ArticleType.study;

  List<ArticleItemBean> showDataList = [];
  Map<ArticleType, List<ArticleItemBean>> dataMap = Map();
  final GlobalKey<ScaffoldState> globalKey = GlobalKey();

  @override
  void initState() {
    logic.getArticleData('config_study').then((List<ArticleItemBean> data) {
      dataMap[ArticleType.study] = data;
      showDataList.addAll(data);
      refresh();
      ArticleJson.loadArticles();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final fontSizeByHeight = height * 30 / 1200;
    final detector = PlatformType();
    final isNotMobile = !detector.isMobile();

    return CommonLayout(
      globalKey: globalKey,
      drawer: getTypeChangeWidegt(height, fontSizeByHeight, isNotMobile),
      child: Container(
        child: isNotMobile
            ? getPcGrid(height, fontSizeByHeight, width, context)
            : getMobileList(),
      ),
    );
  }

  Row getPcGrid(double height, double fontSizeByHeight, double width,
      BuildContext context) {
    return Row(
      children: <Widget>[
        getTypeChangeWidegt(height, fontSizeByHeight, true),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
                left: 0.06 * width, right: 0.06 * width, top: 0.02 * width),
            child: showDataList.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overScroll) {
                      overScroll.disallowGlow();
                      return true;
                    },
                    child: GridView.count(
                      crossAxisCount: 3,
                      padding: EdgeInsets.fromLTRB(
                          0.02 * width, 0.02 * height, 0.02 * width, 0),
                      children: List.generate(showDataList.length, (index) {
                        return GestureDetector(
                          child: ArticleItem(bean: showDataList[index]),
                          onTap: () {
                            final name = showDataList[index].articleName;
                            final result = Uri.encodeFull(name);
                            Navigator.of(context).pushNamed(
                                articlePage + '/$result',
                                arguments: ArticleData(index, showDataList));
                          },
                        );
                      }),
                    )),
          ),
        )
      ],
    );
  }
//
//  int getCrossCount(double width) {
//    final result = ((width - 400) ~/ 300) < 1 ? 1 : ((width - 400) ~/ 300);
//    return result > 3 ? 3 : result;
//  }

  Column getTypeChangeWidegt(
      double height, double fontSizeByHeight, bool isNotMobile) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          "我的\n博客",
          style: TextStyle(
            fontSize: getScaleSizeByHeight(height, 90.0),
            fontFamily: "huawen_kt",
          ),
        ),
        SizedBox(
          height: getScaleSizeByHeight(height, 40.0),
        ),
        FlatButton(
          onPressed: () {
            if (type == ArticleType.study) return;
            type = ArticleType.study;
            showDataList.clear();
            if (dataMap[ArticleType.study] != null) {
              showDataList.addAll(dataMap[ArticleType.study]);
              refresh();
            } else {
              refresh();
              logic
                  .getArticleData("config_study")
                  .then((List<ArticleItemBean> data) {
                dataMap[ArticleType.study] = data;
                showDataList.addAll(data);
                refresh();
              });
            }
          },
          child: Text(
            '学习',
            style: TextStyle(
              fontSize: fontSizeByHeight,
              color: type == ArticleType.study ? null : const Color(0xff9E9E9E),
              fontFamily: 'huawen_kt',
            ),
          ),
        ),
        SizedBox(
          height: getScaleSizeByHeight(height, 40.0),
        ),
        FlatButton(
          onPressed: () {
            if (type == ArticleType.life) return;
            type = ArticleType.life;
            showDataList.clear();
            if (dataMap[ArticleType.life] != null) {
              showDataList.addAll(dataMap[ArticleType.life]);
              refresh();
            } else {
              refresh();
              logic
                  .getArticleData("config_life")
                  .then((List<ArticleItemBean> data) {
                dataMap[ArticleType.life] = data;
                showDataList.addAll(data);
                refresh();
              });
            }
          },
          child: Text(
            '生活',
            style: TextStyle(
              fontSize: fontSizeByHeight,
              color: type == ArticleType.life ? null : Color(0xff9E9E9E),
              fontFamily: 'huawen_kt',
            ),
          ),
        ),
        SizedBox(
          height: getScaleSizeByHeight(height, 40.0),
        ),
        FlatButton(
          onPressed: () {
            if (type == ArticleType.topic) return;
            type = ArticleType.topic;
            showDataList.clear();
            if (dataMap[ArticleType.topic] != null) {
              showDataList.addAll(dataMap[ArticleType.topic]);
              refresh();
            } else {
              refresh();
              logic
                  .getArticleData('config_topic')
                  .then((List<ArticleItemBean> data) {
                dataMap[ArticleType.topic] = data;
                showDataList.addAll(data);
                refresh();
              });
            }
          },
          child: Text(
            '习题',
            style: TextStyle(
              fontSize: fontSizeByHeight,
              color: type == ArticleType.topic ? null : Color(0xff9E9E9E),
              fontFamily: 'huawen_kt',
            ),
          ),
        ),
        if (isNotMobile)
          Container()
        else
          SizedBox(
            height: getScaleSizeByHeight(height, 40.0),
          ),
        if (isNotMobile)
          Container()
        else
          IconButton(
              icon: Icon(
                Icons.search,
                color: const Color(0xff9E9E9E),
              ),
              onPressed: () async {
                final dynamic data = await ArticleJson.loadArticles();
                final map = Map.from(data);
                showSearch(
                    context: context, delegate: SearchDelegateWidget(map));
              }),
      ],
    );
  }

  void refresh() {
    setState(() {});
  }

  Widget getMobileList() {
    if (showDataList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overScroll) {
          overScroll.disallowGlow();
          return true;
        },
        child: ListView.builder(
          itemCount: showDataList.length,
          padding: EdgeInsets.all(0.0),
          itemBuilder: (ctx, index) {
            return GestureDetector(
              child: ArticleItem(bean: showDataList[index]),
              onTap: () {
                final name = showDataList[index].articleName;
                final result = Uri.encodeFull(name);
                Navigator.of(context).pushNamed(articlePage + '/$result',
                    arguments: ArticleData(index, showDataList));
              },
            );
          },
        ),
      );
    }
  }

  double getScaleSizeByWidth(double width, double size) {
    return size * width / 1600;
  }

  double getScaleSizeByHeight(double height, double size) {
    return size * height / 1200;
  }
}

enum ArticleType { life, study, topic }
