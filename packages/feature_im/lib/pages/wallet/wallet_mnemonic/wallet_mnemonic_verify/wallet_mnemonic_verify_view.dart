import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'wallet_mnemonic_verify_logic.dart';

class WalletMnemonicVerifyView extends StatelessWidget {
  final logic = Get.find<WalletMnemonicVerifyLogic>();

  WalletMnemonicVerifyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: TitleBar.back(title: StrRes.walletMnemonicVerify),
        backgroundColor: Styles.c_FFFFFF,
        body: Obx(() => SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StrRes.walletMnemonicVerifyTitle,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      StrRes.walletMnemonicVerifySubTitle,
                      style: TextStyle(
                        color: Color(0xFFF75D58),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: logic.mnemonicVerifyList.value
                            .asMap()
                            .entries
                            .map((entry) {
                          final double itemWidth =
                              (MediaQuery.of(context).size.width - 40 - 10) / 2;
                          int index = entry.key + 1;
                          var item = entry.value;
                          return Container(
                            width: itemWidth,
                            height: 45,
                            decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFC5C5C5)),
                                borderRadius: BorderRadius.circular(30)),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      index < 10 ? "0${index}" : "${index}",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFB3B3B3)),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 18,
                                  decoration:
                                      BoxDecoration(color: Color(0xFFD8D8D8)),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    child: Center(
                                      child: Text(
                                        "${item["value"]}",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: logic.mnemonicDisperList.value.map((item) {
                          final double itemWidth =
                              (MediaQuery.of(context).size.width - 40 - 20) / 3;
                          return GestureDetector(
                            onTap: () {
                              logic.selectItem(item);
                            },
                            child: Container(
                              width: itemWidth,
                              height: 35,
                              decoration: BoxDecoration(
                                  color: item["check"]
                                      ? Color(0xFF78ABF4)
                                      : Color(0xFFB2B2B2),
                                  borderRadius: BorderRadius.circular(30)),
                              child: Center(
                                child: Text(
                                  "${item["value"]}",
                                  style: TextStyle(
                                      color: item["check"]
                                          ? Styles.c_FFFFFF
                                          : Styles.c_0C1C33,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    Button(
                      onTap: logic.verifyList,
                      height: 50,
                      text: StrRes.walletMnemonicVerifyBtn,
                      enabled: true,
                      radius: 30,
                    ),
                  ],
                ),
              ),
            )));
  }
}
