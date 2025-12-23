import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:feature_im/feature_im.dart';
import 'package:feature_im/im_host_bridge.dart';
import 'package:feature_main/src/home_page/models/token_price_model.dart';
import 'package:feature_main/src/home_page/service/home_page_provider.dart';
import 'package:feature_main/src/home_page/utils/k_build_coins.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:shared_setting/state/app_provider.dart';
import 'package:shared_ui/widget/base_page.dart';
import 'package:shared_utils/hive_storage.dart';
import 'package:shared_utils/hive_boxes.dart';
import 'package:shared_utils/wallet_nav.dart';
import 'package:feature_wallet/hive/tokens.dart';
import 'package:feature_main/src/home_page/fragments/home_page_appbar_fragments.dart';
import 'package:feature_main/src/home_page/fragments/home_page_full_chain_ranking_fragments.dart';
import 'package:feature_main/src/home_page/fragments/home_page_more_fragments.dart';
import 'package:feature_main/src/home_page/fragments/home_page_profile_fragments.dart';
import 'package:feature_main/src/home_page/fragments/home_page_user_guide_fragments.dart';
import 'package:feature_wallet/hive/Wallet.dart';

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
  late List<String> _addresses = [];
  ProviderSubscription<AsyncValue<TokenPriceModel>>? _priceSub;
  String tokensListKey(String address) => 'tokens_$address';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
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
    _priceSub?.close();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _loaddingTokens();
    await _refreshTokensPrice();
  }

  Future<String> computeTotalFromHive2dp() async {
    final reqAddr = (await HiveStorage().getValue<String>('selected_address', boxName: boxWallet) ?? '').trim().toLowerCase();
    final key = tokensListKey(reqAddr);
    final raw = await HiveStorage().getList<Map>(key, boxName: boxTokens) ?? const <Map>[];
    final tokens = raw.map((e) => Tokens.fromJson(Map<String, dynamic>.from(e))).toList();
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

  Future<void> _loaddingTokens() async {
    _tokenList
      ..clear()
      ..addAll(kBuiltCoins);

    if (mounted) setState(() {});
  }

  Future<void> _refreshTokensPrice() async {
    // 收集地址（统一小写、去重；SOL 无地址先略过）
    final addresses = _tokenList.map((t) => t.tokenAddress.trim()).where((s) => s.isNotEmpty).toSet().toList();
    if (mounted) setState(() => _addresses = addresses);

    ref.read(getWalletTokensPriceProvide(_addresses).notifier).fetchWalletTokenPriceData(_addresses);
    _priceSub?.close();
    _priceSub = ref.listenManual<AsyncValue<TokenPriceModel>>(getWalletTokensPriceProvide(_addresses), (prev, next) {
      next.when(
        data: (data) {
          final priceMap = <String, String>{for (final p in data.result) p.address.trim(): p.unitPrice};

          // 合并回内存列表
          for (var i = 0; i < _tokenList.length; i++) {
            final t = _tokenList[i];
            final addr = t.tokenAddress.trim();

            final newPrice = priceMap[addr];
            if (newPrice == null) continue;

            _tokenList[i] = Tokens(
              image: t.image,
              title: t.title,
              subtitle: t.subtitle,
              price: newPrice, // 覆盖价格
              number: t.number,
              toadd: t.toadd,
              tokenAddress: t.tokenAddress,
            );
          }
          if (mounted) setState(() {});
        },
        loading: () {},
        error: (e, StackTrace) {},
      );
    });
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
                  // HomePageBackupFragments(),
                  // HomePageEarnCoinsFragments(),
                  HomePageFullChainRankingFragments(tokesList: _tokenList),
                  // HomePageTrendingTokensFragments(),
                  // SizedBox(height: 15.h),
                  // HomePageTradingContractFragments(),
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
    _bootstrap();
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
