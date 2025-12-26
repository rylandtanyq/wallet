import 'package:feature_main/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_utils/token_icon.dart';
import 'package:feature_wallet/hive/tokens.dart';
import 'package:feature_wallet/src/add_tokens_page/index.dart';
import 'package:shared_utils/to_fixed_trunc.dart';

class HomePageFinancialDataViewFragments extends StatelessWidget {
  final List<Tokens> items;

  const HomePageFinancialDataViewFragments({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 标题行
        _buildHeaderRow(context),
        Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(.4), height: 1, thickness: 1),

        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          // padding: EdgeInsets.all(8),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildItemRow(items[index], context),
        ),
        // if (items.length > 5)
        //   SizedBox(
        //     width: 100.w,
        //     height: 32.h,
        //     child: ElevatedButton(
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Theme.of(context).colorScheme.onSecondary,
        //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        //         padding: const EdgeInsets.symmetric(vertical: 5),
        //         side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.0),
        //       ),
        //       onPressed: () {
        //         WalletNav.to(() => const AddingTokens(), transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
        //       },
        //       child: Text(
        //         t.home.view_all,
        //         style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => {},
              child: Row(
                children: [
                  Text("名称", style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface, height: 1.5)),
                  // SizedBox(width: 3.w),
                  // Image.asset('assets/images/ic_home_sort_default.png', width: 8.5.w, height: 10.h),
                ],
              ),
            ),
          ),
          // SizedBox(width: 30.w),
          // Expanded(
          //   flex: 2,
          //   child: GestureDetector(
          //     onTap: () => {},
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Text(t.home.volume_24h, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface, height: 1.5)),
          //         SizedBox(width: 3.w),
          //         Image.asset('assets/images/ic_home_sort_default.png', width: 8.5.w, height: 10.h),
          //       ],
          //     ),
          //   ),
          // ),
          // Expanded(
          //   flex: 2,
          //   child: GestureDetector(
          //     onTap: () => {},
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Text(t.home.latest_price, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface, height: 1.5)),
          //         SizedBox(width: 3.w),
          //         Image.asset('assets/images/ic_home_sort_default.png', width: 8.5.w, height: 10.h),
          //       ],
          //     ),
          //   ),
          // ),
          Expanded(
            // flex: 2,
            child: GestureDetector(
              onTap: () => {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("价格", style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface, height: 1.5)),
                  // SizedBox(width: 3.w),
                  // Image.asset('assets/images/ic_home_sort_default.png', width: 8.5.w, height: 10.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(Tokens item, BuildContext context) {
    final number = double.tryParse(item.number);
    final price = double.tryParse(item.price);
    final totalPrice = number! * price!;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(50), child: TokenIcon(item.image, size: 40)),
          SizedBox(width: 10.w),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // 'USDT',
                  item.title,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground),
                ),
                Text(
                  '\$${toFixedTrunc(item.price)}',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.end,
          //   children: [
          //     Text(
          //       toFixedTrunc(item.number, digits: 2),
          //       style: TextStyle(fontSize: 16.sp, color: Theme.of(context).colorScheme.onBackground),
          //     ),
          //     Text(
          //       '\$${toFixedTrunc((totalPrice).toString(), digits: 2)}',
          //       style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontWeight: FontWeight.bold),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
