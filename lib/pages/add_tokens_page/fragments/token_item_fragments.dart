import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/theme/app_textStyle.dart';
import 'package:untitled1/widget/tokenIcon.dart';

enum TokenTrailingAction { none, add, remove }

class TokenItemFragments extends StatelessWidget {
  final int? index;
  final String image;
  final String name;
  final String symbol;
  final String price;
  final String num;
  final TokenTrailingAction action;
  final Future<void> Function()? onTap;
  final Future<void> Function()? onLongPress;
  const TokenItemFragments({
    super.key,
    this.index,
    required this.image,
    required this.name,
    required this.symbol,
    required this.price,
    required this.num,
    this.action = TokenTrailingAction.none,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: index == 0 ? 20 : 0),
      width: double.infinity,
      height: 40.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(50), child: TokenIcon(image, size: 40)),
          SizedBox(width: 10.w),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w600),
                    ),
                    Text(symbol, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      num,
                      style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w600),
                    ),
                    Text(price, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: onTap,
            onLongPress: onLongPress,
            child: action == TokenTrailingAction.add
                ? Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.primary)
                : Icon(Icons.remove_circle_outline, color: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
    );
  }
}
