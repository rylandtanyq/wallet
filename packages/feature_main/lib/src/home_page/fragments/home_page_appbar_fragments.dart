import 'package:feature_main/src/linked_wallet_Dapp.dart';
import 'package:feature_main/src/my_settings.dart';
import 'package:feature_main/src/notification_page.dart';
import 'package:feature_main/src/search_page/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_ui/theme/app_textStyle.dart';

class HomePageAppbarFragments extends StatelessWidget {
  const HomePageAppbarFragments({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.to(Mysettings(), transition: Transition.leftToRight, popGesture: true),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
              child: Image.asset('assets/images/ic_home_function.png', width: 16.w, height: 16.w),
            ),
          ),
          SizedBox(width: 22.w),
          Expanded(
            child: GestureDetector(
              onTap: () => Get.to(SearchPage(), transition: Transition.rightToLeft, popGesture: true),
              child: Container(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(19.r)),
                padding: EdgeInsets.all(10),
                height: 37.h,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, color: Theme.of(context).colorScheme.onBackground),
                    SizedBox(width: 8.w),
                    Text('BTC/USDT', style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 22.w),
          GestureDetector(
            onTap: () {
              Get.to(
                Linkedwalletdapp(), // 要跳转的页面
                transition: Transition.rightToLeft, // 设置从右到左的动画
                duration: const Duration(milliseconds: 300), // 可选：设置动画持续时间
              );
            },
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
              child: Image.asset('assets/images/ic_home_link.png', width: 16.w, height: 16.w),
            ),
          ),
          SizedBox(width: 22.w),
          ColorFiltered(
            colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
            child: Image.asset('assets/images/ic_home_scan.png', width: 16.w, height: 16.w),
          ),
          SizedBox(width: 22.w),
          GestureDetector(
            onTap: () {
              Get.to(
                NotificationPage(), // 要跳转的页面
                transition: Transition.rightToLeft, // 设置从右到左的动画
                duration: const Duration(milliseconds: 300), // 可选：设置动画持续时间
              );
            },
            // child: Image.asset('assets/images/ic_home_message.png', width: 16.w, height: 16.w),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
              child: Image.asset('assets/images/ic_home_message.png', width: 16.w, height: 16.w),
            ),
          ),
        ],
      ),
    );
  }
}
