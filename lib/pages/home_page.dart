import 'package:flutter/material.dart';
import 'article_page.dart';
import '../json/article_item_bean.dart';
import '../logic/home_page_logic.dart';
import '../widgets/artical_item.dart';
import '../widgets/common_layout.dart';

class HolePage extends StatefulWidget {
  @override
  _HolePageState createState() => _HolePageState();
}

class _HolePageState extends State<HolePage> {
  final logic = HomePageLogic();
  ArticleType type = ArticleType.life;

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
        child: Container(
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
                        fontFamily: "huawen_kt"),
                  ),
                  SizedBox(
                    height: getScaleSizeByHeight(height, 40.0),
                  ),
                  FlatButton(
                    onPressed: (){
                      if(type == ArticleType.life) return;
                      type = ArticleType.life;
                      showDataList.clear();
                      showDataList.addAll(dataMap[ArticleType.life]);
                      setState(() {});
                    },
                    child: Text(
                      "生活",
                      style: TextStyle(
                        fontSize: fontSizeByHeight,
                        color: type == ArticleType.life ? null : Color(0xff9E9E9E),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: getScaleSizeByHeight(height, 40.0),
                  ),
                  FlatButton(
                    onPressed: (){
                      if(type == ArticleType.study) return;
                      type = ArticleType.study;
                      showDataList.clear();
                      if(dataMap[ArticleType.study] != null) {
                        showDataList.addAll(dataMap[ArticleType.study]);
                        setState(() {});
                      } else {
                        logic.getArticleData("config_study.json").then((List<ArticleItemBean> data) {
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
                          color: type == ArticleType.study ? null : Color(0xff9E9E9E),),
                    ),
                  ),
                  SizedBox(
                    height: getScaleSizeByHeight(height, 40.0),
                  ),
//                      FlatButton(
//                        onPressed: (){
//                          if(type == ArticleType.read) return;
//                        },
//                        child: Text(
//                          "阅读",
//                          style: TextStyle(
//                            fontSize: fontSizeByHeight,
//                            color: type == ArticleType.read ? null : Color(0xff9E9E9E),
//                          ),
//                        ),
//                      ),
                ],
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                      top: 70, left: 0.06 * width),
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
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Wrap(
                              children: List.generate(showDataList.length,
                                  (index) {
                                return Container(
                                  margin: EdgeInsets.fromLTRB(
                                      0.02 * width,
                                      0.04 * height,
                                      0.02 * width,
                                      0.04 * height),
                                  child: GestureDetector(
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
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
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


enum ArticleType{
  life,
  study,
  read
}