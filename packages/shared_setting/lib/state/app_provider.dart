import 'app_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

final riseAndFallCycleProvide = StateNotifierProvider<RiseAndFallCycleNotifier, String>((ref) {
  return RiseAndFallCycleNotifier();
});

final getBioMetricsProvide = StateNotifierProvider<BiometricsNotifier, bool>((ref) {
  return BiometricsNotifier();
});
