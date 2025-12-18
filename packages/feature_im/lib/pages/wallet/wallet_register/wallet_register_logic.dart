import 'package:flutter/cupertino.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim/core/controller/im_controller.dart';

class WalletRegisterLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final wallet = "".obs;
  final enabled = false.obs;
  final walletAddressCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final passwordAgainCtrl = TextEditingController();
  final agree = false.obs;
  FocusNode? walletAddressFocus = FocusNode();
  FocusNode? usernameFocus = FocusNode();
  FocusNode? passwordFocus = FocusNode();
  FocusNode? passwordAgainFocus = FocusNode();
  @override
  void onInit() {
    var arguments = Get.arguments;
    wallet.value = arguments['walletAddress'];
    walletAddressCtrl.text = wallet.value;
    walletAddressCtrl.addListener(_onChanged);
    usernameCtrl.addListener(_onChanged);
    passwordCtrl.addListener(_onChanged);
    passwordAgainCtrl.addListener(_onChanged);
    super.onInit();
  }
  @override
  void onClose() {
    walletAddressCtrl.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    passwordAgainCtrl.dispose();
    super.onClose();
  }
  _onChanged() {
    enabled.value = walletAddressCtrl.text.trim().isNotEmpty &&
        usernameCtrl.text.trim().isNotEmpty &&
        passwordCtrl.text.trim().isNotEmpty &&
        passwordAgainCtrl.text.trim().isNotEmpty;
  }
  void changeAgree(){
    agree.value = !agree.value;
  }
  void openPrivacy(){
    print("打开协议");
  }
  bool _checkingInput() {
    if (walletAddressCtrl.text.trim().isEmpty) {
      IMViews.showToast("请输入钱包地址");
      return false;
    }
    if (usernameCtrl.text.trim().isEmpty) {
      IMViews.showToast("请输入用户名");
      return false;
    }
    if (!IMUtils.isValidPassword(passwordCtrl.text)) {
      IMViews.showToast(StrRes.wrongPasswordFormat);
      return false;
    } else if (passwordCtrl.text != passwordAgainCtrl.text) {
      IMViews.showToast(StrRes.twicePwdNoSame);
      return false;
    }
    if(!agree.value){
       IMViews.showToast("请阅读并同意用户协议");
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
      final data = await Apis.register(
        nickname: "",
        areaCode: "",
        phoneNumber: "",
        email: usernameCtrl.text.trim(),
        account: walletAddressCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
        verificationCode: "",
        invitationCode: "",
      );
      if (null == IMUtils.emptyStrToNull(data.imToken) ||
          null == IMUtils.emptyStrToNull(data.chatToken)) {
        AppNavigator.startLogin();
        return;
      }
      final account = {
        "areaCode": "",
        "phoneNumber": "",
        'email': usernameCtrl.text.trim()
      };
      await DataSp.putLoginCertificate(data);
      await DataSp.putLoginAccount(account);
      await imLogic.login(data.userID, data.imToken);
      Logger.print('---------im login success-------');
      PushController.login(
        data.userID,
        onTokenRefresh: (token) {
          OpenIM.iMManager.updateFcmToken(
              fcmToken: token,
              expireTime: DateTime.now()
                  .add(Duration(days: 90))
                  .millisecondsSinceEpoch);
        },
      );
      Logger.print('---------jpush login success----');
    });
    AppNavigator.startMain();
  }
}
