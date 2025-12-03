import 'dart:async';

import 'package:feature_wallet/hive/Wallet.dart';
import 'package:feature_wallet/hive/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:shared_utils/hive_storage.dart';
import 'package:shared_utils/hive_boxes.dart';
import 'package:shared_utils/to_fixed_trunc.dart';
import 'package:shared_utils/token_icon.dart';

class SearchPageCurrencyFragments extends StatefulWidget {
  const SearchPageCurrencyFragments({super.key});

  @override
  State<SearchPageCurrencyFragments> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SearchPageCurrencyFragments> {
  List<Tokens> _tokenList = [];
  late Future<String> _totalFuture;
  late Future<Wallet> _wallet;
  StreamSubscription? _hiveSub;
  String tokensListKey(String address) => 'tokens_$address';

  @override
  void initState() {
    super.initState();
    _totalFuture = computeTotalFromHive2dp();
    _wallet = getCurrentSelectWallet();
    Hive.openBox(boxTokens).then((box) {
      _hiveSub = box.watch().listen((_) {
        setState(() {
          _totalFuture = computeTotalFromHive2dp();
        });
      });
    });
  }

  @override
  void dispose() {
    _hiveSub?.cancel();
    super.dispose();
  }

  Future<String> computeTotalFromHive2dp() async {
    final reqAddr = (await HiveStorage().getValue<String>('selected_address', boxName: boxWallet) ?? '').trim().toLowerCase();
    final key = tokensListKey(reqAddr);
    final raw = await HiveStorage().getList<Map>(key, boxName: boxTokens) ?? const <Map>[];
    final tokens = raw.map((e) => Tokens.fromJson(Map<String, dynamic>.from(e))).toList();
    if (mounted) setState(() => _tokenList = tokens);
    final sum = tokens.fold<double>(
      0.0,
      (acc, t) => acc + (double.tryParse(t.price.replaceAll(',', '').trim()) ?? 0.0) * (double.tryParse(t.number.replaceAll(',', '').trim()) ?? 0.0),
    );

    return sum.toStringAsFixed(2);
  }

  Future<Wallet> getCurrentSelectWallet() async {
    final wallet = await HiveStorage().getObject<Wallet>('currentSelectWallet', boxName: boxWallet) ?? Wallet.empty();
    return wallet;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      // padding: EdgeInsets.all(8),
      itemCount: _tokenList.length.clamp(0, 5).toInt(),
      itemBuilder: (context, index) => _buildItemRow(_tokenList[index], context),
    );
  }

  Widget _buildItemRow(Tokens item, BuildContext context) {
    final number = double.tryParse(item.number);
    final price = double.tryParse(item.price);
    final totalPrice = number! * price!;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
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
              Text(
                '\$${toFixedTrunc((totalPrice).toString(), digits: 2)}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
