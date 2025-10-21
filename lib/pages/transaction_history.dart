import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<String> _transactions = [];

  @override
  void initState() {
    super.initState();
    _getTranscationRecord();
  }

  void _getTranscationRecord() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _transactions = prefs.getStringList('transactions_data')!;
    });
    debugPrint('${_transactions}');
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
      body: SafeArea(child: _transactions.isEmpty ? _noTransactionWidget() : _transactionList()),
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
        final jsonStr = _transactions[index];
        String to = '';
        String amount = '';
        String symbol = '';
        try {
          final m = jsonDecode(jsonStr) as Map<String, dynamic>;
          to = m['to']?.toString() ?? '';
          amount = m['amount']?.toString() ?? '';
          symbol = m['tokenSymbol']?.toString() ?? '';
        } catch (_) {}
        return Container(
          padding: EdgeInsets.only(right: 12.w),
          width: double.infinity,
          height: 80.h,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10.r)),
          child: Row(
            children: [
              showImageLogo(symbol),
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
                        Text("to: ${shortAddr(to)}", style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                    Text(
                      amount,
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
