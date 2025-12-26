import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'wallet_create_logic.dart';

class WalletCreateView extends StatelessWidget {
  final logic = Get.find<WalletCreateLogic>();

  WalletCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: TitleBar.back(
          title: StrRes.walletCreate,
        ),
        backgroundColor: Styles.c_FFFFFF,
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              InputBox.account(
                label: '*设置钱包名称',
                labelStyle: Styles.ts_8E9AB0_14sp,
                hintText: "请输入钱包名称",
                code: "",
                onAreaCode: null,
                controller: logic.walletNameCtrl,
                focusNode: logic.walletNameFocus,
                keyBoardType: TextInputType.text,
              ),
              16.verticalSpace,
              InputBox.password(
                label: '*设置密码',
                labelStyle: Styles.ts_8E9AB0_14sp,
                hintText: "请输入密码，不少于8位数",
                controller: logic.passwordCtrl,
                focusNode: logic.passwordFocus,
                keyBoardType: TextInputType.text,
              ),
              16.verticalSpace,
              InputBox.password(
                label: '*确认密码',
                labelStyle: Styles.ts_8E9AB0_14sp,
                hintText: "请确认密码",
                controller: logic.passwordAgainCtrl,
                focusNode: logic.passwordAgainFocus,
                keyBoardType: TextInputType.text,
              ),
              16.verticalSpace,
              InputBox.account(
                label: '提示信息',
                labelStyle: Styles.ts_8E9AB0_14sp,
                hintText: "密码提示信息（选填）",
                code: "",
                onAreaCode: null,
                controller: logic.tipsCtrl,
                focusNode: logic.tipsFocus,
                keyBoardType: TextInputType.text,
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
                              "我已阅读并同意",
                              style: TextStyle(color: Styles.c_8E9AB0),
                            ),
                            GestureDetector(
                              onTap: logic.openPrivacy,
                              child: Text("《用户协议》",
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
                    onTap: logic.createWallet,
                    height: 50,
                    text: StrRes.walletCreate,
                    enabled: logic.enabled.value,
                    radius: 30,
                  )),
            ],
          ),
        ));
  }
}
