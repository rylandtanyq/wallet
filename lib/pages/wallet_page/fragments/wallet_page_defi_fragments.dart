import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/constants/AppColors.dart';

class WalletPageDefiFragments extends StatelessWidget {
  const WalletPageDefiFragments({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '热门理财',
                  style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              Image.asset('assets/images/ic_arrows_right.png', width: 7, height: 12),
            ],
          ),
        ),
        SizedBox(
          height: 115.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return GestureDetector(onTap: () => {}, child: _buildHotCoinItemView());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHotCoinItemView() {
    return Container(
      height: 115.h,
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8EEEE), width: 1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.asset('assets/images/ic_home_bit_coin.png', width: 35.h, height: 35.h, fit: BoxFit.cover),
              ),
              SizedBox(width: 11.w),
              Text(
                'FARTCION',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 11.h),
          Text(
            '¥1.14',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 2.h),
          Text(
            '-10.22%',
            style: TextStyle(fontSize: 13.sp, color: AppColors.color_F3607B),
          ),
        ],
      ),
    );
  }
}
