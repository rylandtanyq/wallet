import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:feature_im/routes/app_navigator.dart';

class WalletMnemonicSuccessLogic extends GetxController {
  final wallet = "".obs;
  @override
  void onInit() {
    var arguments = Get.arguments;
    wallet.value = arguments['walletAddress'];
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void viewWalletRegister() => AppNavigator.startWalletRegister(walletAddress: wallet.value);
}
