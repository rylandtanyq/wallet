import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/i18n/strings.g.dart';

class HomePageBackupFragments extends StatefulWidget {
  const HomePageBackupFragments({super.key});

  @override
  State<HomePageBackupFragments> createState() => _HomePageBackupFragmentsState();
}

class _HomePageBackupFragmentsState extends State<HomePageBackupFragments> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 底层图片
        Image.asset('assets/images/bg_home_banner.png', width: 350.w, height: 105.h, fit: BoxFit.cover),

        Positioned(
          top: 16,
          left: 15,
          child: SizedBox(
            width: 180.w,
            child: Text(
              t.home.backup_wallet_tip,
              style: TextStyle(color: Colors.black, fontSize: 17.sp, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        // 第二个文本（右下角）
        Positioned(
          bottom: 16,
          left: 15,
          child: Container(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: BorderRadius.circular(17.r)),
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            height: 28.h,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.home.backup_now,
                  style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.onBackground),
                ),
                SizedBox(width: 5.w),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Theme.of(context).colorScheme.onBackground),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
