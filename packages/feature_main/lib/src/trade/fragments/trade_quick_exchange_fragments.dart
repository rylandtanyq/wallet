import 'package:feature_main/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'package:shared_ui/widget/wallet_icon.dart';

class TradeQuickExchangeFragments extends StatefulWidget {
  const TradeQuickExchangeFragments({super.key});

  @override
  State<TradeQuickExchangeFragments> createState() => _TradeQuickExchangeFragmentsState();
}

class _TradeQuickExchangeFragmentsState extends State<TradeQuickExchangeFragments> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 220,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: Theme.of(context).colorScheme.surface),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            t.trade.sell,
                            style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Icon(WalletIcon.wallet, size: 12.h, color: Theme.of(context).colorScheme.onSurface),
                              SizedBox(width: 4.w),
                              Text("0.00", style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                              SizedBox(width: 4.w),
                              Icon(Icons.add_box_sharp, size: 16.h, color: Theme.of(context).colorScheme.primary),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Image.asset('assets/images/BNB.png', width: 40, height: 40),
                              SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("USDT", style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                                  Text("BNB chain", style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                                ],
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.onBackground),
                            ],
                          ),
                          Text("0.00", style: AppTextStyles.headline1.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                        ],
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            t.trade.buy,
                            style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Icon(WalletIcon.wallet, size: 12.h, color: Theme.of(context).colorScheme.onSurface),
                              SizedBox(width: 4.w),
                              Text("0.00", style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                              SizedBox(width: 4.w),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Image.asset('assets/images/ETH.png', width: 40, height: 40),
                              SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("USDT", style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                                  Text("BNB chain", style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                                ],
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.onBackground),
                            ],
                          ),
                          Text("0.00", style: AppTextStyles.headline1.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                SizedBox(width: 12.w),
                Expanded(child: Divider(height: .5, color: Theme.of(context).colorScheme.onSurface.withOpacity(.2))),
                SizedBox(width: 10.w),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: BorderRadius.circular(50.r)),
                  alignment: Alignment.center,
                  child: Icon(WalletIcon.switch_up_and_down, color: Theme.of(context).colorScheme.onBackground),
                ),
                SizedBox(width: 10.w),
                Expanded(child: Divider(height: .5, color: Theme.of(context).colorScheme.onSurface.withOpacity(.2))),
                SizedBox(width: 12.w),
              ],
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 16),
          width: double.infinity,
          height: 40.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(50.r)),
          child: Text(
            t.trade.transaction,
            style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
