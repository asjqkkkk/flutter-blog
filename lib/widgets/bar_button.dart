import 'package:flutter/material.dart';

class BarButton<T> extends StatelessWidget {
  final bool isChecked;
  final Widget child;
  final VoidCallback onPressed;

  const BarButton({
    Key key,
    this.isChecked = false,
    @required this.child,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          isChecked
              ? Container(
                  width: 4,
                  height: 4,
                )
              : Container(),
          FlatButton(
            child: child,
            onPressed: onPressed ?? () {},
          ),
          isChecked
              ? Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
