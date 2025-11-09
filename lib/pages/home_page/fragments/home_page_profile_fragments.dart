import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:untitled1/constants/app_colors.dart';
import 'package:untitled1/constants/hive_boxes.dart';
import 'package:untitled1/hive/tokens.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/util/HiveStorage.dart';

class HomePageProfileFragments extends StatefulWidget {
  const HomePageProfileFragments({super.key});

  @override
  State<HomePageProfileFragments> createState() => _HomePageProfileFragmentsState();
}

class _HomePageProfileFragmentsState extends State<HomePageProfileFragments> {
  late Future<String> _totalFuture;
  late StreamSubscription _hiveSub;

  @override
  void initState() {
    super.initState();
    _totalFuture = computeTotalFromHive2dp();

    Hive.openBox(boxTokens).then((box) {
      _hiveSub = box.watch().listen((_) {
        setState(() {
          _totalFuture = computeTotalFromHive2dp();
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _hiveSub.cancel();
  }

  Future<String> computeTotalFromHive2dp() async {
    final raw = await HiveStorage().getList<Map>('tokens', boxName: boxTokens) ?? const <Map>[];
    final tokens = raw.map((e) => Tokens.fromJson(Map<String, dynamic>.from(e))).toList();
    final sum = tokens.fold<double>(
      0.0,
      (acc, t) => acc + (double.tryParse(t.price.replaceAll(',', '').trim()) ?? 0.0) * (double.tryParse(t.number.replaceAll(',', '').trim()) ?? 0.0),
    );

    return sum.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(
          child: Image.asset('assets/images/ic_clip_photo.png', width: 60.w, height: 60.w, fit: BoxFit.cover),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () {
            //弹出钱包Dialog
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.common.my_wallet,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8.w),
              // Image.asset('assets/images/ic_arrows_down.png', width: 10.w, height: 6.w),
              Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.onBackground),
            ],
          ),
        ),
        FutureBuilder<String>(
          future: _totalFuture,
          builder: (_, snap) => Text(
            '\$${snap.data ?? '0.00'}',
            style: TextStyle(fontSize: 35.sp, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/ic_home_app_icon.png', width: 20.w, height: 20.w),
            SizedBox(width: 6.5.w),
            Image.asset('assets/images/ic_home_app_icon1.png', width: 20.w, height: 20.w),
            SizedBox(width: 6.5.w),
            Image.asset('assets/images/ic_home_app_icon2.png', width: 20.w, height: 20.w),
            SizedBox(width: 6.5.w),
            Image.asset('assets/images/ic_home_app_icon3.png', width: 20.w, height: 20.w),
            SizedBox(width: 6.5.w),
            Icon(
              Icons.circle,
              size: 2.5.h,
              color: Color(0xFF6F7470), // #6F7470 颜色
            ),
            SizedBox(width: 6.5.w),
            Image.asset('assets/images/ic_home_visa.png', width: 49.w, height: 21.h),
            SizedBox(width: 4.5.w),
            Image.asset('assets/images/ic_home_master.png', width: 49.w, height: 21.h),
            SizedBox(width: 4.5.w),
            Image.asset('assets/images/ic_home_applepay.png', width: 49.w, height: 21.h),
          ],
        ),
        SizedBox(height: 18.h),
        MaterialButton(
          onPressed: () {
            //弹出充值dialog
          },
          height: 40.h, // 设置高度
          minWidth: 175.w,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
          color: AppColors.color_2B6D16,
          textColor: Colors.white,
          child: Text(t.home.recharge, style: TextStyle(fontSize: 17.sp)),
        ),
        SizedBox(height: 35.h),
      ],
    );
  }
}
