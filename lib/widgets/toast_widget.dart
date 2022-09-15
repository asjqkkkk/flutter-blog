import 'package:flutter/material.dart';
import 'package:new_web/config/all_configs.dart';
import 'package:new_web/util/full_screen_dialog_util.dart';

class ToastWidget {
  factory ToastWidget() {
    _instance ??= ToastWidget._internal();
    return _instance!;
  }

  ToastWidget._internal();

  static ToastWidget? _instance;

  bool isShowing = false;

  void _showToast(BuildContext? context, Widget widget, int second) {
    if (!isShowing) {
      isShowing = true;
      FullScreenDialog.getInstance()!.showDialog(
        context!,
        widget,
      );
      Future.delayed(
          Duration(
            seconds: second,
          ), () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          isShowing = false;
        } else {
          isShowing = false;
        }
      });
    }
  }

  void showToast(String text) {
    final widget = Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: v50),
        decoration: BoxDecoration(
            border: Border.all(color: color4, width: v2),
            borderRadius: BorderRadius.all(Radius.circular(
              v4,
            )),
            color: color4),
        width: v100,
        padding: EdgeInsets.fromLTRB(v10, v5, v10, v5),
        child: Material(
          color: Colors.transparent,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: CTextStyle(fontSize: v10, color: Colors.white),
          ),
        ),
      ),
    );
    _showToast(GlobalData.instance.context, widget, 1);
  }
}
