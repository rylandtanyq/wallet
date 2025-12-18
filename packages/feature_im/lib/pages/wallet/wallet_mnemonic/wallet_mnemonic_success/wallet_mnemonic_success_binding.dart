import 'package:get/get.dart';

import 'wallet_mnemonic_success_logic.dart';

class WalletMnemonicSuccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WalletMnemonicSuccessLogic());
  }
}
