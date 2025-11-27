import 'package:feature_main/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'package:feature_main/src/home/home_page/fragments/home_page_product_card_fragments.dart';

class HomePageEarnCoinsFragments extends StatefulWidget {
  const HomePageEarnCoinsFragments({super.key});

  @override
  State<HomePageEarnCoinsFragments> createState() => _HomePageEarnCoinsFragmentsState();
}

class _HomePageEarnCoinsFragmentsState extends State<HomePageEarnCoinsFragments> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.all(10.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  t.home.earn_center,
                  style: AppTextStyles.size19.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                ),
              ),
              Text(t.home.activity_count, style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface)),
              SizedBox(width: 5.w),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Theme.of(context).colorScheme.onSurface),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.h),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(.1), width: .5),
            borderRadius: BorderRadius.circular(8.0), // 设置圆角
          ),
          child: StatefulProductCard(),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}
