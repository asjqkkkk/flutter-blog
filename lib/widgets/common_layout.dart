import 'package:flutter/material.dart';
import '../json/article_json_bean.dart';

import '../widgets/web_bar.dart';
import 'search_delegate_widget.dart';
export '../widgets/web_bar.dart';

class CommonLayout extends StatelessWidget {
  const CommonLayout({
    Key key,
    @required this.child,
    this.pageType = PageType.home,
    this.drawer,
    this.globalKey,
    this.floatingActionButton,
  }) : super(key: key);

  final Widget child;
  final Widget drawer;
  final Widget floatingActionButton;
  final PageType pageType;
  final GlobalKey<ScaffoldState> globalKey;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isNotMobile = !PlatformType().isMobile();

    return Scaffold(
      key: globalKey,
      drawer: isNotMobile || pageType != PageType.home
          ? null
          : Drawer(
              child: drawer,
            ),
      floatingActionButton:
          floatingActionButton ?? getFab(isNotMobile, pageType, context),
      body: Container(
        margin: pageType == PageType.article
            ? getArticlePageMargin(isNotMobile, width, height)
            : getCommonMargin(isNotMobile, width, height),
        child: Stack(
          children: <Widget>[
            WebBar(pageType: pageType),
            Container(
              child: child,
              margin: EdgeInsets.only(top: isNotMobile ? 70 : 90),
            ),
          ],
        ),
      ),
    );
  }

  EdgeInsets getCommonMargin(bool isNotMobile, double width, double height) {
    return isNotMobile
        ? EdgeInsets.only(
            left: 0.07 * width, right: 0.07 * width, top: 0.05 * height)
        : const EdgeInsets.all(0);
  }

  EdgeInsets getArticlePageMargin(
      bool isNotMobile, double width, double height) {
    return isNotMobile
        ? EdgeInsets.only(left: 20, right: 20, top: 0.05 * height)
        : const EdgeInsets.all(0);
  }

  Widget getFab(bool isNotMobile, PageType pageType, BuildContext context) {
    if (isNotMobile) return null;
    return FloatingActionButton(
      elevation: 0.0,
      backgroundColor: Colors.white.withOpacity(0.8),
      onPressed: () async {
        if (pageType == PageType.home) {
          globalKey?.currentState?.openDrawer();
        } else {
          final dynamic data = await ArticleJson.loadArticles();
          final map = Map.from(data);
          showSearch(context: context, delegate: SearchDelegateWidget(map));
        }
      },
      child: Icon(
        pageType == PageType.home ? Icons.menu : Icons.search,
        color: Colors.black.withOpacity(0.5),
      ),
    );
  }
}
