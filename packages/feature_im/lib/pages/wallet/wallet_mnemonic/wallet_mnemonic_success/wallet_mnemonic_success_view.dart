import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'wallet_mnemonic_success_logic.dart';

class WalletMnemonicSuccessView extends StatelessWidget {
  final logic = Get.find<WalletMnemonicSuccessLogic>();

  WalletMnemonicSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.walletMnemonicVerify),
      backgroundColor: Styles.c_FFFFFF,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 100,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NewImageRes.walletSuccess.toImage
                  ..width = 80.w
                  ..height = 80.h
              ],
            ),
            SizedBox(height: 10,),
            Text("验证通过",textAlign: TextAlign.center,style: TextStyle
              (fontSize: 16),),
            SizedBox(height: 50,),
            Button(
              onTap: logic.viewWalletRegister,
              height: 50,
              text: "完成",
              enabled: true,
              radius: 30,
            ),
          ],
        ),
      ),
    );
  }
}
