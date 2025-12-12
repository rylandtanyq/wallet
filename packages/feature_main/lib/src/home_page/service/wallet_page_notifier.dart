import 'package:feature_main/src/home_page/models/token_price_model.dart';
import 'package:feature_main/src/home_page/network/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetWalletTokensPriceNotifier extends StateNotifier<AsyncValue<TokenPriceModel>> {
  GetWalletTokensPriceNotifier() : super(const AsyncLoading());

  Future fetchWalletTokenPriceData(List<String> data) async {
    try {
      final walletTokensPriceData = await WalletApi.listWalletTokenDataFetch(data);
      state = AsyncValue.data(walletTokensPriceData);
    } catch (e) {
      debugPrint('token price fail: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
