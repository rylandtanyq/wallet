import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/pages/wallet_page/models/token_price_model.dart';
import 'package:untitled1/request/request.api.dart';
import 'package:untitled1/util/theme_persistence.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final mode = await ThemePersistence.loadThemeMode();
    state = mode;
  }

  void setTheme(ThemeMode mode) async {
    state = mode;
    await ThemePersistence.saveThemeMode(mode);
  }

  void toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    await ThemePersistence.saveThemeMode(newMode);
  }
}

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(AppLocale.en.flutterLocale) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString("locale_code");
    if (code != null) {
      state = AppLocaleUtils.parse(code).flutterLocale;
      LocaleSettings.setLocale(AppLocaleUtils.parse(code));
    }
  }

  Future<void> changeLocale(AppLocale newLocale) async {
    state = newLocale.flutterLocale;
    LocaleSettings.setLocale(newLocale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("locale_code", newLocale.languageTag);
  }
}

class RiseAndFallCycleNotifier extends StateNotifier<String> {
  static const _prefKey = "riseAndFallCycleKey";

  RiseAndFallCycleNotifier() : super(t.Mysettings.zero_clock_change) {
    loadRiseAndFallCycle();
  }

  Future<void> loadRiseAndFallCycle() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> setRiseAndFallCycle(String key) async {
    state = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, key);
  }
}

class GetWalletTokensNotifier extends StateNotifier<AsyncValue<dynamic>> {
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
