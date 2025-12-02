import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_utils/constants/app_colors.dart';
import 'package:shared_utils/hive_storage.dart';
import 'package:shared_utils/hive_boxes.dart';
import 'package:shared_utils/token_icon.dart';
import 'package:feature_wallet/hive/tokens.dart';
import 'package:feature_wallet/i18n/strings.g.dart';
import 'package:feature_wallet/src/transfer_page.dart';
import 'package:shared_utils/to_fixed_trunc.dart';
import 'package:shared_ui/widget/custom_appbar.dart';
import 'package:shared_ui/theme/app_textStyle.dart';

class SelectTransferCoinTypePage extends StatefulWidget {
  const SelectTransferCoinTypePage({super.key});

  @override
  State<SelectTransferCoinTypePage> createState() => _SelectTransferCoinTypePageState();
}

class _SelectTransferCoinTypePageState extends State<SelectTransferCoinTypePage> with TickerProviderStateMixin {
  late List<Tokens> _tokenList = [];
  String tokensListKey(String address) => 'tokens_$address';
  // final List<Map<String, String>> _items = [
  //   {"currency": "SOL", "network": "Solana", "tokenAddress": ""},
  //   {"currency": "USDT", "network": "Solana", "tokenAddress": "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"},
  //   {"currency": "USDC", "network": "Solana", "tokenAddress": "4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU"},
  //   {"currency": "WSOL", "network": "Solana", "tokenAddress": "So11111111111111111111111111111111111111112"},
  // ];

  @override
  void initState() {
    super.initState();
    _loadingTokens();
  }

  Future<void> _loadingTokens() async {
    final reqAddr = (await HiveStorage().getValue<String>('selected_address', boxName: boxWallet) ?? '').trim().toLowerCase();
    if (reqAddr.isEmpty) return;
    final key = tokensListKey(reqAddr);

    final rawList = await HiveStorage().getList<Map>(key, boxName: boxTokens) ?? <Map>[];
    debugPrint('rawList print: $rawList');
    _tokenList = rawList.map((e) => Tokens.fromJson(Map<String, dynamic>.from(e))).toList();
    setState(() {});
  }

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
            // HorizontalSelectList(
            //   items: List.generate(10, (index) {
            //     return '榜单 ${index + 1}';
            //   }),
            //   onSelected: (index) {
            //     print('选中: $index');
            //   },
            // ),
            // SizedBox(height: 15.h),
            // Divider(height: 0.5, color: Theme.of(context).colorScheme.surface),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 代币列表
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _tokenList.length,
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
                                  backgroundColor: Theme.of(context).colorScheme.primary,
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
    final item = _tokenList[index];
    final price = item.price;
    final number = item.number;
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        // await HiveStorage().ensureBoxReady();
        Get.to(TransferPage(currency: item.title, tokenAddress: item.tokenAddress, network: item.subtitle, image: item.image));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        color: Theme.of(context).colorScheme.background,
        child: Row(
          children: [
            ClipOval(child: TokenIcon(item.image)),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w600),
                  ),
                  if (price != '0.00') Text(price, style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(toFixedTrunc(number, digits: 2), style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                Text(
                  toFixedTrunc(((double.tryParse(price))! * double.tryParse(number)!).toString(), digits: 2),
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
