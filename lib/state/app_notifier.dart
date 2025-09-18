import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
