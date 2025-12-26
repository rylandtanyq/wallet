import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'wallet_mnemonic_logic.dart';

class WalletMnemonicView extends StatelessWidget {
  final logic = Get.find<WalletMnemonicLogic>();

  WalletMnemonicView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.walletMnemonicCreate),
      backgroundColor: Styles.c_FFFFFF,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NewImageRes.mnemonicLock.toImage
                  ..width = 120.w
                  ..height = 120.h
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              StrRes.walletMnemonicCreateTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              StrRes.walletMnemonicCreateSubTitle,
              style: TextStyle(fontSize: 14, color: Styles.c_8E9AB0),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Color(0xFFFDF4F3),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFFF75D58),
                        size: 18,
                      ),
                      Text(
                        StrRes.walletMnemonicCreateTips,
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFF75D58),
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                  Text(
                    StrRes.walletMnemonicCreateTips1,
                    style: TextStyle(fontSize: 12, color: Color(0xFFF75D58)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40,),
            Button(
              onTap: logic.createMnemonic,
              height: 50,
              text: StrRes.walletMnemonicCreate,
              enabled: true,
              radius: 30,
            )
          ],
        ),
      ),
    );
  }
}
