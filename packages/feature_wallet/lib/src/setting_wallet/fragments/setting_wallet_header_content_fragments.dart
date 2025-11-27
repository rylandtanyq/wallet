import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_utils/constants/app_colors.dart';
import 'package:feature_wallet/hive/Wallet.dart';
import 'package:feature_wallet/i18n/strings.g.dart';
import 'package:shared_ui/widget/wallet_avatar_smart.dart';

class SettingWalletHeaderContentFragments extends StatelessWidget {
  final Wallet wallet;
  const SettingWalletHeaderContentFragments({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WalletAvatarSmart(address: wallet.address, avatarImagePath: wallet.avatarImagePath, size: 60.w),
          SizedBox(height: 8.h),
          Text(
            wallet.name,
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ID: deed...27dc',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.color_757F7F),
                ),
                SizedBox(width: 8.w),
                Image.asset('assets/images/ic_wallet_copy.png', width: 13.w, height: 13.w),
              ],
            ),
          ),
          SizedBox(width: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.wallet.security_level_low,
                style: TextStyle(fontSize: 12.sp, color: AppColors.color_A5B1B1),
              ),
              SizedBox(width: 2.w),
              Image.asset('assets/images/ic_wallet_safety_error.png', width: 14.w, height: 14.w),
            ],
          ),
        ],
      ),
    );
  }
}
