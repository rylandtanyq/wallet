import 'package:feature_main/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_utils/constants/app_colors.dart';
import 'package:shared_ui/theme/app_textStyle.dart';

/// 奖励账户
class Rewardsaccount extends StatefulWidget {
  const Rewardsaccount({super.key});

  @override
  State<Rewardsaccount> createState() => _RewardsaccountState();
}

class _RewardsaccountState extends State<Rewardsaccount> {
  final List<Map<String, String>> data = [
    {"path": "assets/images/BNB.png", "coin": "BNB", "number": "0.00", "price": "¥0.00"},
    {"path": "assets/images/USDT.png", "coin": "USDT", "number": "0.00", "price": "¥0.00"},
    {"path": "assets/images/ETH.png", "coin": "ETH", "number": "0.00", "price": "¥0.00"},
    {"path": "assets/images/BTC.png", "coin": "BTC", "number": "0.00", "price": "¥0.00"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => {Feedback.forTap(context), Navigator.of(context).pop()},
          child: Icon(Icons.arrow_back_ios_new, size: 20.w, color: Theme.of(context).colorScheme.onBackground),
        ),
        leadingWidth: 40,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              t.Mysettings.rewards_account,
              style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
            ),
            Text(t.common.my_wallet, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => {Feedback.forTap(context), _rewardsAccountPopup()},
            child: Icon(Icons.help_outline, size: 20.w, color: Theme.of(context).colorScheme.onBackground),
          ),
          SizedBox(width: 12.5),
        ],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.Mysettings.available_balance, style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onSurface)),
            Text(
              "¥0.00",
              style: AppTextStyles.size30.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 26),
            Text(
              t.Mysettings.my_assets,
              style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
            ),
            ListView.separated(
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                final item = data[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Image.asset(item["path"] ?? "", width: 37.w, height: 37.h),
                  title: Text(
                    item["coin"] ?? "",
                    style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.normal),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        item["number"] ?? "",
                        style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.normal),
                      ),
                      Text(
                        item["price"] ?? "",
                        style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 43);
              },
              itemCount: data.length,
            ),
          ],
        ),
      ),
    );
  }

  void _rewardsAccountPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (Context) {
        return Container(
          padding: EdgeInsets.only(top: 44, left: 12, right: 12),
          width: double.infinity,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/images/rewardsAccount_popup_img.png", width: 160.w, height: 153.h),
                Text(
                  t.Mysettings.what_is_rewards_account,
                  style: AppTextStyles.size21.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 19.h),
                Text(t.Mysettings.rewards_account_desc, style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                SizedBox(height: 23.h),
                SizedBox(height: 20.h),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(25.r)),
                  ),
                  child: Text(
                    t.Mysettings.got_it,
                    // style: TextStyle(fontSize: 18.sp, color: Colors.white),
                    style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
