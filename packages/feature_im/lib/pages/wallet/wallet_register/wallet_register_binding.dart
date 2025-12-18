import 'package:get/get.dart';

import 'wallet_register_logic.dart';

class WalletRegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WalletRegisterLogic());
  }
}
