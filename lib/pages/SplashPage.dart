import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled1/hive/transaction_record.dart';
import 'package:untitled1/pages/CreateWalletPage.dart';
import 'package:untitled1/pages/tabpage/HomePage.dart';

class Splashpage extends StatefulWidget {
  const Splashpage({super.key});

  @override
  State<Splashpage> createState() => _SplashpageState();
}

class _SplashpageState extends State<Splashpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("启动页")));
  }
}
