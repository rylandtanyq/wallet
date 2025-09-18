import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/theme/app_textStyle.dart';

class ContractTradingCard extends StatefulWidget {
  @override
  _ContractTradingCardState createState() => _ContractTradingCardState();
}

class _ContractTradingCardState extends State<ContractTradingCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(.4), width: 1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ethwusdt 24小时涨幅',
                    // style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onBackground),
                  ),
                  SizedBox(height: 8),

                  Text(
                    '+29.3%',
                    style: TextStyle(fontSize: 29.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                  ),
                  SizedBox(height: 4),
                ],
              ),
              Image.asset('assets/images/bg_home_banner.png', width: 100.w, height: 43.h, fit: BoxFit.cover),
            ],
          ),
          SizedBox(width: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('2025-06-06用户 ', style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                  Text(
                    'xxx***xxx',
                    style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                  ),
                  Text(' 看涨收益率', style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
