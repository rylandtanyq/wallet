import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solana/dto.dart';
import 'package:untitled1/constants/AppColors.dart';

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
          child: Icon(Icons.arrow_back_ios_new, size: 20.w, color: Colors.black),
        ),
        leadingWidth: 40,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "奖励账户",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(
              "我的钱包",
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Color(0xFF757F7F)),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => {Feedback.forTap(context), _rewardsAccountPopup()},
            child: Icon(Icons.help_outline, size: 20.w, color: Colors.black),
          ),
          SizedBox(width: 12.5),
        ],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "可用余额",
              style: TextStyle(fontSize: 15.sp, color: Color(0xFF757F7F)),
            ),
            Text(
              "¥0.00",
              style: TextStyle(fontSize: 30.sp, color: Colors.black, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 26),
            Text(
              "我的资产",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black),
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
                    style: TextStyle(fontSize: 16.sp, color: Colors.black),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        item["number"] ?? "",
                        style: TextStyle(fontSize: 16.sp, color: Colors.black),
                      ),
                      Text(
                        item["price"] ?? "",
                        style: TextStyle(fontSize: 12.sp, color: Color(0xFF757F7F)),
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
                  "什么是奖励账户",
                  style: TextStyle(fontSize: 21.sp, color: Colors.black, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 19.h),
                Text(
                  "你参与活动所获得的代币奖励默认存入奖励账户。 \n\n你可以将奖励代币轻松提现到钱包中，也可以将选定的代币划转到钱包账户，用于抵扣链上交易手续费。\n\n代币会自动加入到你的钱包账户中，可按照与美元 1:1 的汇率抵扣手续费。",
                  style: TextStyle(fontSize: 15.sp, color: Color(0xFF757F7F)),
                ),
                SizedBox(height: 23.h),
                SizedBox(height: 20.h),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.color_286713,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(25.r)),
                  ),
                  child: Text(
                    "知道了",
                    style: TextStyle(fontSize: 18.sp, color: Colors.white),
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
