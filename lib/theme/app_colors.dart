import 'package:flutter/material.dart';

class AppColor {
  // 通用颜色, 不随主题变化
  static const Color primary = Color(0xFF286713);

  // 日间模式颜色
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightPrimaryText = Color(0xFF000000);
  static const Color lightSecondaryText = Color(0xFF757F7F);
  static const Color lightCard = Color(0xFFF6F6F6);
  static const Color lightSurface = Color(0xFFF6F6F6);
  // appbar 日间颜色
  static const Color lightAppBar = Color(0xFFFFFFFF);

  // 夜间模式主题
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkPrimaryText = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFF757F7F);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkSurface = Color(0xFF1E1E1E);
  // appbar 夜间颜色
  static const Color darkAppBar = Color(0xFF000000);

  /// 日间主题色板
  static final ColorScheme lightScheme = ColorScheme.light(
    primary: primary, // 按钮底色
    onPrimary: Colors.white, // 按钮上的文字颜色
    secondary: Colors.teal, // 次级颜色
    onSecondary: Colors.white, // 次级颜色文字颜色
    background: lightBackground, // 页面背景
    onBackground: lightPrimaryText, // 背景上的文字颜色
    surface: lightSurface, // 卡片
    onSurface: lightSecondaryText, // 卡片上的文字颜色
    error: Colors.red, // 错误或者提示信息
    onError: Colors.white, // 错误或者提示信息的文字颜色
  );

  /// 夜间主题色板
  static final ColorScheme darkScheme = ColorScheme.dark(
    primary: primary,
    onPrimary: Colors.white,
    secondary: Colors.teal,
    onSecondary: Colors.black,
    background: darkBackground,
    onBackground: darkPrimaryText,
    surface: darkSurface,
    onSurface: darkSecondaryText,
    error: Colors.red,
    onError: Colors.white,
  );
}
