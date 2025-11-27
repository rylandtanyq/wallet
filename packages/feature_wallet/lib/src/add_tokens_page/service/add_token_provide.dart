import 'package:feature_wallet/src/add_tokens_page/models/add_tokens_model.dart';
import 'package:feature_wallet/src/add_tokens_page/models/search_token_model.dart';
import 'package:feature_wallet/src/add_tokens_page/service/add_token_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getWalletTokensProvide = StateNotifierProvider.family<GetWalletTokensNotifier, AsyncValue<AddTokensModel>, String>((ref, tokenAddress) {
  return GetWalletTokensNotifier();
});

final getWalletSearchTokenProvide = StateNotifierProvider.family<GetWalletSearchTokenNotifier, AsyncValue<SearchTokenModel>, String>((ref, name) {
  return GetWalletSearchTokenNotifier();
});
