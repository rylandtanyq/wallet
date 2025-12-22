import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:feature_im/pages/home/home_binding.dart';
import 'package:openim_common/openim_common.dart';

import 'core/controller/im_controller.dart';
import 'routes/app_pages.dart';
import 'widgets/app_view.dart';

class ChatApp extends StatefulWidget {
  const ChatApp({Key? key}) : super(key: key);

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  late final GlobalKey<NavigatorState> _imNavKey = GlobalKey<NavigatorState>(debugLabel: 'im_nav_${DateTime.now().microsecondsSinceEpoch}');
  late final GlobalKey<ScaffoldMessengerState> _imMsgKey =
      GlobalKey<ScaffoldMessengerState>(debugLabel: 'im_msg_${DateTime.now().microsecondsSinceEpoch}');

  late final Key _appKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return AppView(
      builder: (locale, outerBuilder) => GetMaterialApp(
        key: _appKey,
        navigatorKey: _imNavKey,
        scaffoldMessengerKey: _imMsgKey,
        debugShowCheckedModeBanner: false,
        enableLog: true,
        builder: (ctx, child) {
          final built = outerBuilder(ctx, child);

          return WillPopScope(
            onWillPop: () async {
              final nav = _imNavKey.currentState;
              if (nav != null && await nav.maybePop()) {
                return false; // 已处理，不要退出 ChatApp
              }

              Navigator.of(ctx, rootNavigator: true).pop();
              return false;
            },
            child: built,
          );
        },
        logWriterCallback: (text, {bool isError = false}) {
          Logger.print(text, isError: isError, onlyConsole: true);
        },
        translations: TranslationService(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        fallbackLocale: TranslationService.fallbackLocale,
        locale: locale,
        localeResolutionCallback: (locale, list) {
          Get.locale ??= locale;
          return locale;
        },
        supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
        getPages: AppPages.routes,
        initialBinding: InitBinding(),
        initialRoute: AppRoutes.splash,
        theme: _themeData,
      ),
    );
  }

  ThemeData get _themeData => ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey.shade50,
        canvasColor: Colors.white,
        appBarTheme: const AppBarTheme(color: Colors.white),
        textSelectionTheme: const TextSelectionThemeData().copyWith(cursorColor: Colors.blue),
        checkboxTheme: const CheckboxThemeData().copyWith(
          checkColor: WidgetStateProperty.all(Colors.white),
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return Colors.grey;
            if (states.contains(WidgetState.selected)) return Colors.blue;
            return Colors.white;
          }),
          side: BorderSide(color: Colors.grey.shade500, width: 1),
        ),
        dialogTheme: const DialogThemeData().copyWith(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            textStyle: WidgetStatePropertyAll(
              TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
              ),
            ),
            foregroundColor: const WidgetStatePropertyAll(Colors.black),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData().copyWith(
          color: Colors.white,
          linearTrackColor: Colors.grey,
          circularTrackColor: Colors.grey,
        ),
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: CupertinoColors.systemBlue,
          barBackgroundColor: Colors.white,
          applyThemeToAll: true,
          textTheme: const CupertinoTextThemeData().copyWith(
            navActionTextStyle: const TextStyle(color: CupertinoColors.label),
            actionTextStyle: const TextStyle(color: CupertinoColors.systemBlue),
            textStyle: const TextStyle(color: CupertinoColors.label),
            navLargeTitleTextStyle: const TextStyle(color: CupertinoColors.label),
            navTitleTextStyle: const TextStyle(color: CupertinoColors.label),
            pickerTextStyle: const TextStyle(color: CupertinoColors.label),
            tabLabelTextStyle: const TextStyle(color: CupertinoColors.label),
            dateTimePickerTextStyle: const TextStyle(color: CupertinoColors.label),
          ),
        ),
      );
}

class InitBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<IMController>()) {
      Get.put<IMController>(IMController(), permanent: true);
    }
    if (!Get.isRegistered<PushController>()) {
      Get.put<PushController>(PushController(), permanent: true);
    }
    if (!Get.isRegistered<CacheController>()) {
      Get.put<CacheController>(CacheController(), permanent: true);
    }
    if (!Get.isRegistered<DownloadController>()) {
      Get.put<DownloadController>(DownloadController(), permanent: true);
    }

    if (!Get.isRegistered<HomeBinding>()) {
      final homeBinding = HomeBinding();
      Get.lazyPut<HomeBinding>(() => homeBinding, fenix: true);
      homeBinding.dependencies();
    }
  }
}
