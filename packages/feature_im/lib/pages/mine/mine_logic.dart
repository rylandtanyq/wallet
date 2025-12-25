import 'dart:async';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:feature_im/core/im_callback.dart';
import 'package:feature_im/pages/home/home_logic.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_meeting/openim_meeting.dart';

import '../../core/controller/app_controller.dart';
import '../../core/controller/im_controller.dart';
import '../../routes/app_navigator.dart';
import '../../im_host.dart';

class MineLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final appLogic = Get.find<AppController>();

  late StreamSubscription kickedOfflineSub;

  void viewMyQrcode() => AppNavigator.startMyQrcode();

  void viewMyInfo() => AppNavigator.startMyInfo();
  void copyID() {
    IMUtils.copy(text: imLogic.userInfo.value.userID!);
  }

  void copyAddress() {
    IMUtils.copy(text: imLogic.userInfo.value.account!);
  }

  void accountSetup() => AppNavigator.startAccountSetup();

  void aboutUs() => AppNavigator.startAboutUs();

  void checkUpdate() {
    appLogic.checkUpdateNew();
  }

  Future<void> logout() async {
    final confirm = await Get.dialog<bool>(
      CustomDialog(title: StrRes.logoutHint),
      navigatorKey: IMHost.navKey,
    );
    if (confirm == true) {
      _logoutHelper();
    }
  }

  Future<void> kickedOffline({String? tips}) async {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }

    Get.snackbar(StrRes.accountWarn, tips ?? StrRes.accountException);
    _logoutHelper(false);
  }

  Future<void> _logoutHelper([bool requireLogout = true]) async {
    MeetingClient().forceClose();
    await imLogic.forceHunup();
    DataSp.removeLoginCertificate();

    try {
      await LoadingView.singleton.wrap(asyncFunction: () async {
        if (requireLogout) {
          await imLogic.logout();
        }
        PushController.logout();
      });
    } catch (e) {
      Logger.print('Logout failed: $e');
    } finally {
      _resetAppState();
    }
  }

  void _resetAppState() {
    Get.find<HomeLogic>().conversationsAtFirstPage.clear();
    AppNavigator.startLogin();
  }

  @override
  void onInit() {
    kickedOfflineSub = imLogic.onKickedOfflineSubject.listen((value) {
      if (value == KickoffType.userTokenInvalid) {
        kickedOffline(tips: StrRes.tokenInvalid);
      } else {
        kickedOffline();
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    kickedOfflineSub.cancel();
    super.onClose();
  }
}
