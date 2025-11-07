import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/hive/tokens.dart';
import 'package:untitled1/pages/wallet_page/fragments/wallet_page_skeleton_fragments.dart';
import 'package:untitled1/pages/wallet_page/models/token_price_model.dart';
import 'package:untitled1/util/toFixedTrunc.dart';
import 'package:untitled1/widget/tokenIcon.dart';

class WalletPageTokenItemFragments extends ConsumerStatefulWidget {
  final int index;
  final AsyncValue<TokenPriceModel> tokensPriceState;
  final List<Tokens> fillteredTokensList;
  final Map<String, String> lastPriceMap;
  const WalletPageTokenItemFragments({
    super.key,
    required this.index,
    required this.tokensPriceState,
    required this.fillteredTokensList,
    required this.lastPriceMap,
  });

  @override
  ConsumerState<WalletPageTokenItemFragments> createState() => _WalletPageTokenItemFragmentsState();
}

class _WalletPageTokenItemFragmentsState extends ConsumerState<WalletPageTokenItemFragments> {
  @override
  Widget build(BuildContext context) {
    final item = widget.fillteredTokensList[widget.index];
    final number = double.tryParse(item.number);
    final price = double.tryParse(item.price);
    final totalPrice = number! * price!;

    final key = item.tokenAddress == "SOL" ? "SOL" : item.tokenAddress;
    final priceStr = widget.lastPriceMap[key];

    return GestureDetector(
      // onTap: () => {Get.to(CoinDetailPage())},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(50), child: TokenIcon(item.image, size: 40)),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        // 'USDT',
                        item.title,
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground),
                      ),
                      SizedBox(width: 6),
                    ],
                  ),
                  if (widget.tokensPriceState.isLoading)
                    WalletPageSkeletonFragments()
                  else if (widget.tokensPriceState.hasValue)
                    if (priceStr != null)
                      Text(
                        '\$${toFixedTrunc(item.price)}',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  toFixedTrunc(item.number, digits: 2),
                  style: TextStyle(fontSize: 16.sp, color: Theme.of(context).colorScheme.onBackground),
                ),
                if (widget.tokensPriceState.isLoading)
                  WalletPageSkeletonFragments()
                else if (widget.tokensPriceState.hasValue)
                  Text(
                    '\$${toFixedTrunc((totalPrice).toString(), digits: 2)}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
