// 全局按钮样式
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const ButtonStyle appFilledButtonStyle = ButtonStyle(
  backgroundColor: MaterialStatePropertyAll(Colors.white),
  shape: MaterialStatePropertyAll(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(18)),
      side: BorderSide(color: Colors.grey, width: 1.0),
    ),
  ),
  padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 5)),
);