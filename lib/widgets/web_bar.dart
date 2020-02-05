import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog/pages/friend_link_page.dart';
import '../pages/tag_page.dart';
import '../pages/archive_page.dart';
import '../pages/about_page.dart';
import '../pages/home_page.dart';

import 'bar_button.dart';

class WebBar extends StatefulWidget {
  final PageType pageType;
  final bool isHome;


  const WebBar({Key key, this.pageType = PageType.home, this.isHome = false})
      : super(key: key);

  @override
  _WebBarState createState() => _WebBarState();
}

class _WebBarState extends State<WebBar> {
  PageType pageType;

  @override
  void initState() {
    pageType = widget.pageType;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final fontSize = height * 30 / 1200;

    return Container(
      width: size.width - 200.0,
      height: 70,
      child: SingleChildScrollView(
        child: Row(
          children: <Widget>[
            FlutterLogo(
              size: getScaleSizeByHeight(height, 75.0),
              colors: Colors.blueGrey,
            ),
            SizedBox(
              width: 30.0,
            ),
            Container(
              height: getScaleSizeByHeight(height, 50.0),
              width: 3.0,
              color: Color(0xff979797),
            ),
            SizedBox(
              width: 30.0,
            ),
            Text(
              "Flutter",
              style: TextStyle(fontSize: fontSize),
            ),
            Spacer(
              flex: width ~/ 150,
            ),
            Expanded(
              child: BarButton(
                child: Text(
                  "首页",
                  style: TextStyle(fontSize: fontSize),
                ),
                onPressed: () {
                  if (pageType == PageType.home && widget.isHome) return;
                  Navigator.of(context).popUntil((route) => route.isFirst);
//                  Navigator.pushNamed(context, '/second');
                },
                isChecked: pageType == PageType.home,
              ),
            ),
            Expanded(
              child: BarButton(
                child: Text(
                  "标签",
                  style: TextStyle(fontSize: fontSize),
                ),
                onPressed: () {
                  if (pageType == PageType.tag) return;
//                  if(!widget.isHome) Navigator.of(context).pop();
                  pushAndRemove(context, "tag");
                },
                isChecked: pageType == PageType.tag,
              ),
            ),
            Expanded(
              child: BarButton(
                child: Text(
                  "归档",
                  style: TextStyle(fontSize: fontSize),
                ),
                onPressed: () {
                  if (pageType == PageType.archive) return;
//                  if(!widget.isHome) Navigator.of(context).pop();
                  pushAndRemove(context, "archive");
                },
                isChecked: pageType == PageType.archive,
              ),
            ),
            Expanded(
              child: BarButton(
                child: Text(
                  "友链",
                  style: TextStyle(fontSize: fontSize),
                ),
                onPressed: () {
                  if (pageType == PageType.link) return;
//                  if(!widget.isHome) Navigator.of(context).pop();
                  pushAndRemove(context, "link");
                },
                isChecked: pageType == PageType.link,
              ),
            ),
            Expanded(
              child: BarButton(
                child: Text(
                  "关于",
                  style: TextStyle(fontSize: fontSize),
                ),
                onPressed: () {
                  if (pageType == PageType.about) return;
//                  if(!widget.isHome) Navigator.of(context).pop();
                  pushAndRemove(context, "about");
                },
                isChecked: pageType == PageType.about,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void pushAndRemove(BuildContext context, String routeName) {
    if(widget.isHome) {
      Navigator.pushNamed(context, '/$routeName');
    } else {
      Navigator.pushReplacementNamed(context, '/$routeName');
    }
  }

  double getScaleSizeByHeight(double height, double size) {
    return size * height / 1200;
  }
}

enum PageType { home, tag, archive, about, link }
