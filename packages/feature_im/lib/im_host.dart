import 'package:flutter/material.dart';

class IMHost {
  IMHost._();

  /// IM 内部导航
  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>(debugLabel: 'im_nav');

  static final GlobalKey<ScaffoldMessengerState> msgKey = GlobalKey<ScaffoldMessengerState>(debugLabel: 'im_msg');

  static const Key appKey = ValueKey('im_get_app');
}
