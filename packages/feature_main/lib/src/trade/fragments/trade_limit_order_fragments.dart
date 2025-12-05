import 'package:feature_main/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'package:shared_ui/widget/wallet_icon.dart';

class TradeLimitOrderFragments extends StatefulWidget {
  const TradeLimitOrderFragments({super.key});

  @override
  State<TradeLimitOrderFragments> createState() => _TradeLimitOrderFragmentsState();
}

class _TradeLimitOrderFragmentsState extends State<TradeLimitOrderFragments> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomInset + 16),
        child: Column(
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
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              width: double.infinity,
              height: 115.h,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10.r)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t.trade.expectedOrderPrice,
                        style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 4.w, horizontal: 12.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(50.r)),
                        child: Text(t.trade.enterPrice, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 12),
                    width: double.infinity,
                    height: 50.h,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textEditingController,
                            decoration: InputDecoration(
                              hintText: "1BNB",
                              hintStyle: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.background,
                              border: OutlineInputBorder(borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        Text("0 USDT", style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 16),
              width: double.infinity,
              height: 40.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(50.r)),
              child: Text(
                t.trade.confirm,
                style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
