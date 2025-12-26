import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:feature_im/routes/app_navigator.dart';

class WalletIndexLogic extends GetxController {
  void viewWalletCreate() => AppNavigator.startWalletMnemonic();
  void viewWalletImport() => AppNavigator.startWalletImport();
  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
