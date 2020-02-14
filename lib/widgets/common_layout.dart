import 'dart:math';

import 'package:flutter/material.dart';
import '../json/article_json_bean.dart';

import '../widgets/web_bar.dart';
import 'fab_menu.dart';
import 'search_delegate_widget.dart';
export '../widgets/web_bar.dart';

class CommonLayout extends StatelessWidget {
  const CommonLayout({Key key,
    @required this.child,
    this.pageType = PageType.home, this.drawer, this.globalKey})
      : super(key: key);

  final Widget child;
  final Widget drawer;
  final PageType pageType;
  final GlobalKey<ScaffoldState> globalKey;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    final width = size.width;
    final height = size.height;
    final isNotMobile = !PlatformDetector().isMobile();

    return Scaffold(
      key: globalKey,
      drawer: isNotMobile || pageType != PageType.home ? null : Drawer(
        child: drawer,
      ),
      floatingActionButton: getFab(isNotMobile, pageType,context),
      body: Container(
        margin: isNotMobile
            ? EdgeInsets.only(
            left: 0.07 * width, right: 0.07 * width, top: 0.05 * height)
            : const EdgeInsets.all(0),
        child: Stack(
          children: <Widget>[
            WebBar(
              pageType: pageType,
            ),
            Container(
              child: child,
              margin: const EdgeInsets.only(top: 70),
            ),
          ],
        ),
      ),
    );
  }

  Widget getFab(bool isNotMobile, PageType pageType, BuildContext context) {
    if (isNotMobile) return null;
    if(pageType == PageType.article) return null;
    return FloatingActionButton(
      elevation: 0.0,
      backgroundColor: Colors.white.withOpacity(0.8),
      onPressed: () async{
        if(pageType == PageType.home) {
          globalKey?.currentState?.openDrawer();
        } else {
          final dynamic data = await ArticleJson.loadArticles();
          final map = Map.from(data);
          showSearch(context: context, delegate: SearchDelegateWidget(map));
        }
      }, child: Icon(pageType == PageType.home ? Icons.menu : Icons.search, color: Colors.black.withOpacity(0.5),),);
  }
}
