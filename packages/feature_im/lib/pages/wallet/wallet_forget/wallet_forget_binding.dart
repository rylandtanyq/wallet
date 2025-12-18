import 'package:get/get.dart';

import 'wallet_forget_logic.dart';

class WalletForgetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WalletForgetLogic());
  }
}
