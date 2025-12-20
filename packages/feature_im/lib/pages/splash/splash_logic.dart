import 'dart:async';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:feature_im/pages/conversation/conversation_logic.dart';
import 'package:openim_common/openim_common.dart';

import '../../core/controller/im_controller.dart';
import '../../routes/app_navigator.dart';

class SplashLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final pushLogic = Get.find<PushController>();

  String? get userID => DataSp.userID;
  String? get token => DataSp.imToken;

  late StreamSubscription initializedSub;
  Timer? _timeout;
  bool _handled = false;

  @override
  void onInit() {
    Logger.print('---------login---------- userID: $userID, token: $token');

    // 超时兜底, 防止 SDK 初始化一直不回调导致卡 splash
    _timeout = Timer(const Duration(seconds: 8), () {
      if (_handled) return;
      _handled = true;
      Logger.print('initOpenIM timeout -> go login', isError: true);
      AppNavigator.startLogin();
    });

    initializedSub = imLogic.initializedSubject.listen((inited) {
      if (_handled) return;

      // 冷启动时 inited 可能先是 null/false（表示还没初始化完）
      if (inited != true) {
        Logger.print('openim not ready yet: $inited');
        return; // 继续等 true
      }

      // 只有 true 才做路由决策
      _handled = true;
      _timeout?.cancel();

      if (userID != null && token != null) {
        _login();
      } else {
        AppNavigator.startLogin();
      }
    });

    // 触发初始化
    imLogic.initOpenIM();
    super.onInit();
  }

  Future<void> _login() async {
    try {
      Logger.print('---------_login---------- userID: $userID');
      await imLogic.login(userID!, token!);
      Logger.print('---------im login success-------');

      // push/拉会话失败不要影响进首页(避免误删凭证/回登录)
      try {
        PushController.login(
          userID!,
          onTokenRefresh: (token) {
            OpenIM.iMManager.updateFcmToken(
              fcmToken: token,
              expireTime: DateTime.now().add(const Duration(days: 90)).millisecondsSinceEpoch,
            );
          },
        );
      } catch (e, s) {
        Logger.print('push init failed (ignored): $e\n$s', isError: true);
      }

      dynamic conversations;
      try {
        conversations = await ConversationLogic.getConversationFirstPage();
      } catch (e, s) {
        Logger.print('getConversationFirstPage failed (ignored): $e\n$s', isError: true);
        conversations = null;
      }

      AppNavigator.startSplashToMain(isAutoLogin: true, conversations: conversations);
    } catch (e, s) {
      Logger.print('im login failed: $e\n$s', isError: true);
      await DataSp.removeLoginCertificate();
      AppNavigator.startLogin();
    }
  }

  @override
  void onClose() {
    _timeout?.cancel();
    initializedSub.cancel();
    super.onClose();
  }
}
