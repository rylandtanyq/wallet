import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import '../wallet_mnemonic_logic.dart';

class WalletMnemonicBackupLogic extends GetxController {
  final mnemonicList = [].obs;
  final mnemonic = "".obs;
  final wallet = "".obs;
  @override
  void onInit() {
    var arguments = Get.arguments;
    print("获取的助记词：${arguments['mnemonicStr']}");
    print("获取的钱包地址：${arguments['walletAddress']}");
    mnemonic.value = arguments['mnemonicStr'];
    wallet.value = arguments['walletAddress'];
    mnemonicToList();
    super.onInit();
  }
  void mnemonicToList(){
    final rawStr = mnemonic.value;
    List<String> wordList = rawStr.split(' ');
    // 2. 遍历生成 {index:01, value:xxx} 格式的Map列表
    List<Map<String, dynamic>> resultList = wordList.asMap().entries.map((entry) {
      int index = entry.key + 1; // 索引从1开始（对应01、02...）
      String value = entry.value;

      // 补零：确保索引为两位数（01、02...10、11）
      String indexStr = index.toString().padLeft(2, '0');
      return {
        'sort': indexStr,
        'value': value
      };
    }).toList();
    mnemonicList.value = resultList;
  }
  void copyMnemonic(){
    IMUtils.copy(text: mnemonic.value);
  }
  @override
  void onClose() {
    super.onClose();
  }
  void mnemonicVerify(){
    AppNavigator.startWalletmnemonicverify(mnemonicStr: mnemonic.value,
        walletAddress: wallet.value);
  }
}
