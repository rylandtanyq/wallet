import 'package:get/get.dart';

import 'wallet_mnemonic_backup_logic.dart';

class WalletMnemonicBackupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WalletMnemonicBackupLogic());
  }
}
