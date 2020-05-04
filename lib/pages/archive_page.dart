import 'package:flutter/material.dart';
import '../pages/article_page.dart';
import '../config/base_config.dart';
import '../json/article_item_bean.dart';
import '../json/archive_item_bean.dart';
import '../widgets/web_bar.dart';
import '../widgets/common_layout.dart';

class ArchivePage extends StatefulWidget {
  @override
  _ArchivePageState createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  List<ArchiveItemBean> beans = [];
  bool hasInitialed = false;
  bool isFromTag = false;

  void initialData(List<ArchiveItemBean> transBeans) {
    hasInitialed = true;
    if (transBeans == null) {
      ArchiveItemBean.loadAsset('config_archive').then((data) {
        beans.addAll(data);
        setState(() {});
      });
    } else {
      isFromTag = true;
      beans.addAll(transBeans);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isNotMobile = !PlatformType().isMobile();
    final List<ArchiveItemBean> transBeans =
        ModalRoute.of(context).settings.arguments;
    if (!hasInitialed) {
      initialData(transBeans);
    }

    return CommonLayout(
      pageType: PageType.archive,
      child: beans.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              margin: isNotMobile
                  ? const EdgeInsets.only(top: 50, left: 50, right: 50)
                  : const EdgeInsets.all(20),
              child: Card(
                margin: const EdgeInsets.only(bottom: 0.0),
                child: Container(
                  margin: isNotMobile
                      ? const EdgeInsets.only(top: 20, left: 50, right: 50)
                      : const EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overScroll) {
                      overScroll.disallowGlow();
                      return true;
                    },
                    child: ListView.builder(
                      itemCount: beans.length,
                      itemBuilder: (ctx, index) {
                        final List<YearBean> yearBeans = beans[index].beans;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${!isFromTag ? beans[index].year : beans[index].tag}',
                              style: isNotMobile
                                  ? Theme.of(context).textTheme.headline4
                                  : Theme.of(context).textTheme.headline6,
                            ),
                            Container(
                              margin: isNotMobile
                                  ? const EdgeInsets.only(
                                      top: 10, left: 50, right: 50)
                                  : EdgeInsets.all(0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    List.generate(yearBeans.length, (index2) {
                                  final yearBean = yearBeans[index2];
                                  return Container(
                                    margin: EdgeInsets.only(top: 8),
                                    child: isNotMobile
                                        ? ListTile(
                                            onTap: () {
                                              openArticlePage(
                                                  context,
                                                  List.generate(
                                                      yearBeans.length,
                                                      (index) => ArticleItemBean(
                                                          articleName:
                                                              yearBeans[index]
                                                                  .articleName)),
                                                  index2);
                                            },
                                            leading: Text(
                                              '${yearBean.articleName}',
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: 'huawen_kt'),
                                            ),
                                            trailing: Text(
                                              '${getDate(DateTime.parse(yearBean.createTime))}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1,
                                            ),
                                          )
                                        : FlatButton(
                                            onPressed: () => openArticlePage(
                                                context,
                                                List.generate(
                                                    yearBeans.length,
                                                    (index) => ArticleItemBean(
                                                        articleName:
                                                            yearBeans[index]
                                                                .articleName)),
                                                index2),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  30,
                                              child: Text(
                                                '${yearBean.articleName}',
                                                style: TextStyle(
                                                    fontSize:
                                                        isNotMobile ? 20 : 15,
                                                    fontFamily: 'huawen_kt'),
                                              ),
                                            ),
                                          ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void openArticlePage(
      BuildContext context, List<ArticleItemBean> beans, int index) {
    final name = beans[index].articleName;
    final result = Uri.encodeFull(name);
    Navigator.of(context).pushNamed(articlePage + '/$result',
        arguments: ArticleData(index, beans));
  }

  String getDate(DateTime time) {
    return '${time.year}.${time.month}.${time.day}';
  }
}
