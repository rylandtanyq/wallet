import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:feature_im/pages/mine/server_config/server_config_binding.dart';
import 'package:feature_im/pages/mine/server_config/server_config_view.dart';
import 'package:openim_common/openim_common.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/controller/im_controller.dart';
import '../../routes/app_navigator.dart';
import '../conversation/conversation_logic.dart';

enum LoginType {
  account(0),
  email(1),
  phone(2);

  final int rawValue;

  const LoginType(this.rawValue);

  static LoginType fromRawValue(int rawValue) {
    return values.firstWhere((e) => e.rawValue == rawValue);
  }
}

extension LoginTypeExt on LoginType {
  String get name {
    switch (this) {
      case LoginType.phone:
        return StrRes.phoneNumber;
      case LoginType.email:
        return "用户名";
      case LoginType.account:
        return "钱包地址";
    }
  }

  String get hintText {
    switch (this) {
      case LoginType.phone:
        return StrRes.plsEnterPhoneNumber;
      case LoginType.email:
        return "请输入用户名";
      case LoginType.account:
        return "请输入钱包地址";
    }
  }

  String get exclusiveName {
    switch (this) {
      case LoginType.phone:
        return StrRes.email;
      case LoginType.email:
        return "用户名";
      case LoginType.account:
        return "钱包地址";
    }
  }
}

class LoginLogic extends GetxController with GetTickerProviderStateMixin {
  final imLogic = Get.find<IMController>();
  final phoneCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();
  final verificationCodeCtrl = TextEditingController();
  final obscureText = true.obs;
  final enabled = false.obs;
  final areaCode = "+86".obs;
  final isPasswordLogin = true.obs;
  final versionInfo = ''.obs;
  final loginType = LoginType.phone.obs;

  final List<String> removeType = ["LoginType.phone"];

  String? get email => loginType.value == LoginType.email ? phoneCtrl.text.trim() : null;
  String? get phone => loginType.value == LoginType.phone ? phoneCtrl.text.trim() : null;
  String? get account => loginType.value == LoginType.account ? phoneCtrl.text.trim() : null;
  LoginType operateType = LoginType.phone;

