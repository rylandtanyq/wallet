import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/theme/app_textStyle.dart';

/// 更多服务
class MoreServices extends StatefulWidget {
  const MoreServices({super.key});

  @override
  State<MoreServices> createState() => _MoreServicesState();
}

class _MoreServicesState extends State<MoreServices> {
  final List<Map<String, dynamic>> _moreServicesData = [
    {
      "title": t.home.hotFeatures,
      "item": [
        {"path": "assets/images/transfer.png", "text": t.home.transfer},
        {"path": "assets/images/financial_management.png", "text": t.home.finance},
        {"path": "assets/images/shopping.png", "text": t.home.shopping},
      ],
    },
    {
      "title": t.home.marketTrade,
      "item": [
        {"path": "assets/images/contract.png", "text": t.home.contract},
        {"path": "assets/images/golden_dog_radar.png", "text": t.home.golden_dog_radar},
        {"path": "assets/images/meme_pump.png", "text": t.home.memePump},
        {"path": "assets/images/limit_order.png", "text": t.home.limitOrder},
        {"path": "assets/images/c2c.png", "text": t.home.c2c},
        {"path": "assets/images/buy_coins.png", "text": t.home.buyCoin},
        {"path": "assets/images/bank_card.png", "text": t.home.bankCard},
      ],
    },
    {
      "title": t.home.transfer,
      "item": [
        {"path": "assets/images/earn_coins.png", "text": t.home.earnCoin},
        {"path": "assets/images/red_envelope.png", "text": t.home.redPacket},
        {"path": "assets/images/invitation_center.png", "text": t.home.limitOrder},
        {"path": "assets/images/rewards_account.png", "text": t.Mysettings.rewards_account},
      ],
    },
    {
      "title": t.home.walletTools,
      "item": [
        {"path": "assets/images/receiving_payments.png", "text": t.home.receive},
        {"path": "assets/images/authorization_detection.png", "text": t.home.authCheck},
        {"path": "assets/images/contract_testing.png", "text": t.home.contractCheck},
        {"path": "assets/images/get_gas.png", "text": t.home.getGas},
        {"path": "assets/images/SOL_rental_recovery.png", "text": t.home.solRentRecovery},
        {"path": "assets/images/blockchain_explorer.png", "text": t.home.blockchainExplorer},
        {"path": "assets/images/EIP-7702_detection.png", "text": t.home.eip7702Check},
        {"path": "assets/images/transaction_history.png", "text": t.home.transactionHistory},
        {"path": "assets/images/batch_transfers.png", "text": t.home.batchTransfer},
        {"path": "assets/images/beginner's_guide.png", "text": t.home.beginnerGuide},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leadingWidth: 40,
        leading: GestureDetector(
          onTap: () => {Feedback.forTap(context), Navigator.of(context).pop()},
          child: Icon(Icons.arrow_back_ios_new, size: 20.w, color: Theme.of(context).colorScheme.onBackground),
        ),
        centerTitle: true,
        title: Text(
          t.home.moreServices,
          // style: TextStyle(fontSize: 18.sp, color: Colors.black, fontWeight: FontWeight.w500),
          style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w500),
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
                      style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w500),
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
                              style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onBackground),
                              maxLines: 2,
                              textAlign: TextAlign.center,
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
