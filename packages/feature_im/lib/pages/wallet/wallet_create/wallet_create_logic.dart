import 'package:flutter/cupertino.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/routes/app_navigator.dart';

class WalletCreateLogic extends GetxController {
  final enabled = false.obs;
  final walletNameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final passwordAgainCtrl = TextEditingController();
  final tipsCtrl = TextEditingController();
  final agree = false.obs;
  FocusNode? walletNameFocus = FocusNode();
  FocusNode? passwordFocus = FocusNode();
  FocusNode? passwordAgainFocus = FocusNode();
  FocusNode? tipsFocus = FocusNode();

  @override
  void onInit() {
    walletNameCtrl.addListener(_onChanged);
    super.onInit();
  }

  @override
  void onClose() {
    walletNameCtrl.dispose();
    passwordCtrl.dispose();
    passwordAgainCtrl.dispose();
    tipsCtrl.dispose();
    super.onClose();
  }
  _onChanged() {
    // enabled.value = walletNameCtrl.text.trim().isNotEmpty &&
    //     passwordCtrl.text.trim().isNotEmpty &&
    //     passwordAgainCtrl.text.trim().isNotEmpty &&
    //     agree.value;
  }
  void changeAgree(){
    agree.value = !agree.value;
  }
  void openPrivacy(){
    print("打开协议");
  }
  void createWallet(){
    AppNavigator.startWalletMnemonic();
  }
}
