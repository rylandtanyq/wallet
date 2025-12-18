import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'wallet_index_logic.dart';

class WalletIndexView extends StatelessWidget {
  final logic = Get.find<WalletIndexLogic>();

  WalletIndexView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: StrRes.wallet,
        backgroundColor: Styles.c_F8F9FA,
      ),
      backgroundColor: Styles.c_F8F9FA,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          children: [
            GestureDetector(
              onTap: logic.viewWalletCreate,
              child: Container(
                height: 65,
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                decoration: BoxDecoration(
                    color: Styles.c_FFFFFF,
                    borderRadius: BorderRadius.circular(5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      StrRes.walletCreate,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    ImageRes.rightArrow.toImage
                      ..width = 30.w
                      ..height = 30.h
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: logic.viewWalletImport,
              child: Container(
                height: 65,
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                decoration: BoxDecoration(
                    color: Styles.c_FFFFFF,
                    borderRadius: BorderRadius.circular(5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      StrRes.walletImport,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    ImageRes.rightArrow.toImage
                      ..width = 30.w
                      ..height = 30.h
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
