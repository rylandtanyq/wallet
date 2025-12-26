import 'package:get/get.dart';

import 'wallet_index_logic.dart';

class WalletIndexBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WalletIndexLogic());
  }
}
