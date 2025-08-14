import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/constants/AppColors.dart';

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
        border: Border.all(
          color: const Color(0xFFE8EEEE),
          width: 1,
        ),
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
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),

                  Text(
                    '+29.3%',
                    style: TextStyle(
                      fontSize: 29.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.color_286713,
                    ),
                  ),
                  SizedBox(height: 4),

                ],
              ),
              Image.asset(
                'assets/images/bg_home_banner.png',
                width: 100.w,
                height: 43.h,
                fit: BoxFit.cover,
              ),

            ],
          ),
          SizedBox(width: 20.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '2025-06-06用户 ',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'xxx***xxx',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '看涨 收益率',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

            ],
          ),

        ],
      ),
    );
  }
}