import 'package:feature_wallet/src/add_tokens_page/models/add_tokens_model.dart';
import 'package:feature_wallet/src/add_tokens_page/models/search_token_model.dart';
import 'package:feature_wallet/src/add_tokens_page/network/repository.dart';
// import 'package:feature_wallet/src/wallet_page/network/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetWalletTokensNotifier extends StateNotifier<AsyncValue<AddTokensModel>> {
  GetWalletTokensNotifier() : super(const AsyncLoading());

  Future fetchWalletTokenData(String tokenAddress) async {
    try {
      final walletTokenData = await WalletApi.walletTokensDataFetch(tokenAddress);
      state = AsyncValue.data(walletTokenData);
    } catch (e) {
      debugPrint('获取钱包代币失败: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

class GetWalletSearchTokenNotifier extends StateNotifier<AsyncValue<SearchTokenModel>> {
  GetWalletSearchTokenNotifier() : super(const AsyncLoading());

  Future fetchWalletSearchTokenData(String name) async {
    try {
      final walletSearchTokenData = await WalletApi.searchTokenFetch(name);
      state = AsyncValue.data(walletSearchTokenData);
    } catch (e) {
      debugPrint('search token fail: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
