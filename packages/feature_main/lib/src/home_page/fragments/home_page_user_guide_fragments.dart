import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:feature_main/i18n/strings.g.dart';
import 'package:shared_ui/theme/app_textStyle.dart';

class HomePageUserGuideFragments extends StatelessWidget {
  const HomePageUserGuideFragments({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 5),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  t.home.user_guide,
                  style: AppTextStyles.size19.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                ),
              ),
              Image.asset('assets/images/ic_arrows_right.png', width: 7, height: 12),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.h),
          height: 130.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              return GestureDetector(onTap: () => {}, child: _buildGuideItemRow(context));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGuideItemRow(BuildContext context) {
    return Container(
      height: 130.h,
      margin: EdgeInsets.only(right: 15.w),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(.4), width: 1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            // 使用 Expanded 让图片占据剩余空间
            child: Image.asset(
              'assets/images/bg_home_banner.png',
              width: 233.w,
              fit: BoxFit.cover, // 确保图片适应
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.home.create_first_wallet, style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                SizedBox(height: 2.h),
                Text(t.home.start_crypto_journey, style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
