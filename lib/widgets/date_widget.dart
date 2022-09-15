import 'dart:async';

import 'package:flutter/material.dart';
import 'package:new_web/config/all_configs.dart';
import 'package:new_web/util/all_utils.dart';

class DateWidget extends StatefulWidget {
  const DateWidget({Key? key, this.margin}) : super(key: key);

  final EdgeInsetsGeometry? margin;

  @override
  _DateWidgetState createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget> {
  final _current = ValueNotifier(DateTime.now());

  DateTime get current => _current.value;
  late StreamSubscription timerSub;

  @override
  void initState() {
    final timer = Stream.periodic(const Duration(seconds: 1), (i) => i);
    timerSub = timer.listen((data) => _current.value = DateTime.now());
    super.initState();
  }

  @override
  void dispose() {
    timerSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: widget.margin ?? EdgeInsets.only(top: v20, left: v56),
        child: ValueListenableBuilder(
            valueListenable: _current,
            builder: (context, dynamic value, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getDate(value),
                    style: CTextStyle(
                        color: color2,
                        fontSize: v20,
                        height: 1,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: v11),
                  Text(
                    getTime(value),
                    style: CTextStyle(color: color3, fontSize: v15, height: 1),
                  ),
                ],
              );
            }),
      ),
    );
  }

}
