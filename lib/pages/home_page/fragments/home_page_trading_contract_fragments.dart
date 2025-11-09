import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/theme/app_textStyle.dart';
import 'package:untitled1/widget/ContractTradingCard.dart';

class HomePageTradingContractFragments extends StatelessWidget {
  const HomePageTradingContractFragments({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  t.home.contract_trading,
                  style: AppTextStyles.size19.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                ),
              ),
              Image.asset('assets/images/ic_arrows_right.png', width: 7, height: 12),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        ContractTradingCard(),
      ],
    );
  }
}
