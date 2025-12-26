import 'package:get/get.dart';

import 'wallet_mnemonic_verify_logic.dart';

class WalletMnemonicVerifyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WalletMnemonicVerifyLogic());
  }
}