  FocusNode? accountFocus = FocusNode();
  FocusNode? pwdFocus = FocusNode();
  late TabController tabController;
  _initData() async {
    var map = DataSp.getLoginAccount();
    if (map is Map) {
      String? phoneNumber = map["phoneNumber"];
      String? areaCode = map["areaCode"];

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        phoneCtrl.text = phoneNumber;
      }
      if (areaCode != null && areaCode.isNotEmpty) {
        this.areaCode.value = areaCode;
      }
    }
    loginType.value = LoginType.fromRawValue(DataSp.getLoginType());
    operateType = loginType.value;
    tabController.index = loginType.value.rawValue;
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    pwdCtrl.dispose();
    verificationCodeCtrl.dispose();
    tabController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    if (removeType.length == 0) {
      tabController = TabController(length: 3, vsync: this);
    } else {
      tabController = TabController(length: 2, vsync: this);
    }
    _initData();
    phoneCtrl.addListener(_onChanged);
    pwdCtrl.addListener(_onChanged);
    verificationCodeCtrl.addListener(_onChanged);
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    getPackageInfo();
  }

  List<String> getTabsList() {
    List<String> tabsList = [];
    for (var e in LoginType.values) {
      if (!removeType.contains(e.toString())) {
        String name = e.name;
        tabsList.add(name);
      }
    }
    return tabsList;
  }

  _onChanged() {
    if (loginType.value == LoginType.account) {
      enabled.value = phoneCtrl.text.trim().isNotEmpty && pwdCtrl.text.trim().isNotEmpty;
    } else if (loginType.value == LoginType.email) {
      enabled.value = phoneCtrl.text.trim().isNotEmpty && pwdCtrl.text.trim().isNotEmpty;
    } else {
      enabled.value = isPasswordLogin.value && phoneCtrl.text.trim().isNotEmpty && pwdCtrl.text.trim().isNotEmpty ||
          !isPasswordLogin.value && phoneCtrl.text.trim().isNotEmpty && verificationCodeCtrl.text.trim().isNotEmpty;
    }
  }

  login() {
    DataSp.putLoginType(loginType.value.rawValue);
    LoadingView.singleton.wrap(asyncFunction: () async {
      var suc = await _login();
      if (suc) {
        final result = await ConversationLogic.getConversationFirstPage();

        Get.find<CacheController>().resetCache();
        AppNavigator.startMain(conversations: result);
      }
    });
  }

  Future<bool> _login() async {
    try {
      print(loginType.value);
      if (loginType.value == LoginType.phone) {
        if (phone?.isNotEmpty == true && !IMUtils.isMobile(areaCode.value, phoneCtrl.text)) {
          IMViews.showToast(StrRes.plsEnterRightPhone);
          return false;
        }
      } else if (loginType.value == LoginType.email) {
        if (email?.isNotEmpty == false) {
          IMViews.showToast("请输入用户名");
          return false;
        }
      } else if (loginType.value == LoginType.account) {
        if (this.account?.isNotEmpty == false) {
          IMViews.showToast("请输入钱包地址");
          return false;
        }
      }
      final password = IMUtils.emptyStrToNull(pwdCtrl.text);
      final code = IMUtils.emptyStrToNull(verificationCodeCtrl.text);
      final data = await Apis.login(
        areaCode: areaCode.value,
        phoneNumber: phone,
        account: this.account,
        email: email,
        password: isPasswordLogin.value ? password : null,
        verificationCode: "",
      );
      final account = {"areaCode": "", "phoneNumber": "", 'email': email, 'account': this.account, 'loginType': loginType.value.rawValue};
      await DataSp.putLoginCertificate(data);
      await DataSp.putLoginAccount(account);
      Logger.print('login : ${data.userID}, token: ${data.imToken}');
      await imLogic.login(data.userID, data.imToken);
      Logger.print('im login success');
      PushController.login(
        data.userID,
        onTokenRefresh: (token) {
          OpenIM.iMManager.updateFcmToken(fcmToken: token, expireTime: DateTime.now().add(Duration(days: 90)).millisecondsSinceEpoch);
        },
      );
      Logger.print('push login success');
      return true;
    } catch (e, s) {
      Logger.print('login e: $e $s');
    }
    return false;
  }

  void togglePasswordType() {
    isPasswordLogin.value = !isPasswordLogin.value;
  }

  void toggleLoginType() {
    if (loginType.value == LoginType.phone) {
      loginType.value = LoginType.email;
    } else {
      loginType.value = LoginType.phone;
    }

    phoneCtrl.text = '';
  }

  Future<bool> getVerificationCode() async {
    if (phone?.isNotEmpty == true && !IMUtils.isMobile(areaCode.value, phoneCtrl.text)) {
      IMViews.showToast(StrRes.plsEnterRightPhone);
      return false;
    }

    if (email?.isNotEmpty == true && !phoneCtrl.text.isEmail) {
      IMViews.showToast(StrRes.plsEnterRightEmail);
      return false;
    }

    return sendVerificationCode();
  }

  /// [usedFor] 1：注册，2：重置密码 3：登录
  Future<bool> sendVerificationCode() => LoadingView.singleton.wrap(
      asyncFunction: () => Apis.requestVerificationCode(
            areaCode: areaCode.value,
            phoneNumber: phone,
            email: email,
            usedFor: 3,
          ));

  void openCountryCodePicker() async {
    String? code = await IMViews.showCountryCodePicker();
    if (null != code) areaCode.value = code;
  }

  void configService() => Get.to(
        () => ServerConfigPage(),
        binding: ServerConfigBinding(),
      );

  void registerNow() => AppNavigator.startRegister();

  void forgetPassword() => AppNavigator.startForgetPassword();

  void forgetWallet() => AppNavigator.startWalletForget();

  void registerWallet() => AppNavigator.startWalletIndex();

  void getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;
    final appName = packageInfo.appName;
    final buildNumber = packageInfo.buildNumber;

    versionInfo.value = '$appName $version+$buildNumber SDK: ${OpenIM.version}';
  }
}
