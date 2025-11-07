import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled1/pages/add_tokens_page/models/add_tokens_model.dart';
import 'package:untitled1/pages/wallet_page/models/token_price_model.dart';
import 'package:untitled1/state/app_notifier.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

final riseAndFallCycleProvide = StateNotifierProvider<RiseAndFallCycleNotifier, String>((ref) {
  return RiseAndFallCycleNotifier();
});

final getWalletTokensProvide = StateNotifierProvider.family<GetWalletTokensNotifier, AsyncValue<AddTokensModel>, String>((ref, tokenAddress) {
  return GetWalletTokensNotifier();
});

final getWalletTokensPriceProvide = StateNotifierProvider.family<GetWalletTokensPriceNotifier, AsyncValue<TokenPriceModel>, List<String>>((ref, arg) {
  return GetWalletTokensPriceNotifier();
});
