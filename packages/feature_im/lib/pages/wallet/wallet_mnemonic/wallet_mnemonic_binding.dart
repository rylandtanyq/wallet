import 'package:get/get.dart';

import 'wallet_mnemonic_logic.dart';

class WalletMnemonicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WalletMnemonicLogic());
  }
}
