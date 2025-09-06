import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/pages/view/CustomAppBar.dart';

/// 已连接的DApp页面
class Linkedwalletdapp extends StatefulWidget {
  const Linkedwalletdapp({super.key});

  @override
  State<Linkedwalletdapp> createState() => _LinkedwalletdappState();
}

class _LinkedwalletdappState extends State<Linkedwalletdapp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "已连接的DApp",
        actions: [
          Image.asset('assets/images/ic_home_scan.png', width: 16.w, height: 16.w),
          SizedBox(width: 12.w),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 2),
            Image.asset('assets/images/grouping_3.png', width: 88.w, height: 88.h),
            Text(
              "暂未连接任何DApp",
              style: TextStyle(fontSize: 19.sp, color: Colors.black, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 11.h),
            Container(
              width: 176.w,
              height: 40.h,
              decoration: BoxDecoration(color: AppColors.color_286713, borderRadius: BorderRadius.circular(25.r)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/scan_white.png', width: 17.w, height: 17.h),
                  SizedBox(width: 9.w),
                  Text(
                    "扫描连接",
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
                  ),
                ],
              ),
            ),
            Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
