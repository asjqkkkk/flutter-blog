import 'package:flutter/material.dart';
import '../pages/about_page.dart';

import 'bar_button.dart';

class WebBar extends StatefulWidget {
  final PageType pageType;
  final bool isHome;

  const WebBar({Key key, this.pageType = PageType.home, this.isHome = false}) : super(key: key);

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
//                  pageType = PageType.home;
//                  setState(() {});
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
                  showWaitingDialog(context);
//                  pageType = PageType.tag;
//                  setState(() {});
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
                  showWaitingDialog(context);
//                  pageType = PageType.archive;
//                  setState(() {});
                },
                isChecked: pageType == PageType.archive,
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
                  Navigator.of(context).push(new MaterialPageRoute(builder: (ctx){return AboutPage();}));
//                  pageType = PageType.about;
//                  setState(() {});
                },
                isChecked: pageType == PageType.about,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showWaitingDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            content: Text("功能尚在开发中..."),
          );
        });
  }

  double getScaleSizeByHeight(double height, double size) {
    return size * height / 1200;
  }
}

enum PageType { home, tag, archive, about }
