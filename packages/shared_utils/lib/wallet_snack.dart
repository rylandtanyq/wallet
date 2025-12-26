import 'package:flutter/material.dart';

class WalletSnack {
  WalletSnack._();
  static final GlobalKey<ScaffoldMessengerState> key = GlobalKey<ScaffoldMessengerState>(debugLabel: 'wallet_snack');

  static void closeAll() {
    key.currentState?.clearSnackBars();
  }

  static void show(String title, String message, {Duration duration = const Duration(seconds: 2)}) {
    final messenger = key.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(duration: duration, content: Text('$title：$message')));
  }
}
