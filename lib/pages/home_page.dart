import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'article_page.dart';
import '../json/article_item_bean.dart';
import '../logic/home_page_logic.dart';
import '../widgets/artical_item.dart';
import '../widgets/common_layout.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final logic = HomePageLogic();
  ArticleType type = ArticleType.life;
  bool isInOtherPage = false;

  List<ArticleItemBean> showDataList = [];
  Map<ArticleType, List<ArticleItemBean>> dataMap = Map();

  @override
  void initState() {
    logic.getArticleData("config_life.json").then((List<ArticleItemBean> data) {
      dataMap[ArticleType.life] = data;
      showDataList.addAll(data);
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final fontSize = width * 30 / 1440;
    final fontSizeByHeight = height * 30 / 1200;
    print("Size:${size.width}   ${size.height}");

    return Scaffold(
      body: CommonLayout(
        isHome: true,
        child: isInOtherPage
            ? Container()
            : Container(
                child: Row(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "我的\n博客",
                          style: TextStyle(
                              fontSize: getScaleSizeByHeight(height, 90.0),
                              fontFamily: "huawen_kt",),
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
                              setState(() {});
                            } else {
                              setState(() {});
                              logic
                                  .getArticleData("config_study.json")
                                  .then((List<ArticleItemBean> data) {
                                dataMap[ArticleType.study] = data;
                                showDataList.addAll(data);
                                setState(() {});
                              });
                            }
                          },
                          child: Text(
                            "学习",
                            style: TextStyle(
                              fontSize: fontSizeByHeight,
                              color: type == ArticleType.study
                                  ? null
                                  : Color(0xff9E9E9E),
                              fontFamily: "huawen_kt",
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
                            showDataList.addAll(dataMap[ArticleType.life]);
                            setState(() {});
                          },
                          child: Text(
                            "生活",
                            style: TextStyle(
                              fontSize: fontSizeByHeight,
                              color: type == ArticleType.life
                                  ? null
                                  : Color(0xff9E9E9E),
                              fontFamily: "huawen_kt",
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
                              setState(() {});
                            } else {
                              setState(() {});
                              logic
                                  .getArticleData("config_topic.json")
                                  .then((List<ArticleItemBean> data) {
                                dataMap[ArticleType.topic] = data;
                                showDataList.addAll(data);
                                setState(() {});
                              });
                            }
                          },
                          child: Text(
                            "习题",
                            style: TextStyle(
                              fontSize: fontSizeByHeight,
                              color: type == ArticleType.topic
                                  ? null
                                  : Color(0xff9E9E9E),
                              fontFamily: "huawen_kt",
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                            left: 0.06 * width,
                            right: 0.06 * width,
                            top: 0.02 * width),
                        child: showDataList.isEmpty
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : NotificationListener<
                                    OverscrollIndicatorNotification>(
                                onNotification: (overScroll) {
                                  overScroll.disallowGlow();
                                  return true;
                                },
                                child: GridView.count(
                                  crossAxisCount: 3,
                                  padding: EdgeInsets.fromLTRB(0.02 * width,
                                      0.02 * height, 0.02 * width, 0),
                                  children: List.generate(showDataList.length,
                                      (index) {
                                    return GestureDetector(
                                      child: ArticleItem(
                                          bean: showDataList[index]),
                                      onTap: () {
                                        Navigator.of(context).push(
                                            new MaterialPageRoute(
                                                builder: (ctx) {
                                          return ArticlePage(
                                            bean: showDataList[index],
                                          );
                                        }));
                                      },
                                    );
                                  }),
                                )),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  double getScaleSizeByWidth(double width, double size) {
    return size * width / 1600;
  }

  double getScaleSizeByHeight(double height, double size) {
    return size * height / 1200;
  }
}

enum ArticleType { life, study, topic }
