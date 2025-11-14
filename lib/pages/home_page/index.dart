import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:untitled1/constants/hive_boxes.dart';
import 'package:untitled1/hive/tokens.dart';
import 'package:untitled1/pages/home_page/fragments/home_page_appbar_fragments.dart';
import 'package:untitled1/pages/home_page/fragments/home_page_backup_fragments.dart';
import 'package:untitled1/pages/home_page/fragments/home_page_earn_coins_fragments.dart';
import 'package:untitled1/pages/home_page/fragments/home_page_full_chain_ranking_fragments.dart';
import 'package:untitled1/pages/home_page/fragments/home_page_more_fragments.dart';
import 'package:untitled1/pages/home_page/fragments/home_page_profile_fragments.dart';
import 'package:untitled1/pages/home_page/fragments/home_page_trading_contract_fragments.dart';
import 'package:untitled1/pages/home_page/fragments/home_page_trending_tokens_fragments.dart';
import 'package:untitled1/pages/home_page/fragments/home_page_user_guide_fragments.dart';
import 'package:untitled1/state/app_provider.dart';
import 'package:untitled1/util/HiveStorage.dart';
import 'package:untitled1/hive/Wallet.dart';

import '../../base/base_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with BasePage<HomePage>, AutomaticKeepAliveClientMixin {
  final EasyRefreshController _refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);
  late Future<String> _totalFuture;
  late Future<Wallet> _wallet;
  StreamSubscription? _hiveSub;
  StreamSubscription? _hiveWallet;
  List<Tokens> _tokenList = [];
  String tokensListKey(String address) => 'tokens_$address';

  @override
  void initState() {
    super.initState();
    _totalFuture = computeTotalFromHive2dp();
    _wallet = getCurrentSelectWallet();
    Hive.openBox(boxTokens).then((box) {
      _hiveSub = box.watch().listen((_) {
        setState(() {
          _totalFuture = computeTotalFromHive2dp();
        });
      });
    });
    Hive.openBox(boxWallet).then((box) {
      _hiveWallet = box.watch().listen((box) {
        setState(() {
          _wallet = getCurrentSelectWallet();
        });
      });
    });
  }

  @override
  void dispose() {
    _hiveSub?.cancel();
    _hiveWallet?.cancel();
    super.dispose();
  }

  Future<String> computeTotalFromHive2dp() async {
    final reqAddr = (await HiveStorage().getValue<String>('selected_address', boxName: boxWallet) ?? '').trim().toLowerCase();
    final key = tokensListKey(reqAddr);
    final raw = await HiveStorage().getList<Map>(key, boxName: boxTokens) ?? const <Map>[];
    final tokens = raw.map((e) => Tokens.fromJson(Map<String, dynamic>.from(e))).toList();
    if (mounted) setState(() => _tokenList = tokens);
    final sum = tokens.fold<double>(
      0.0,
      (acc, t) => acc + (double.tryParse(t.price.replaceAll(',', '').trim()) ?? 0.0) * (double.tryParse(t.number.replaceAll(',', '').trim()) ?? 0.0),
    );

    return sum.toStringAsFixed(2);
  }

  Future<Wallet> getCurrentSelectWallet() async {
    final wallet = await HiveStorage().getObject<Wallet>('currentSelectWallet', boxName: boxWallet) ?? Wallet.empty();
    return wallet;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        iconTheme: const IconThemeData(color: Colors.white),
        title: HomePageAppbarFragments(),
      ),
      body: EasyRefresh(
        controller: _refreshController,
        header: const ClassicHeader(),
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 30.h),
            padding: EdgeInsets.only(bottom: 40.h),
            child: Center(
              child: Column(
                children: [
                  HomePageProfileFragments(totalFuture: _totalFuture, wallet: _wallet),
                  HomePageMoreFragments(),
                  SizedBox(height: 15.h),
                  HomePageBackupFragments(),
                  // VerticalMarquee(
                  //   items: ['35%返佣待开启！卓越邀请人项目来袭！', '222222222', '333333333'],
                  //   itemHeight: 40,
                  //   scrollDuration: Duration(seconds: 3),
                  // ),
                  HomePageEarnCoinsFragments(),
                  HomePageFullChainRankingFragments(tokesList: _tokenList),
                  HomePageTrendingTokensFragments(),
                  SizedBox(height: 15.h),
                  HomePageTradingContractFragments(),
                  SizedBox(height: 15.h),
                  HomePageUserGuideFragments(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onRefresh() async {
    await _refreshRequest();
    _refreshController.finishRefresh();
  }

  Future<bool> _refreshRequest() async {
    bool resultStatus = true;
    return resultStatus;
  }

  @override
  bool get wantKeepAlive => true;
}

class MySearchBar extends StatefulWidget {
  const MySearchBar({super.key, required this.onSubmit});

  final void Function(String) onSubmit;

  @override
  State<StatefulWidget> createState() => _MySearchState();
}

class _MySearchState extends State<MySearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white),
      child: TextField(
        autofocus: true,
        decoration: const InputDecoration(
          hintText: "搜索",
          contentPadding: EdgeInsets.only(bottom: 10),
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
        onSubmitted: (content) {
          widget.onSubmit(content);
        },
      ),
    );
  }
}
