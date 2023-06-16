import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WSToast {
  WSToast._();

  static void show(String msg,
      {ToastGravity gravity = ToastGravity.CENTER,
      String webPosition = 'center'}) {
    Fluttertoast.showToast(
        gravity: gravity,
        webPosition: webPosition,
        webBgColor: 'linear-gradient(to right, #3E4346, #151617)',
        timeInSecForIosWeb: 2,
        toastLength: Toast.LENGTH_LONG,
        msg: msg,
        backgroundColor: Colors.black.withOpacity(0.6));
  }
}
