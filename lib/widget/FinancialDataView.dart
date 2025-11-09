import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/constants/app_colors.dart';
import 'package:untitled1/i18n/strings.g.dart';

import '../entity/FinancialItem.dart';

class FinancialDataPage extends StatelessWidget {
  final List<FinancialItem> items;

  const FinancialDataPage({super.key, required this.items});

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
          padding: EdgeInsets.all(8),
          itemCount: items.length > 5 ? 5 : items.length,
          itemBuilder: (context, index) => _buildItemRow(items[index], context),
        ),
        SizedBox(
          width: 100.w,
          height: 32.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.onSecondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              padding: EdgeInsets.symmetric(vertical: 5),
              side: BorderSide(color: AppColors.color_286713, width: 1.0),
            ),
            onPressed: () => {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${t.home.view_all}  ',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                ),
                Icon(Icons.arrow_forward_ios_outlined, size: 14, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.background,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => {},
            child: Row(
              children: [
                Text(t.home.name, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface, height: 1.5)),
                SizedBox(width: 3.w),
                Image.asset('assets/images/ic_home_sort_default.png', width: 8.5.w, height: 10.h),
              ],
            ),
          ),
          SizedBox(width: 30.w),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(t.home.volume_24h, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface, height: 1.5)),
                  SizedBox(width: 3.w),
                  Image.asset('assets/images/ic_home_sort_default.png', width: 8.5.w, height: 10.h),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(t.home.latest_price, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface, height: 1.5)),
                  SizedBox(width: 3.w),
                  Image.asset('assets/images/ic_home_sort_default.png', width: 8.5.w, height: 10.h),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(t.home.change_24h, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface, height: 1.5)),
                  SizedBox(width: 3.w),
                  Image.asset('assets/images/ic_home_sort_default.png', width: 8.5.w, height: 10.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(FinancialItem item, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset('assets/images/ic_home_bit_coin.png', width: 40.w, height: 40.w, fit: BoxFit.cover),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
                        children: [
                          TextSpan(text: item.amount),
                          if (item.time.isNotEmpty) TextSpan(text: '  ${item.time}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(item.price, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(item.change, style: TextStyle(fontSize: 12, color: item.isPositive ? Colors.green : Colors.red)),
            ],
          ),
        ],
      ),
    );
  }
}
