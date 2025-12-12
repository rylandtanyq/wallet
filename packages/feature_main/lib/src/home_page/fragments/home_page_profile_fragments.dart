import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_utils/constants/app_colors.dart';
import 'package:feature_wallet/hive/Wallet.dart';
import 'package:feature_main/i18n/strings.g.dart';
import 'package:shared_ui/widget/wallet_avatar_smart.dart';

class HomePageProfileFragments extends StatefulWidget {
  final Future<String> totalFuture;
  final Future<Wallet> wallet;
  const HomePageProfileFragments({super.key, required this.totalFuture, required this.wallet});

  @override
  State<HomePageProfileFragments> createState() => _HomePageProfileFragmentsState();
}

class _HomePageProfileFragmentsState extends State<HomePageProfileFragments> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<Wallet>(
          future: widget.wallet,
          builder: (_, snapshot) {
            if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
              return ClipOval(
                child: Image.asset('assets/images/ic_clip_photo.png', width: 60.w, height: 60.w, fit: BoxFit.cover),
              );
            }
            final w = snapshot.data!;
            return WalletAvatarSmart(
              address: w.address,
              avatarImagePath: w.avatarImagePath,
              size: 60.w,
              radius: 60.w / 2,
              defaultAsset: 'assets/images/ic_clip_photo.png',
            );
          },
        ),
        SizedBox(height: 8.h),
        FutureBuilder(
          future: widget.wallet,
          builder: (_, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox.shrink();
            }
            final w = snapshot.data ?? Wallet.empty();
            return Text(
              w.name,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            );
          },
        ),
        FutureBuilder<String>(
          future: widget.totalFuture,
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
        // MaterialButton(
        //   onPressed: () {
        //     //弹出充值dialog
        //   },
        //   height: 40.h, // 设置高度
        //   minWidth: 175.w,
        //   elevation: 0,
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
        //   color: Theme.of(context).colorScheme.primary,
        //   textColor: Colors.white,
        //   child: Text(t.home.recharge, style: TextStyle(fontSize: 17.sp)),
        // ),
        SizedBox(height: 35.h),
      ],
    );
  }
}
