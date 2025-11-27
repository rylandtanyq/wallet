import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_setting/i18n/strings.g.dart';

import 'package:shared_utils/theme_persistence.dart';

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
  // 默认语言：用 shared_setting 这份的 AppLocale
  LocaleNotifier() : super(AppLocale.en.flutterLocale) {
    _loadLocale();
  }

  static const _storageKey = 'locale_code';

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_storageKey);

    if (code != null && code.isNotEmpty) {
      // 1. 从本地存的 languageTag 恢复成 shared_setting 的 AppLocale
      final localeEnum = AppLocaleUtils.parse(code);

      // 2. 更新给 MaterialApp 用的 Locale
      state = localeEnum.flutterLocale;

      // 3. 通知 slang：当前语言切成这个（多 package 会自动同步）
      LocaleSettings.setLocale(localeEnum);
    } else {
      // 没有存过，就按设备语言来一次（可选逻辑）
      // 如果你不想自动用设备语言，也可以直接删掉这一块，只保留 en
      LocaleSettings.useDeviceLocale();
      final current = LocaleSettings.currentLocale;
      state = current.flutterLocale;

      // 顺便存一份，避免下次再算
      await prefs.setString(_storageKey, current.languageTag);
    }
  }

  /// 外部调用：仍然是 AppLocale 类型，
  /// 但 **这个 AppLocale 必须来自 shared_setting 的 strings.g.dart**
  Future<void> changeLocale(AppLocale newLocale) async {
    // 1. 更新 MaterialApp 用的 Locale
    state = newLocale.flutterLocale;

    // 2. 通知 slang：切换语言（其他分包的 t.xxx 会一起跟着变）
    LocaleSettings.setLocale(newLocale);

    // 3. 存到本地
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, newLocale.languageTag);
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

class BiometricsNotifier extends StateNotifier<bool> {
  static const _preBiometricKey = 'biometric';
  BiometricsNotifier() : super(true) {
    loadBiometrics();
  }

  Future<void> loadBiometrics() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_preBiometricKey);
    if (value != null) {
      state = value;
    }
  }

  Future<void> toggleBiometrics() async {
    final newState = !state;
    state = newState;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_preBiometricKey, newState);
  }
}
