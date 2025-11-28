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
  LocaleNotifier() : super(AppLocale.en.flutterLocale) {
    _loadLocale();
  }

  static const _storageKey = 'locale_code';

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_storageKey);

    if (code != null && code.isNotEmpty) {
      final localeEnum = AppLocaleUtils.parse(code);

      state = localeEnum.flutterLocale;

      LocaleSettings.setLocale(localeEnum);
    } else {
      LocaleSettings.useDeviceLocale();
      final current = LocaleSettings.currentLocale;
      state = current.flutterLocale;

      await prefs.setString(_storageKey, current.languageTag);
    }
  }

  Future<void> changeLocale(AppLocale newLocale) async {
    state = newLocale.flutterLocale;

    LocaleSettings.setLocale(newLocale);

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
