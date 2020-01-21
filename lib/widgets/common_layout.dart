import 'package:flutter/material.dart';

class CommonLayout extends StatelessWidget {

  final Widget child;

  const CommonLayout({Key key,@required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Container(
      margin: EdgeInsets.only(left: 0.07 * width, right: 0.07 * width, top: 0.05 * height),
      child: child,
    );
  }
}
