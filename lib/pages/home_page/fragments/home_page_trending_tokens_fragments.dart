import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/theme/app_textStyle.dart';

class HomePageTrendingTokensFragments extends StatefulWidget {
  const HomePageTrendingTokensFragments({super.key});

  @override
  State<HomePageTrendingTokensFragments> createState() => _HomePageTrendingTokensFragmentsState();
}

class _HomePageTrendingTokensFragmentsState extends State<HomePageTrendingTokensFragments> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 5),
          child: Row(
            children: [
              Text(
                t.home.trending_tokens,
                style: AppTextStyles.size19.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          height: 115.h,
          padding: EdgeInsets.symmetric(horizontal: 10.h),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            itemBuilder: (context, index) {
              return GestureDetector(onTap: () => {}, child: _buildHotCoinItemView(index));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHotCoinItemView(int index) {
    return Container(
      height: 115.h,
      margin: EdgeInsets.only(right: 16.w),
      padding: EdgeInsets.all(10.h),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(.4), width: 1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (index == 1)
                ClipOval(
                  child: Image.asset('assets/images/fartcoin_left.png', width: 35.h, height: 35.h, fit: BoxFit.cover),
                )
              else
                ClipOval(
                  child: Image.asset('assets/images/fartcoin_right.png', width: 35.h, height: 35.h, fit: BoxFit.cover),
                ),
              SizedBox(width: 11.w),
              Text(
                'FARTCION',
                style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '¥1.14',
            style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 2.h),
          Text(
            '-10.22%',
            style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
