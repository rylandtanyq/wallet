import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:feature_im/routes/app_navigator.dart';
import 'package:feature_im/core/controller/im_controller.dart';

class WalletImportLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final wallet = AdvancedMultiChainWallet();
  final enabled = false.obs;
  final mnemonicCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final passwordAgainCtrl = TextEditingController();
  final agree = false.obs;
  FocusNode? mnemonicFocus = FocusNode();
  FocusNode? usernameFocus = FocusNode();
  FocusNode? passwordFocus = FocusNode();
  FocusNode? passwordAgainFocus = FocusNode();
  final walletAddress = "".obs;

  @override
  void onInit() {
    mnemonicCtrl.addListener(_onChanged);
    usernameCtrl.addListener(_onChanged);
    passwordCtrl.addListener(_onChanged);
    passwordAgainCtrl.addListener(_onChanged);
    super.onInit();
  }

  @override
  void onClose() {
    mnemonicCtrl.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    passwordAgainCtrl.dispose();
    super.onClose();
  }

  _onChanged() {
    enabled.value = mnemonicCtrl.text.trim().isNotEmpty &&
        usernameCtrl.text.trim().isNotEmpty &&
        passwordCtrl.text.trim().isNotEmpty &&
        passwordAgainCtrl.text.trim().isNotEmpty;
  }

  void changeAgree() {
    agree.value = !agree.value;
  }

  void openPrivacy() {
    print("打开协议");
  }

  void pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null || clipboardData!.text!.isNotEmpty) {
      // 剪贴板为空时提示
      mnemonicCtrl.text = clipboardData!.text!;
      return;
    }
  }

  bool _checkingInput() {
    if (mnemonicCtrl.text.trim().isEmpty) {
      IMViews.showToast(StrRes.walletImportMnemonicError);
      return false;
    }
    if (usernameCtrl.text.trim().isEmpty) {
      IMViews.showToast(StrRes.walletImportUserNamePlace);
      return false;
    }
    if (!IMUtils.isValidPassword(passwordCtrl.text)) {
      IMViews.showToast(StrRes.wrongPasswordFormat);
      return false;
    } else if (passwordCtrl.text != passwordAgainCtrl.text) {
      IMViews.showToast(StrRes.twicePwdNoSame);
      return false;
    }
    if (!agree.value) {
      IMViews.showToast(StrRes.walletImportPrivacyError);
      return false;
    }
    return true;
  }

  void nextStep() {
    if (_checkingInput()) {
      register();
    }
  }

  void register() async {
    await LoadingView.singleton.wrap(asyncFunction: () async {
      // 1. 初始化钱包
      await wallet.initialize(networkId: 'solana');
      final newWallet = await wallet.restoreFromMnemonic(mnemonicCtrl.text);
      if (newWallet != null && newWallet["currentAddress"] != null) {
        walletAddress.value = newWallet["currentAddress"]!;
      }
    });
    if (walletAddress.value.isEmpty) {
      IMViews.showToast(StrRes.walletImportError);
      return;
    }
    await LoadingView.singleton.wrap(asyncFunction: () async {
      final data = await Apis.register(
        nickname: "",
        areaCode: "",
        phoneNumber: "",
        email: usernameCtrl.text.trim(),
        account: walletAddress.value,
        password: passwordCtrl.text.trim(),
        verificationCode: "",
        invitationCode: "",
      );
      if (null == IMUtils.emptyStrToNull(data.imToken) || null == IMUtils.emptyStrToNull(data.chatToken)) {
        AppNavigator.startLogin();
        return;
      }
      final account = {"areaCode": "", "phoneNumber": "", 'email': usernameCtrl.text.trim()};
      await DataSp.putLoginCertificate(data);
      await DataSp.putLoginAccount(account);
      await imLogic.login(data.userID, data.imToken);
      Logger.print('---------im login success-------');
      PushController.login(
        data.userID,
        onTokenRefresh: (token) {
          OpenIM.iMManager.updateFcmToken(fcmToken: token, expireTime: DateTime.now().add(Duration(days: 90)).millisecondsSinceEpoch);
        },
      );
      Logger.print('---------jpush login success----');
    });
    AppNavigator.startMain();
  }
}
