import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/pages/TransferPage.dart';
import 'package:untitled1/pages/view/CustomAppBar.dart';
import 'package:untitled1/pages/view/HorizntalSelectList.dart';
import 'package:untitled1/theme/app_textStyle.dart';
import '../constants/AppColors.dart';

class SelectTransferCoinTypePage extends StatefulWidget {
  const SelectTransferCoinTypePage({super.key});

  @override
  State<SelectTransferCoinTypePage> createState() => _SelectTransferCoinTypePageState();
}

class _SelectTransferCoinTypePageState extends State<SelectTransferCoinTypePage> with TickerProviderStateMixin {
  final List<Map<String, String>> _items = [
    {"currency": "SOL", "network": "Solana", "tokenAddress": ""},
    {"currency": "USDT", "network": "Solana", "tokenAddress": "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"},
    {"currency": "USDC", "network": "Solana", "tokenAddress": "4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU"},
    {"currency": "WSOL", "network": "Solana", "tokenAddress": "So11111111111111111111111111111111111111112"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: t.transfer_receive_payment.selectTransferCoin),
      body: Container(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(19.r)),
                    height: 37.h,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search, color: Theme.of(context).colorScheme.onBackground),
                        SizedBox(width: 8.w),
                        Text(
                          t.transfer_receive_payment.tokenOrContract,
                          style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            HorizontalSelectList(
              items: List.generate(10, (index) {
                return '榜单 ${index + 1}';
              }),
              onSelected: (index) {
                print('选中: $index');
              },
            ),
            SizedBox(height: 15.h),
            Divider(height: 0.5, color: Theme.of(context).colorScheme.surface),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 代币列表
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        return _buildCoinTypeItem(index);
                      },
                    ),

                    // 底部提示（紧接在列表后）
                    Padding(
                      padding: EdgeInsets.only(top: 20.h, bottom: 30.h),
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              t.transfer_receive_payment.tokenNotFound,
                              style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.color_2B6D16,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21.5.r)),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 11),
                                ),
                                onPressed: () {
                                  // 按钮点击事件
                                },
                                child: Text(
                                  t.transfer_receive_payment.addToken,
                                  style: AppTextStyles.size17.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinTypeItem(int index) {
    final currency = _items[index]["currency"];
    final tokenAddress = _items[index]["tokenAddress"];
    final network = _items[index]["network"];
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Get.to(TransferPage(currency: currency!, tokenAddress: tokenAddress!, network: network!));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        color: Theme.of(context).colorScheme.background,
        child: Row(
          children: [
            ClipOval(
              child: Image.asset('assets/images/ic_home_bit_coin.png', width: 40.w, height: 40.h),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _items[index]["currency"] ?? "",
                    style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w600),
                  ),
                  Text('Solana', style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
            ),
            Column(
              children: [
                Text('9.${index}0', style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                Text(
                  '¥${index + 1}.00',
                  style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NetworkItem {
  final String name;
  final bool isHot;
  final String pinyin;

  NetworkItem({required this.name, this.isHot = false, required this.pinyin});
}
