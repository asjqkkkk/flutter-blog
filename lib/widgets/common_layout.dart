import 'package:flutter/material.dart';

import '../widgets/web_bar.dart';
export '../widgets/web_bar.dart';

class CommonLayout extends StatelessWidget {
  const CommonLayout(
      {Key key,
      @required this.child,
      this.isHome = false,
      this.pageType = PageType.home})
      : super(key: key);

  final Widget child;
  final bool isHome;
  final PageType pageType;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isNotMobile = !PlatformDetector().isMobile();

    return Container(
      margin: isNotMobile
          ? EdgeInsets.only(
              left: 0.07 * width, right: 0.07 * width, top: 0.05 * height)
          : EdgeInsets.all(0),
      child: Stack(
        children: <Widget>[
          WebBar(
            isHome: isHome,
            pageType: pageType,
          ),
          Container(
            child: child,
            margin: EdgeInsets.only(top: 70),
          ),
        ],
      ),
    );
  }
}
