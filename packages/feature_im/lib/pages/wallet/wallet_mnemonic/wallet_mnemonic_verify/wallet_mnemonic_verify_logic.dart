import 'dart:math';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';

class WalletMnemonicVerifyLogic extends GetxController {
  final mnemonicList = [].obs;
  final mnemonic = "".obs;
  final wallet = "".obs;
  final mnemonicVerifyList = [].obs;
  final mnemonicDisperList = [].obs;
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
        'value': value,
        'check':false
      };
    }).toList();
    List<Map<String, dynamic>> verifyList = wordList.asMap().entries.map(
            (entry) {
      return {
        'value': ""
      };
    }).toList();
    mnemonicList.value = resultList;
    mnemonicDisperList.value = shuffleList(mnemonicList.value);
    mnemonicVerifyList.value = verifyList;
  }
  List<T> shuffleList<T>(List<T> list) {
    // 创建副本，避免修改原列表
    List<T> newList = List.from(list);
    // 随机数生成器（确保每次打乱结果不同）
    final random = Random();

    // Fisher-Yates 洗牌算法（高效且随机）
    for (int i = newList.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      // 交换元素
      T temp = newList[i];
      newList[i] = newList[j];
      newList[j] = temp;
    }
    return newList;
  }
  void selectItem(dynamic item){
    //遍历需要验证的助记词集合
    if(item["check"]){
      //如果被选中了
      for(int i = 0;i<mnemonicDisperList.value.length;i++){
        if(mnemonicDisperList.value[i]["value"]==item["value"]){
          for(int k = 0;k<mnemonicVerifyList.value.length;k++){
            if(mnemonicVerifyList.value[k]["value"]==item["value"]){
              mnemonicVerifyList.value[k]["value"] = "";
              break;
            }
          }
          mnemonicDisperList.value[i]["check"] = false;
        }
      }
    }else{
      for(int i = 0;i<mnemonicDisperList.value.length;i++){
        if(mnemonicDisperList.value[i]["value"]==item["value"]){
          for(int k = 0;k<mnemonicVerifyList.value.length;k++){
            if(mnemonicVerifyList.value[k]["value"]==""){
              mnemonicVerifyList.value[k]["value"] =  mnemonicDisperList
                  .value[i]["value"];
              break;
            }
          }
          mnemonicDisperList.value[i]["check"] = true;
        }
      }
    }
    mnemonicVerifyList.refresh();
    mnemonicDisperList.refresh();
  }
  @override
  void onClose() {
    super.onClose();
  }
  void verifyList(){
    String result = mnemonicVerifyList.value.map((item) => item['value']!).join(' ');
    if(result == mnemonic.value){
      AppNavigator.startWalletmnemonicSuccess(walletAddress: wallet.value);
    }else{
      IMViews.showToast("助记词验证失败");
    }
  }
}
