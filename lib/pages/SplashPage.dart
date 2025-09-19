import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled1/hive/create_solana_wallet.dart';
import 'package:untitled1/pages/CreateWalletPage.dart';
import 'package:untitled1/pages/tabpage/HomePage.dart';

class Splashpage extends StatefulWidget {
  const Splashpage({super.key});

  @override
  State<Splashpage> createState() => _SplashpageState();
}

class _SplashpageState extends State<Splashpage> {
  final solana_wallet = CreateSolanaWallet.empty();
  // debugPrint('$solana_wallet');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (solana_wallet.address.isEmpty) {
        debugPrint("没有创建钱包");
        Get.off(Createwalletpage());
      } else {
        Get.off(HomePage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("启动页")));
  }
}
