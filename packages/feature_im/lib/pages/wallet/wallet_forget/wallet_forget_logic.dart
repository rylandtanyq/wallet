import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim/core/controller/im_controller.dart';

class WalletForgetLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final wallet = AdvancedMultiChainWallet();
  final enabled = false.obs;
  final mnemonicCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final passwordAgainCtrl = TextEditingController();
  final agree = false.obs;
  FocusNode? mnemonicFocus = FocusNode();
  FocusNode? passwordFocus = FocusNode();
  FocusNode? passwordAgainFocus = FocusNode();
  final walletAddress = "".obs;

  @override
  void onInit() {
    mnemonicCtrl.addListener(_onChanged);
    passwordCtrl.addListener(_onChanged);
    passwordAgainCtrl.addListener(_onChanged);
    super.onInit();
  }

  @override
  void onClose() {
    mnemonicCtrl.dispose();
    passwordCtrl.dispose();
    passwordAgainCtrl.dispose();
    super.onClose();
  }

  _onChanged() {
    enabled.value = mnemonicCtrl.text.trim().isNotEmpty &&
        passwordCtrl.text.trim().isNotEmpty &&
        passwordAgainCtrl.text.trim().isNotEmpty;
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
      IMViews.showToast("请输入助记词");
      return false;
    }
    if (!IMUtils.isValidPassword(passwordCtrl.text)) {
      IMViews.showToast(StrRes.wrongPasswordFormat);
      return false;
    } else if (passwordCtrl.text != passwordAgainCtrl.text) {
      IMViews.showToast(StrRes.twicePwdNoSame);
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
      if(newWallet!=null && newWallet["currentAddress"]!=null){
        walletAddress.value = newWallet["currentAddress"]!;
      }
    });
    if(walletAddress.value.isEmpty){
      IMViews.showToast("助记词导入失败");
      return;
    }
    await LoadingView.singleton.wrap(asyncFunction: () async {
      final data = await Apis.resetPassword(
        areaCode: "",
        phoneNumber: "",
        email: "",
        account: walletAddress.value,
        password: passwordCtrl.text.trim(),
        verificationCode: "",
      );
      Logger.print('---------jpush login success----');
    });
    IMViews.showToast(StrRes.changedSuccessfully);
    AppNavigator.startBackLogin();
  }
}
