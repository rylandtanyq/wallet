import 'package:get/get.dart';

import 'wallet_import_logic.dart';

class WalletImportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WalletImportLogic());
  }
}
