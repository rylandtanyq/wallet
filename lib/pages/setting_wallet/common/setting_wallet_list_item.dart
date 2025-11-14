import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/constants/app_colors.dart';

class SettingWalletListItem extends StatelessWidget {
  final String icon;
  final String mainTitle;
  final String subTitle;
  final bool isVerify;
  final VoidCallback onTap;
  const SettingWalletListItem({
    super.key,
    required this.icon,
    required this.isVerify,
    required this.mainTitle,
    required this.onTap,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.grey.withOpacity(0.1), // 点击效果
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            // 主副标题
            Expanded(
              child: Text(mainTitle, style: TextStyle(fontSize: 16.sp)),
            ),
            if (isVerify) Image.asset('assets/images/ic_wallet_reminder.png', width: 19.w, height: 19.w),
            SizedBox(width: 5.w),
            if (subTitle.isNotEmpty)
              Text(
                subTitle,
                style: TextStyle(fontSize: 15.sp, color: isVerify ? Colors.black : AppColors.color_757F7F),
              ),
            SizedBox(width: 13.w),
            // 右侧箭头
            Icon(Icons.arrow_forward_ios, size: 12.w, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
