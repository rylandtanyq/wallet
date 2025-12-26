import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'wallet_forget_logic.dart';

class WalletForgetView extends StatelessWidget {
  final logic = Get.find<WalletForgetLogic>();

  WalletForgetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.walletForget),
      backgroundColor: Styles.c_FFFFFF,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(left: 12.w, right: 8.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Styles.c_E8EAEF, width: 1),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Stack(
                  children: [
                    TextField(
                      controller: logic.mnemonicCtrl,
                      focusNode: logic.mnemonicFocus,
                      style: Styles.ts_0C1C33_17sp,
                      maxLines: 10,
                      minLines: 6,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: StrRes.walletForgetMnemonicPlace,
                        hintStyle: Styles.ts_8E9AB0_14sp,
                        isDense: true,
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: GestureDetector(
                        onTap: logic.pasteFromClipboard,
                        child: Text(
                          StrRes.walletForgetPaste,
                          style:
                          TextStyle(color: Styles.c_0089FF, fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              16.verticalSpace,
              InputBox.password(
                labelStyle: Styles.ts_8E9AB0_14sp,
                hintText: StrRes.walletForgetPassPlace,
                controller: logic.passwordCtrl,
                focusNode: logic.passwordFocus,
                keyBoardType: TextInputType.text,
                label: StrRes.walletForgetPass,
              ),
              16.verticalSpace,
              InputBox.password(
                labelStyle: Styles.ts_8E9AB0_14sp,
                hintText: StrRes.walletForgetPassConfigPlace,
                controller: logic.passwordAgainCtrl,
                focusNode: logic.passwordAgainFocus,
                keyBoardType: TextInputType.text,
                label: StrRes.walletForgetPassConfig,
              ),
              25.verticalSpace,
              Obx(() => Button(
                onTap: logic.nextStep,
                height: 50,
                text: StrRes.walletForget,
                enabled: logic.enabled.value,
                radius: 30,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
