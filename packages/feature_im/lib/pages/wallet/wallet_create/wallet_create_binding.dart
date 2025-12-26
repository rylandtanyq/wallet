import 'package:get/get.dart';

import 'wallet_create_logic.dart';

class WalletCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WalletCreateLogic());
  }
}
