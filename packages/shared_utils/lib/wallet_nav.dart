import 'package:flutter/material.dart';

class WalletNav {
  WalletNav._();

  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>(debugLabel: 'wallet_nav');

  static NavigatorState? get _nav => key.currentState;

  static Route<T> _route<T>(
    Widget page, {
    Object? arguments,
    Duration duration = const Duration(milliseconds: 300),
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: page.runtimeType.toString(), arguments: arguments),
      fullscreenDialog: fullscreenDialog,
      maintainState: maintainState,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Get.to - push
  static Future<T?> to<T>(
    Widget page, {
    Object? arguments,
    Duration duration = const Duration(milliseconds: 300),
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
    final nav = _nav;
    if (nav == null) return Future.value(null);
    return nav.push<T>(_route<T>(page, arguments: arguments, duration: duration, fullscreenDialog: fullscreenDialog, maintainState: maintainState));
  }

  /// Get.off - pushReplacement
  static Future<T?> off<T, TO extends Object?>(
    Widget page, {
    Object? arguments,
    Duration duration = const Duration(milliseconds: 300),
    bool fullscreenDialog = false,
    bool maintainState = true,
    TO? result,
  }) {
    final nav = _nav;
    if (nav == null) return Future.value(null);
    return nav.pushReplacement<T, TO>(
      _route<T>(page, arguments: arguments, duration: duration, fullscreenDialog: fullscreenDialog, maintainState: maintainState),
      result: result,
    );
  }

  /// Get.offAll - pushAndRemoveUntil (清栈)
  static Future<T?> offAll<T>(
    Widget page, {
    Object? arguments,
    Duration duration = const Duration(milliseconds: 300),
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
    final nav = _nav;
    if (nav == null) return Future.value(null);
    return nav.pushAndRemoveUntil<T>(
      _route<T>(page, arguments: arguments, duration: duration, fullscreenDialog: fullscreenDialog, maintainState: maintainState),
      (route) => false,
    );
  }

  /// Get.back
  static void back<T extends Object?>([T? result]) => _nav?.pop(result);

  /// pop 到某个条件
  static void backUntil(bool Function(Route<dynamic>) predicate) {
    _nav?.popUntil(predicate);
  }

  /// pop 到首页（通常是第一个 route）
  static void backToRoot() {
    _nav?.popUntil((r) => r.isFirst);
  }

  /// 命名路由（可选）
  static Future<T?> toNamed<T>(String routeName, {Object? arguments}) {
    final nav = _nav;
    if (nav == null) return Future.value(null);
    return nav.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> offNamed<T, TO extends Object?>(String routeName, {Object? arguments, TO? result}) {
    final nav = _nav;
    if (nav == null) return Future.value(null);
    return nav.pushReplacementNamed<T, TO>(routeName, arguments: arguments, result: result);
  }

  static Future<T?> offAllNamed<T>(String routeName, {Object? arguments}) {
    final nav = _nav;
    if (nav == null) return Future.value(null);
    return nav.pushNamedAndRemoveUntil<T>(routeName, (r) => false, arguments: arguments);
  }
}
