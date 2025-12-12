//
import 'package:feature_main/src/home_page/models/token_price_model.dart';
import 'package:feature_main/src/home_page/service/wallet_page_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getWalletTokensPriceProvide = StateNotifierProvider.family<GetWalletTokensPriceNotifier, AsyncValue<TokenPriceModel>, List<String>>((ref, arg) {
  return GetWalletTokensPriceNotifier();
});
