import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/pages/view/CustomAppBar.dart';
import 'package:untitled1/state/app_provider.dart';
import 'package:untitled1/theme/app_textStyle.dart';

/// 已连接的DApp页面
class Linkedwalletdapp extends ConsumerStatefulWidget {
  const Linkedwalletdapp({super.key});

  @override
  ConsumerState<Linkedwalletdapp> createState() => _LinkedwalletdappState();
}

class _LinkedwalletdappState extends ConsumerState<Linkedwalletdapp> {
  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    return Scaffold(
      appBar: CustomAppBar(
        title: t.common.connected_dapps,
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
            Text(t.common.no_connected_dapps, style: AppTextStyles.size19.copyWith(color: Theme.of(context).colorScheme.onBackground)),
            SizedBox(height: 11.h),
            Container(
              width: 176.w,
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: AppColors.color_286713, borderRadius: BorderRadius.circular(25.r)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/scan_white.png', width: 17.w, height: 17.h),
                  SizedBox(width: 9.w),
                  Expanded(
                    child: Text(
                      t.common.scan_to_connect,
                      style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
