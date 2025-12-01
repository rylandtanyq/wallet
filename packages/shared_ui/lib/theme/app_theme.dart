import 'package:flutter/material.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'app_colors.dart';

class AppTheme {
  /// 日间主题
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColor.primary,
    colorScheme: AppColor.lightScheme,
    scaffoldBackgroundColor: AppColor.lightBackground,
    cardColor: AppColor.lightCard,
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headline1.copyWith(color: AppColor.lightPrimaryText),
      headlineMedium: AppTextStyles.headline2.copyWith(color: AppColor.lightPrimaryText),
      headlineSmall: AppTextStyles.headline3.copyWith(color: AppColor.lightPrimaryText),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColor.lightPrimaryText),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColor.lightPrimaryText),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColor.lightPrimaryText),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColor.lightPrimaryText),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColor.lightPrimaryText),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColor.lightPrimaryText),
    ),
    appBarTheme: AppBarTheme(backgroundColor: AppColor.lightAppBar, foregroundColor: AppColor.lightScheme.onBackground, elevation: 0),
  );

  /// 夜间主题
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColor.primary,
    colorScheme: AppColor.darkScheme,
    scaffoldBackgroundColor: AppColor.darkBackground,
    cardColor: AppColor.darkCard,
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headline1.copyWith(color: AppColor.darkPrimaryText),
      headlineMedium: AppTextStyles.headline2.copyWith(color: AppColor.darkPrimaryText),
      headlineSmall: AppTextStyles.headline3.copyWith(color: AppColor.darkPrimaryText),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColor.darkPrimaryText),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColor.darkPrimaryText),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColor.darkPrimaryText),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColor.darkPrimaryText),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColor.darkPrimaryText),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColor.darkPrimaryText),
    ),
    appBarTheme: AppBarTheme(backgroundColor: AppColor.darkAppBar, foregroundColor: AppColor.darkScheme.onBackground, elevation: 0),
  );
}
