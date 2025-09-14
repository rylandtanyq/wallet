import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 更多服务
class MoreServices extends StatefulWidget {
  const MoreServices({super.key});

  @override
  State<MoreServices> createState() => _MoreServicesState();
}

class _MoreServicesState extends State<MoreServices> {
  final List<Map<String, dynamic>> _moreServicesData = [
    {
      "title": "热门功能",
      "item": [
        {"path": "assets/images/transfer.png", "text": "转账"},
        {"path": "assets/images/financial_management.png", "text": "理财"},
        {"path": "assets/images/shopping.png", "text": "购物"},
      ],
    },
    {
      "title": "行情和交易",
      "item": [
        {"path": "assets/images/contract.png", "text": "合约"},
        {"path": "assets/images/golden_dog_radar.png", "text": "金狗雷达"},
        {"path": "assets/images/meme_pump.png", "text": "Meme Pump"},
        {"path": "assets/images/limit_order.png", "text": "限价委托"},
        {"path": "assets/images/c2c.png", "text": "C2C"},
        {"path": "assets/images/buy_coins.png", "text": "买币"},
        {"path": "assets/images/bank_card.png", "text": "银行卡"},
      ],
    },
    {
      "title": "赚币",
      "item": [
        {"path": "assets/images/earn_coins.png", "text": "赚币"},
        {"path": "assets/images/red_envelope.png", "text": "红包"},
        {"path": "assets/images/invitation_center.png", "text": "限价委托"},
        {"path": "assets/images/rewards_account.png", "text": "奖励账户"},
      ],
    },
    {
      "title": "钱包工具",
      "item": [
        {"path": "assets/images/receiving_payments.png", "text": "收款"},
        {"path": "assets/images/authorization_detection.png", "text": "授权检测"},
        {"path": "assets/images/contract_testing.png", "text": "合约检测"},
        {"path": "assets/images/get_gas.png", "text": "GetGas"},
        {"path": "assets/images/SOL_rental_recovery.png", "text": "SOL租金回收"},
        {"path": "assets/images/blockchain_explorer.png", "text": "区块链浏览器"},
        {"path": "assets/images/EIP-7702_detection.png", "text": "EIP-7702 检测"},
        {"path": "assets/images/transaction_history.png", "text": "交易历史"},
        {"path": "assets/images/batch_transfers.png", "text": "批量转账"},
        {"path": "assets/images/beginner's_guide.png", "text": "新手引导"},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = 4;
    final spacing = 0.w;
    final horizontalPadding = 24.w;
    final itemWidth = (screenWidth - horizontalPadding - (crossAxisCount - 1) * spacing) / crossAxisCount;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: GestureDetector(
          onTap: () => {Feedback.forTap(context), Navigator.of(context).pop()},
          child: Icon(Icons.arrow_back_ios_new, size: 20.w, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          "更多服务",
          style: TextStyle(fontSize: 18.sp, color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_moreServicesData.length, (index) {
              final ele = _moreServicesData[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 12.w),
                    child: Text(
                      ele["title"],
                      style: TextStyle(fontSize: 18.sp, color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: (ele["item"] as List).length,
                    padding: EdgeInsets.symmetric(horizontal: 0.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 0, mainAxisSpacing: 16.h),
                    itemBuilder: (context, index2) {
                      final item = ele["item"][index2];
                      return SizedBox(
                        // width: itemWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(item["path"], width: 50, height: 50),
                            SizedBox(height: 8.h),
                            Text(
                              item["text"],
                              style: TextStyle(fontSize: 12.sp, color: Colors.black),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
