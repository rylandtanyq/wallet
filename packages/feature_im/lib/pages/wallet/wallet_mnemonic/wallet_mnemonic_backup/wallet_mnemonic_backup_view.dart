import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'wallet_mnemonic_backup_logic.dart';

class WalletMnemonicBackupView extends StatelessWidget {
  final logic = Get.find<WalletMnemonicBackupLogic>();

  WalletMnemonicBackupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.walletMnemonicBackUp),
      backgroundColor: Styles.c_FFFFFF,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StrRes.walletMnemonicBackUpTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              StrRes.walletMnemonicBackUpSubTitle,
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
                children: logic.mnemonicList.map((item) {
                  final double itemWidth =
                      (MediaQuery.of(context).size.width - 40 - 10) / 2;
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
                              "${item["sort"]}",
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
                          decoration: BoxDecoration(color: Color(0xFFD8D8D8)),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            child: Center(
                              child: Text(
                                "${item["value"]}",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
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
              height: 100,
            ),
            Button(
              onTap: logic.mnemonicVerify,
              height: 50,
              text: StrRes.walletMnemonicBackUpBtn1,
              enabled: true,
              radius: 30,
            ),
            GestureDetector(
              onTap: logic.copyMnemonic,
              child: Container(
                height: 50,
                width: double.infinity,
                child: Center(
                  child: Text(
                    StrRes.walletMnemonicBackUpBtn2,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Styles.c_0089FF),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
