import 'package:flutter/material.dart';
import '../widgets/web_bar.dart';

class CommonLayout extends StatelessWidget {
  final Widget child;
  final bool isHome;
  final PageType pageType;

  const CommonLayout(
      {Key key, @required this.child, this.isHome = false, this.pageType = PageType.home})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Container(
      margin: EdgeInsets.only(
          left: 0.07 * width, right: 0.07 * width, top: 0.05 * height),
      child: Stack(
        children: <Widget>[
          WebBar(
            isHome: isHome,
            pageType: pageType,
          ),
          child,
        ],
      ),
    );
  }
}
