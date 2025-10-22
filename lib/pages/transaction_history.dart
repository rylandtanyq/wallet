import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/constants/hive_boxes.dart';
import 'package:untitled1/hive/transaction_record.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/theme/app_textStyle.dart';
import 'package:untitled1/util/HiveStorage.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  List<TransactionRecord> _transactions = [];
  String _txListKey(String address) => 'tx_$address';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadTranscationForAddress();
  }

  void loadTranscationForAddress() async {
    try {
      final address = await HiveStorage().getValue<String>('selected_address', boxName: boxWallet) ?? '';
      if (address.isEmpty) {
        if (!mounted) return;
        setState(() {
          _transactions = [];
          _loading = false;
        });
        return;
      }

      final key = _txListKey(address);

      // 强类型getList<TransactionRecord>报错，先使用弱类型getList<Map>
      final raw = await HiveStorage().getList<Map>(key, boxName: boxTx) ?? const <Map>[];

      // 逐个 Map 强转为 <String,dynamic> 再 fromJson
      final list = raw.map((m) => TransactionRecord.fromJson(Map<String, dynamic>.from(m))).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (!mounted) return;
      setState(() {
        _transactions = list;
        _loading = false;
      });
    } catch (e) {
      debugPrint('获取交易记录失败: $e');
      if (!mounted) return;
      setState(() {
        _transactions = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leadingWidth: 40,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.w, color: Theme.of(context).colorScheme.onBackground),
          onPressed: () {
            Feedback.forTap(context);
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: Text(t.home.trade_history, style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
        ),
      ),

      /// body
      body: SafeArea(child: _loading ? _noTransactionWidget() : _transactionList()),
    );
  }

  /// 无交易记录时显示
  Widget _noTransactionWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book, size: 100.w, color: Theme.of(context).colorScheme.onSurfaceVariant),
          SizedBox(height: 16.h),
          Text(t.home.no_transfer_records_yet, style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  /// 有交易记录时显示
  Widget _transactionList() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: _transactions.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final item = _transactions[index];
        return Container(
          padding: EdgeInsets.only(right: 12.w),
          width: double.infinity,
          height: 80.h,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10.r)),
          child: Row(
            children: [
              showImageLogo(item.tokenSymbol),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          t.home.transfer,
                          style: AppTextStyles.size19.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                        ),
                        Text("to: ${shortAddr(item.to)}", style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                    Text(
                      '${item.amount}',
                      style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String shortAddr(String s, {int head = 6, int tail = 6, String sep = '…'}) {
    if (s.isEmpty) return '';
    if (s.length <= head + tail) return s;
    return '${s.substring(0, head)}$sep${s.substring(s.length - tail)}';
  }

  Widget showImageLogo(String tokenSymbol) {
    switch (tokenSymbol) {
      case 'SOL':
        return Image.asset('assets/images/solana_logo.png', width: 70, height: 70);
      case 'USDT':
        return Image.asset('assets/images/USDT.png', width: 70, height: 70);
      default:
        return SizedBox();
    }
  }
}
