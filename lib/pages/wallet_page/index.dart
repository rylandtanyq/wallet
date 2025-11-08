import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:untitled1/constants/hive_boxes.dart';
import 'package:untitled1/hive/Wallet.dart';
import 'package:untitled1/hive/tokens.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:solana_wallet/solana_package.dart';
import 'package:untitled1/pages/wallet_page/fragments/wallet_page_action_fragments.dart';
import 'package:untitled1/pages/wallet_page/fragments/wallet_page_bankcard_fragments.dart';
import 'package:untitled1/pages/wallet_page/fragments/wallet_page_build_top_frafments.dart';
import 'package:untitled1/pages/wallet_page/fragments/wallet_page_defi_fragments.dart';
import 'package:untitled1/pages/wallet_page/fragments/wallet_page_nft_fragment.dart';
import 'package:untitled1/pages/wallet_page/fragments/wallet_page_screen_loader_fragments.dart';
import 'package:untitled1/pages/wallet_page/fragments/wallet_page_token_fragments.dart';
import 'package:untitled1/pages/wallet_page/models/token_price_model.dart';
import 'package:untitled1/state/app_provider.dart';
import 'package:untitled1/theme/app_textStyle.dart';
import 'package:untitled1/util/fetchTokenBalances.dart';
import '../../base/base_page.dart';
import '../../util/HiveStorage.dart';
import '../../widget/dialog/SelectWalletDialog.dart';
import '../../widget/dialog/FullScreenDialog.dart';
import '../../widget/StickyTabBarDelegate.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> with BasePage<WalletPage>, TickerProviderStateMixin, WidgetsBindingObserver {
  // ignore: constant_identifier_names
  static const String kSOL_KEY = 'SOL';
  final EasyRefreshController _refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);
  final solana = Solana();
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final defaultNetwork = {"id": "Solana", "path": "assets/images/solana_logo.png"};
  final loader = FullscreenLoader();
  late Map<String, String> _currentNetwork = {};
  late List<Tokens> _tokenList = [];
  late List<Tokens> _fillteredTokensList = [];
  late List<String> _addresses = [];
  late final WalletActions actions;
  late TabController _tabController;
  String? tokensSearchContent;
  int _selectedNetWorkIndex = 0; // 存储选中的索引
  Wallet _wallet = Wallet.empty();
  ProviderSubscription<AsyncValue<TokenPriceModel>>? _priceSub;
  Timer? _timer;
  bool _hadLocalTokens = false; // 本地有没有 token, 用于判定是否显示空态
  Map<String, String> _lastPriceMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) setState(() {});
    });
    _searchController.addListener(_filterItems);
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
    actions = WalletActions(
      reloadTokens: _loadingTokens,
      reloadTokensPrice: _refreshTokenPrice,
      reloadTokensAmount: _refreshTokenAmounts,
      reloadCurrentSelectWalletfn: _getCurrentSelectWalletfn,
      onSearchChange: _onSearchChange,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    _timer?.cancel();
    _priceSub?.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 当应用从后台返回前台时调用
      _loadWalletData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 监听路由的显示状态
    ModalRoute? route = ModalRoute.of(context);
    if (route != null) {
      route.addScopedWillPopCallback(() async {
        return true;
      });
    }
  }

  @override
  void didUpdateWidget(WalletPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当页面重新进入视图时调用
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      _loadWalletData();
    }
  }

  Future<void> _bootstrap() async {
    try {
      await _loadingTokens();
      await _getCurrentSelectWalletfn();
      await _initWalletAndNetwork();
      unawaited(_refreshTokenPrice());
      unawaited(_refreshTokenAmounts());
    } catch (e, st) {
      debugPrint('init error: $e\n$st');
    }
  }

  Future<void> _loadingTokens() async {
    if (mounted) setState(() {});
    final rawList = await HiveStorage().getList<Map>('tokens', boxName: boxTokens) ?? <Map>[];
    _tokenList = rawList.map((e) => Tokens.fromJson(Map<String, dynamic>.from(e))).toList();
    _fillteredTokensList = List.from(_tokenList);
    // 如果本地没有代币, 则显示空状态
    _hadLocalTokens = _tokenList.isNotEmpty;
    final existsSolana = _tokenList.any((token) => token.title.toUpperCase() == 'SOL' || token.title.toUpperCase() == 'SOLANA');
    if (!existsSolana) {
      final solanaToken = Tokens(
        image: 'assets/images/solana_logo.png',
        title: 'SOL',
        subtitle: 'Solana',
        price: '0.00',
        number: '0.00',
        toadd: true,
        tokenAddress: 'SOL',
      );
      _tokenList.add(solanaToken);
      _fillteredTokensList = List.from(_tokenList);
      _hadLocalTokens = true;

      final list = _tokenList.map((t) => t.toJson()).toList();
      await HiveStorage().putList<Map>('tokens', list, boxName: boxTokens);
    }
    if (mounted) setState(() {});
  }

  Future<void> _refreshTokenPrice() async {
    // 收集地址（统一小写、去重；SOL 无地址先略过）
    final addresses = _tokenList.map((t) => t.tokenAddress.trim()).where((s) => s.isNotEmpty).toSet().toList();

    final hasSol = _tokenList.any((t) => t.tokenAddress.trim().isEmpty && t.title.toUpperCase() == 'SOL');

    if (hasSol && !_addresses.contains(kSOL_KEY)) _addresses.add(kSOL_KEY);

    if (mounted) setState(() => _addresses = addresses);
    if (addresses.isEmpty) return;

    if (!mounted) return;
    ref.read(getWalletTokensPriceProvide(_addresses).notifier).fetchWalletTokenPriceData(_addresses);
    _priceSub?.close();
    _priceSub = ref.listenManual<AsyncValue<TokenPriceModel>>(getWalletTokensPriceProvide(_addresses), (prev, next) {
      next.when(
        data: (data) async {
          debugPrint('data print: $data');
          // 建映射：address -> unitPrice
          final priceMap = <String, String>{for (final p in data.result) p.address.trim(): p.unitPrice};
          debugPrint('priceMap print: $priceMap');
          if (mounted) setState(() => _lastPriceMap = priceMap);

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

          // 回写 Hive + 刷新 UI
          final toSave = _tokenList.map((t) => t.toJson()).toList();
          await HiveStorage().putList<Map>('tokens', toSave, boxName: boxTokens);

          _fillteredTokensList = List.from(_tokenList);
          if (mounted) setState(() {});
        },
        loading: () {},
        error: (e, StackTrace) => debugPrint('get token price failed: $e'),
      );
    });
  }

  Future<void> _refreshTokenAmounts() async {
    // 读取当前地址 & RPC
    final wallet = await HiveStorage().getObject<Wallet>('currentSelectWallet', boxName: boxWallet) ?? Wallet.empty();
    final owner = wallet.address;
    if (owner.isEmpty) return;

    // 收集 mint（忽略 SOL：tokenAddress 为空）
    final mints = _tokenList.map((t) => t.tokenAddress.trim()).where((s) => s.isNotEmpty).toList();
    if (mints.isEmpty) return;

    try {
      // 批量拉数量
      final amountMap = await fetchTokenBalancesBatch(ownerAddress: owner, mintAddresses: mints);

      // 合并回内存
      for (var i = 0; i < _tokenList.length; i++) {
        final t = _tokenList[i];
        final key = t.tokenAddress.trim();
        if (key.isEmpty) continue; // 先不处理 SOL
        final newAmount = amountMap[key];
        if (newAmount == null) continue;

        _tokenList[i] = Tokens(
          image: t.image,
          title: t.title,
          subtitle: t.subtitle,
          price: t.price,
          number: newAmount, // 覆盖数量
          toadd: t.toadd,
          tokenAddress: t.tokenAddress,
        );
      }

      // 回写 Hive + 刷新 UI
      final toSave = _tokenList.map((t) => t.toJson()).toList();
      await HiveStorage().putList<Map>('tokens', toSave, boxName: boxTokens);
      _fillteredTokensList = List.from(_tokenList);
      if (mounted) setState(() {});
    } catch (e, st) {
      debugPrint('_refreshTokenAmounts error: $e\n$st');
    }
  }

  Future<Map<String, String>> fetchTokenBalancesBatch({required String ownerAddress, required List<String> mintAddresses}) async {
    final mints = mintAddresses.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final results = <String, String>{};
    for (final m in mints) {
      final amt = await fetchTokenBalance(ownerAddress: ownerAddress, mintAddress: m);
      debugPrint('amt print: $amt');
      results[m] = amt; // m 已经是 lower-case
    }
    return results;
  }

  Future<void> _onSearchChange(String value) async {
    if (_timer?.isActive ?? false) _timer?.cancel();
    _timer = Timer(Duration(milliseconds: 300), () {
      final query = value.trim().toLowerCase();
      setState(() {
        if (query.isEmpty) {
          _fillteredTokensList = List.from(_tokenList);
        } else {
          _fillteredTokensList = _tokenList.where((token) {
            return token.title.toLowerCase().contains(query) || token.subtitle.toLowerCase().contains(query);
          }).toList();
        }
      });
    });
  }

  Future<void> _getCurrentSelectWalletfn() async {
    final w = await HiveStorage().getObject<Wallet>('currentSelectWallet', boxName: boxWallet) ?? Wallet.empty();
    final currentNetworkResult = await HiveStorage().getObject<Map>("currentNetwork");
    if (currentNetworkResult != null) {
      _currentNetwork = Map<String, String>.from(currentNetworkResult);
    } else {
      _currentNetwork = Map<String, String>.from(defaultNetwork);
      HiveStorage().putObject('currentNetwork', _currentNetwork);
    }
    if (!mounted) return;
    setState(() {
      _wallet = w;
    });
  }

  Future<void> _initWalletAndNetwork() async {
    final wallet = await HiveStorage().getObject<Wallet>('currentSelectWallet', boxName: boxWallet);
    final network = await HiveStorage().getObject<Map>('currentNetwork');

    if (wallet != null) {
      if (mounted) setState(() => _wallet = wallet);
    } else {
      _wallet = Wallet.empty();
    }

    if (network != null) {
      _currentNetwork = Map<String, String>.from(network);
    } else {
      _currentNetwork = Map<String, String>.from(defaultNetwork);
      await HiveStorage().putObject('currentNetwork', _currentNetwork);
    }
  }

  Future<void> _loadWalletData() async {
    try {
      final wallet = await HiveStorage().getObject<Wallet>('currentSelectWallet', boxName: boxWallet);
      if (wallet != null) {
        setState(() => _wallet = wallet);
      }
    } catch (e) {
      debugPrint("loadding wallet error:: $e");
    }
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {});
  }

  String _getCommonName(String key) {
    switch (key) {
      case 'allNetworks':
        return t.common.allNetworks;
      case 'Solana':
        return t.common.Solana;
      case 'BNB':
        return t.common.BNB;
      case 'Bitcoin':
        return t.common.Bitcoin;
      case 'Base':
        return t.common.Base;
      case 'Ethereum':
        return t.common.Ethereum;
      case 'Polygon':
        return t.common.Polygon;
      case 'Arbitrum':
        return t.common.Arbitrum;
      case 'Sui':
        return t.common.Sui;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final List<String> categories = [t.common.token, 'DeFi', 'NFT', t.home.bankCard];
    final id = _currentNetwork['id'] ?? 'allNetworks';
    final languageNetName = _getCommonName(id);
    final List<String> titles = [t.home.transfer, t.home.receive, t.home.finance, t.home.getGas, t.home.transaction_history];
    final List<Map<String, String>> items = [
      // {"id": "allNetworks", "path": "assets/images/all_network.png", "netName": t.common.allNetworks},
      {"id": "Solana", "path": "assets/images/solana_logo.png", "netName": t.common.Solana},
      // {"id": "BNB", "path": "assets/images/BTC.png", "netName": t.common.BNB},
      // {"id": "Bitcoin", "path": "assets/images/BTC.png", "netName": t.common.Bitcoin},
      // {"id": "Base", "path": "assets/images/BTC.png", "netName": t.common.Base},
      // {"id": "Ethereum", "path": "assets/images/BTC.png", "netName": t.common.Ethereum},
      // {"id": "Polygon", "path": "assets/images/BTC.png", "netName": t.common.Polygon},
      // {"id": "Arbitrum", "path": "assets/images/BTC.png", "netName": t.common.Arbitrum},
      // {"id": "Sui", "path": "assets/images/BTC.png", "netName": t.common.Sui},
    ];

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    //弹出钱包Dialog
                    showSelectWalletDialog();
                  },
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.asset('assets/images/ic_clip_photo.png', width: 30.w, height: 30.w, fit: BoxFit.cover),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _wallet.name,
                        style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.keyboard_arrow_down_rounded),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final currentSelectNetwork = await showAnimatedFullScreenDialog(context, items);
                  if (currentSelectNetwork != null) {
                    await HiveStorage().putObject('currentNetwork', currentSelectNetwork);
                    setState(() {
                      _currentNetwork = currentSelectNetwork;
                      _wallet.network = currentSelectNetwork['id']!;
                    });
                  }
                },
                child: ClipOval(
                  child: Image.asset(_currentNetwork['path'] ?? items[_selectedNetWorkIndex]["path"]!, width: 25.w, height: 25.w, fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        ),
      ),
      body: EasyRefresh(
        controller: _refreshController,
        header: const ClassicHeader(),
        onRefresh: _onRefresh,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: _buildPageContent(titles, categories, actions),
        ),
      ),
    );
  }

  //选择网络弹窗
  Future<Map<String, String>?> showAnimatedFullScreenDialog(BuildContext context, List<Map<String, String>> items) async {
    _currentNetwork = Map<String, String>.from(await HiveStorage().getObject<Map>("currentNetwork") ?? defaultNetwork);
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullScreenDialog(
            title: t.transfer_receive_payment.selectNetwork,
            child: Column(
              children: [
                // 搜索框
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: t.common.searchNetwork,
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onBackground),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface, // 背景颜色
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22.r), // 圆角22
                        borderSide: BorderSide.none, // 去除边框线
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                    ),
                  ),
                ),
                // 列表
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final itemCurrent = items[index];
                      final isSelected = itemCurrent['netName'] == _currentNetwork["id"];
                      return ListTile(
                        leading: Image.asset(itemCurrent["path"] ?? "", width: 37.5.w, height: 37.5.w),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                itemCurrent["netName"] ?? "",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onBackground,
                                ),
                              ),
                            ),
                            if (isSelected) Image.asset('assets/images/ic_wallet_new_work_selected.png', width: 24, height: 24),
                          ],
                        ),
                        contentPadding: EdgeInsetsGeometry.symmetric(vertical: 10, horizontal: 10),
                        onTap: () {
                          setState(() {
                            _selectedNetWorkIndex = index;
                          });
                          _wallet.network = itemCurrent['id']!;
                          Navigator.pop(context, {"id": "${itemCurrent['id']}", "path": "${itemCurrent['path']}"});
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  Future<void> showSelectWalletDialog() async {
    final resultWallet = await showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => SelectWalletDialog());
    if (resultWallet is Wallet) {
      setState(() => _wallet = resultWallet);
      // ignore: use_build_context_synchronously
      loader.show(context);
      try {
        await _initWalletAndNetwork();
        await Future.wait([_refreshTokenPrice(), _refreshTokenAmounts()]);
      } catch (e) {
        debugPrint('wallet toggle failed: $e');
      } finally {
        loader.hide();
        setState(() {});
      }
    }
  }

  Widget _buildPageContent(titles, List<String> categories, WalletActions actions) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: WalletPageBuildTopFrafments(wallet: _wallet, fillteredTokensList: _fillteredTokensList, actions: actions),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: StickyTabBarDelegate(
            child: TabBar(
              controller: _tabController,
              tabs: categories.map((tab) => Tab(text: tab)).toList(),
              labelColor: Theme.of(context).colorScheme.onBackground,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
              dividerColor: Colors.transparent,
              labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 1.5.h, color: Theme.of(context).colorScheme.onBackground),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 5.h,
              indicatorPadding: EdgeInsets.symmetric(horizontal: 15),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: IndexedStack(
            index: _tabController.index,
            children: [
              WalletPageTokenFragments(
                actions: actions,
                textEditingController: _textEditingController,
                hadLocalTokens: _hadLocalTokens,
                addresses: _addresses,
                fillteredTokensList: _fillteredTokensList,
                lastPriceMap: _lastPriceMap,
              ),
              WalletPageDefiFragments(),
              WalletPageNftFragment(),
              WalletPageBankcardFragments(),
            ],
          ),
        ),
      ],
    );
  }

  void _onRefresh() async {
    await _refreshRequest();
    unawaited(_refreshTokenPrice());
    unawaited(_refreshTokenAmounts());
    _refreshController.finishRefresh();
  }

  Future<bool> _refreshRequest() async {
    bool resultStatus = true;
    return resultStatus;
  }

  @override
  bool get wantKeepAlive => true;
}
