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
  bool _handled = false;

  @override
  void onInit() {
    initializedSub = imLogic.initializedSubject.listen((inited) {
      if (_handled) return;

      if (inited != true) {
        _handled = true;
        AppNavigator.startLogin();
        return;
      }

      if (userID != null && token != null) {
        _handled = true;
        _login();
      } else {
        _handled = true;
        AppNavigator.startLogin();
      }
    });

    // ✅ 关键：每次进 Splash 主动触发一次
    // - 第一次：会真正initSDK并emit
    // - 第二次：会走你上面“重放状态”的逻辑，立刻emit true
    imLogic.initOpenIM();

    super.onInit();
  }

  _login() async {
    try {
      Logger.print('---------login---------- userID: $userID, token: $token');
      await imLogic.login(userID!, token!);
      Logger.print('---------im login success-------');
      PushController.login(
        userID!,
        onTokenRefresh: (token) {
          OpenIM.iMManager.updateFcmToken(fcmToken: token, expireTime: DateTime.now().add(Duration(days: 90)).millisecondsSinceEpoch);
        },
      );
      Logger.print('---------push login success----');
      final result = await ConversationLogic.getConversationFirstPage();

      AppNavigator.startSplashToMain(isAutoLogin: true, conversations: result);
    } catch (e, s) {
      IMViews.showToast('$e $s');
      await DataSp.removeLoginCertificate();
      AppNavigator.startLogin();
    }
  }

  @override
  void onClose() {
    initializedSub.cancel();
    super.onClose();
  }
}
