import 'package:flutter/material.dart';

class SettingWalletBuildBackButtonFragments extends StatelessWidget {
  const SettingWalletBuildBackButtonFragments({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new, // iOS样式箭头
        size: 20,
        color: Colors.black,
      ),
      onPressed: () => Navigator.pop(context),
    );
  }
}
