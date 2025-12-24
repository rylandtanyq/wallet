import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'wallet_register_logic.dart';

class WalletRegisterView extends StatelessWidget {
  final logic = Get.find<WalletRegisterLogic>();

  WalletRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: ""),
      backgroundColor: Styles.c_FFFFFF,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              ImageRes.loginLogo.toImage
                ..width = 64.w
                ..height = 64.h,
              51.verticalSpace,
              InputBox.account(
                label: "",
                labelStyle: Styles.ts_8E9AB0_14sp,
                hintText: "",
                code: "",
                onAreaCode: null,
                controller: logic.walletAddressCtrl,
                focusNode: logic.walletAddressFocus,
                keyBoardType: TextInputType.text,
                readOnly: 1,
              ),
              16.verticalSpace,
              InputBox.account(
                label: "",
                labelStyle: Styles.ts_8E9AB0_14sp,
                hintText: StrRes.plsEnterEmail,
                code: "",
                onAreaCode: null,
                controller: logic.usernameCtrl,
                focusNode: logic.usernameFocus,
                keyBoardType: TextInputType.text,
              ),
              16.verticalSpace,
              InputBox.password(
                labelStyle: Styles.ts_8E9AB0_14sp,
                hintText: StrRes.walletRegisterPass,
                controller: logic.passwordCtrl,
                focusNode: logic.passwordFocus,
                keyBoardType: TextInputType.text,
                label: '',
              ),
              16.verticalSpace,
              InputBox.password(
                labelStyle: Styles.ts_8E9AB0_14sp,
                hintText: StrRes.walletRegisterPassConfirm,
                controller: logic.passwordAgainCtrl,
                focusNode: logic.passwordAgainFocus,
                keyBoardType: TextInputType.text,
                label: '',
              ),
              25.verticalSpace,
              Obx(() => GestureDetector(
                    onTap: logic.changeAgree,
                    child: Row(
                      children: [
                        Icon(
                          logic.agree.value
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: logic.agree.value
                              ? Styles.c_0089FF
                              : Styles.c_8E9AB0,
                          size: 20,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Row(
                          children: [
                            Text(
                              StrRes.walletRegisterAgree,
                              style: TextStyle(color: Styles.c_8E9AB0),
                            ),
                            GestureDetector(
                              onTap: logic.openPrivacy,
                              child: Text(StrRes.walletRegisterPrivacy,
                                  style: TextStyle(
                                    color: Styles.c_0089FF,
                                  )),
                            )
                          ],
                        )
                      ],
                    ),
                  )),
              25.verticalSpace,
              Obx(() => Button(
                    onTap: logic.nextStep,
                    height: 50,
                    text: StrRes.registerNow,
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
