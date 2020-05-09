import 'package:flutter/material.dart';
import '../config/full_screen_dialog_util.dart';

class ToastWidget{

  ToastWidget._internal();

  static ToastWidget _instance;

  factory ToastWidget(){
    _instance ??= ToastWidget._internal();
    return _instance;
  }

  bool isShowing = false;

  void showToast(BuildContext context, Widget widget, int second) {
    if(!isShowing){
      isShowing = true;
      FullScreenDialog.getInstance().showDialog(
        context,
        widget,
      );
      Future.delayed(Duration(seconds: second,),(){
        if(Navigator.of(context).canPop()){
          Navigator.of(context).pop();
          isShowing = false;
        } else{
          isShowing = false;
        }
      });
    }
  }

}