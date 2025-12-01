import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:shared_utils/hive_storage.dart';
import 'package:shared_utils/hive_boxes.dart';
import 'package:feature_wallet/hive/Wallet.dart';

Future<String> calcTotalBalanceReadable() async {
  final wallets = await HiveStorage().getList<Wallet>('wallets_data', boxName: boxWallet) ?? [];

  Decimal parseBalance(String s) {
    // 去掉逗号、空格等，空则按0
    final cleaned = (s.isEmpty ? '0' : s.replaceAll(',', '').trim());
    // 防御：非法字符串当0处理
    return Decimal.tryParse(cleaned) ?? Decimal.zero;
  }

  final total = wallets.fold<Decimal>(Decimal.zero, (acc, w) => acc + parseBalance(w.balance));

  // 根据需要设置小数位数
  final formatted = NumberFormat('#,##0.########').format(double.parse(total.toString()));
  return formatted; // e.g. "12,345.6789"
}
