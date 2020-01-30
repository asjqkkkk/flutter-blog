import 'package:flutter/material.dart';

import 'bar_button.dart';

class WebBar extends StatefulWidget {

  final PageType pageType;

  const WebBar({Key key, this.pageType = PageType.home}) : super(key: key);

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
      child: Row(
        children: <Widget>[
          FlutterLogo(
            size: getScaleSizeByHeight(height,75.0),
            colors: Colors.blueGrey,
          ),
          SizedBox(
            width: 30.0,
          ),
          Container(
            height: getScaleSizeByHeight(height,50.0),
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
            flex: 1,
          ),
          BarButton(
            child: Text(
              "首页",
              style: TextStyle(fontSize: fontSize),
            ),
            onPressed: (){
              setState(() {
                pageType = PageType.home;
              });
            },
            isChecked: pageType == PageType.home,
          ),
          BarButton(
            child: Text(
              "标签",
              style: TextStyle(fontSize: fontSize),
            ),
            onPressed: (){
              setState(() {
                pageType = PageType.tag;
              });
            },
            isChecked: pageType == PageType.tag,
          ),
          BarButton(
            child: Text(
              "归档",
              style: TextStyle(fontSize: fontSize),
            ),
            onPressed: (){
              setState(() {
                pageType = PageType.archive;
              });
            },
            isChecked: pageType == PageType.archive,
          ),
          BarButton(
            child: Text(
              "关于",
              style: TextStyle(fontSize: fontSize),
            ),
            onPressed: (){
              setState(() {
                pageType = PageType.about;
              });
            },
            isChecked: pageType == PageType.about,
          ),
        ],
      ),
    );
  }

  double getScaleSizeByHeight(double height, double size) {
    return size * height / 1200;
  }
}

enum PageType{
  home,
  tag,
  archive,
  about
}
