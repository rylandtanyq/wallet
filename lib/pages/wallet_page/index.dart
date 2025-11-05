import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:untitled1/constants/hive_boxes.dart';
import 'package:untitled1/core/AdvancedMultiChainWallet.dart';
import 'package:untitled1/hive/Wallet.dart';
import 'package:untitled1/hive/tokens.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/pages/BackUpHelperOnePage.dart';
import 'package:untitled1/pages/BackUpHelperPage.dart';
import 'package:untitled1/pages/CoinDetailPage.dart';
import 'package:untitled1/pages/SelectedPayeePage.dart';
import 'package:untitled1/pages/SelectTransferCoinTypePage.dart';
import 'package:solana_wallet/solana_package.dart';
import 'package:untitled1/pages/add_tokens_page/index.dart';
import 'package:untitled1/pages/transaction_history.dart';
import 'package:untitled1/request/request.api.dart';
import 'package:untitled1/servise/solana_servise.dart';
import 'package:untitled1/state/app_provider.dart';
import 'package:untitled1/theme/app_textStyle.dart';
import 'package:untitled1/util/fetchTokenBalances.dart';
import 'package:untitled1/widget/tokenIcon.dart';
import '../../base/base_page.dart';
import '../../constants/AppColors.dart';
import '../../util/HiveStorage.dart';
import '../../entity/Token.dart';
import '../../widget/dialog/SelectWalletDialog.dart';
import '../../widget/dialog/FullScreenDialog.dart';
import '../../widget/StickyTabBarDelegate.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> with BasePage<WalletPage>, TickerProviderStateMixin, WidgetsBindingObserver {
  final EasyRefreshController _refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);
  final solana = Solana();
  final TextEditingController _textEditingController = TextEditingController();
  String? tokensSearchContent;

  final List<Widget> _navIcons = [
    Image.asset('assets/images/ic_wallet_transfer.png', width: 48.w, height: 48.w),
    Image.asset('assets/images/ic_home_grid_collection.png', width: 48.w, height: 48.w),
    Image.asset('assets/images/ic_wallet_finance.png', width: 48.w, height: 48.w),
    Image.asset('assets/images/ic_wallet_gat_gas.png', width: 48.w, height: 48.w),
    Image.asset('assets/images/ic_wallet_transfer_record.png', width: 48.w, height: 48.w),
  ];
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  final List<List<Token>> tokenLists = [
    [
      Token(name: 'USDT', apy: '3.07%', price: '¥7.25', change: '0.00%'),
      Token(name: 'USDC', apy: '3.07%', price: '¥7.25', change: '0.00%'),
      Token(name: 'Q', price: '¥0.00', change: '0.00%'),
    ],
    [
      // NFT 分类的代币数据
      Token(name: 'NFT1', price: '¥10.00', change: '+5.00%'),
    ],
    [
      // 银行卡分类的代币数据
      Token(name: 'VISA', price: '¥100.00', change: '0.00%'),
    ],
  ];

  int _selectedNetWorkIndex = 0; // 存储选中的索引

  int _selectedWalletIndex = 0;

  Wallet _wallet = Wallet.empty();

  static const double _borderRadius = 20;
  static const double _borderWidth = 1.0;

  final defaultNetwork = {"id": "Solana", "path": "assets/images/solana_logo.png"};
  late Map<String, String> _currentNetwork = {};
  late List<Tokens> _tokenList = [];
  late List<Tokens> _fillteredTokensList = [];
  Timer? _timer;
  bool? _hasMnemonic;

  double _parseNum(String s) {
    // 兼容 "1,234.56" 这类字符串；空值返回 0
    final t = (s).replaceAll(',', '').trim();
    return double.tryParse(t) ?? 0.0;
  }

  double _tokenSubtotal(Tokens t) => _parseNum(t.price) * _parseNum(t.number);

  double _portfolioTotal(List<Tokens> list) => list.fold(0.0, (sum, t) => sum + _tokenSubtotal(t));

  String _fmt2(num v) => v.toStringAsFixed(2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _searchController.addListener(_filterItems);
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
    debugPrint('新存的助记词${_wallet.mnemonic}');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    _timer?.cancel();
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
      await _getCurrentSelectWalletfn();
      await _updataWalletBalance();
      await _initWalletAndNetwork();
      await _loadingTokens();
      unawaited(_refreshTokenPrice());
      unawaited(_refreshTokenAmounts());
    } catch (e, st) {
      debugPrint('init error: $e\n$st');
    }
  }

  Future<void> _loadingTokens() async {
    final rawList = await HiveStorage().getList<Map>('tokens', boxName: boxTokens) ?? <Map>[];
    _tokenList = rawList.map((e) => Tokens.fromJson(Map<String, dynamic>.from(e))).toList();
    _fillteredTokensList = List.from(_tokenList);
    final existsSolana = _tokenList.any((token) => token.title.toUpperCase() == 'SOL' || token.title.toUpperCase() == 'SOLANA');
    if (!existsSolana) {
      final solanaToken = Tokens(
        image: 'assets/images/solana_logo.png',
        title: 'SOL',
        subtitle: 'Solana',
        price: '0.000',
        number: '0.000',
        toadd: true,
        tokenAddress: '',
      );
      _tokenList.add(solanaToken);
      _fillteredTokensList = List.from(_tokenList);

      final list = _tokenList.map((t) => t.toJson()).toList();
      await HiveStorage().putList<Map>('tokens', list, boxName: boxTokens);
    }
    setState(() {});
  }

  Future<void> _refreshTokenPrice() async {
    // 收集地址（统一小写、去重；SOL 无地址先略过）
    final addresses = _tokenList.map((t) => t.tokenAddress.trim().toLowerCase()).where((s) => s.isNotEmpty).toSet().toList();
    if (addresses.isEmpty) return;

    try {
      // 一次请求拿所有价格
      final list = await WalletApi.listWalletTokenDataFetch(addresses);

      // 建映射：address -> unitPrice
      final priceMap = <String, String>{for (final p in list) p.address.trim().toLowerCase(): p.unitPrice};

      // 合并回内存列表（没有 copyWith 就 new 一个）
      for (var i = 0; i < _tokenList.length; i++) {
        final t = _tokenList[i];
        final addr = t.tokenAddress.trim().toLowerCase();
        if (addr.isEmpty) continue; // 先不处理 SOL

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
    } catch (e, st) {
      debugPrint('refresh prices failed: $e\n$st');
    }
  }

  String toFixedTrunc(String s, {int digits = 2}) {
    if (!s.contains('.')) return '$s.${'0' * digits}';
    final parts = s.split('.');
    final frac = parts[1];
    final cut = frac.length >= digits ? frac.substring(0, digits) : frac.padRight(digits, '0');
    return '${parts[0]}.$cut';
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

        // 没有 copyWith 就 new 一个
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

      results[m] = amt; // m 已经是 lower-case
    }
    return results;
  }

  void _onSearchChange(String value) {
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
      debugPrint("读取钱包地址: ${wallet.address}");
      setState(() => _wallet = wallet);
      await _updataWalletBalance();
    } else {
      debugPrint("未找到钱包，使用默认 Wallet.empty()");
      _wallet = Wallet.empty();
    }

    if (network != null) {
      _currentNetwork = Map<String, String>.from(network);
    } else {
      _currentNetwork = Map<String, String>.from(defaultNetwork);
      await HiveStorage().putObject('currentNetwork', _currentNetwork);
    }

    debugPrint("当前网络: ${_currentNetwork['id']}");
    debugPrint("助记词: ${_wallet.mnemonic}");
  }

  Future<void> _loadWalletData() async {
    try {
      final wallet = await HiveStorage().getObject<Wallet>('currentSelectWallet', boxName: boxWallet);
      if (wallet != null) {
        debugPrint("刷新钱包数据: ${wallet.address}");
        setState(() => _wallet = wallet);
        await _updataWalletBalance();
      } else {
        debugPrint("未找到 currentSelectWallet");
      }
    } catch (e) {
      debugPrint("加载钱包数据失败: $e");
    }
  }

  // 获取实时钱包余额
  Future<void> _updataWalletBalance() async {
    final wallet = await HiveStorage().getObject<Wallet>('currentSelectWallet', boxName: boxWallet) ?? Wallet.empty();

    if (wallet.address.isEmpty || wallet.address.startsWith('0x000')) {
      return;
    }

    try {
      var solBalance = await getSolBalance(
        rpcUrl: "https://purple-capable-crater.solana-mainnet.quiknode.pro/63bde1d4d678bfd3b06aced761d21c282568ef32/",
        ownerAddress: wallet.address,
      );

      wallet.balance = solBalance.toString();
      await HiveStorage().putObject('currentSelectWallet', wallet, boxName: boxWallet);

      if (mounted) {
        setState(() => _wallet = wallet);
      }
    } catch (e) {
      if (!mounted) return;
      wallet.balance = "0.00";
      await HiveStorage().putObject('currentSelectWallet', wallet, boxName: boxWallet);
      debugPrint("更新余额失败: $e");
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
              // SizedBox(
              //   width: 100.w,
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Theme.of(context).colorScheme.background,
              //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              //       padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.h),
              //       side: BorderSide(
              //         color: Theme.of(context).colorScheme.onSurface,
              //         width: 1.0, // 边框宽度
              //       ),
              //     ),
              //     onPressed: () async {
              //       final currentSelectNetwork = await showAnimatedFullScreenDialog(context, items);
              //       if (currentSelectNetwork != null) {
              //         await HiveStorage().putObject('currentNetwork', currentSelectNetwork);
              //         setState(() {
              //           _currentNetwork = currentSelectNetwork;
              //           _wallet.network = currentSelectNetwork['id']!;
              //         });
              //       }
              //     },
              //     child:
              //     Row(
              //       children: [
              //         ClipOval(
              //           child: Image.asset(
              //             _currentNetwork['path'] ?? items[_selectedNetWorkIndex]["path"]!,
              //             width: 25.w,
              //             height: 25.w,
              //             fit: BoxFit.cover,
              //           ),
              //         ),
              //         SizedBox(width: 5.w),
              //         Expanded(
              //           child: Text(
              //             languageNetName,
              //             style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
              //             maxLines: 1,
              //             overflow: TextOverflow.ellipsis,
              //             textAlign: TextAlign.center,
              //           ),
              //         ),
              //         SizedBox(width: 8.w),
              //         Image.asset('assets/images/ic_arrows_right.png', width: 12.w, height: 12.w),
              //       ],
              //     ),
              //   ),
              // ),
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
          child: _buildPageContent(titles, categories),
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
    final resultWallet = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SelectWalletDialog(
        onWalletSelected: () {
          _loadWalletData();
        },
      ),
    );

    if (resultWallet == true) {
      _initWalletAndNetwork();
    } else if (resultWallet != null) {
      setState(() {
        _wallet = resultWallet;
      });
      await _updataWalletBalance();
    }
  }

  Widget _buildTopView(List<String> titles) {
    final hasMnemonic = _wallet.mnemonic?.isNotEmpty ?? false;
    final showBackupCTA = !_wallet.isBackUp && hasMnemonic;
    return Container(
      padding: EdgeInsets.only(top: 10.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 10.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _wallet.address.length > 12
                          ? '${_wallet.network}:${_wallet.address.substring(0, 6)}...${_wallet.address.substring(_wallet.address.length - 6)}'
                          : '${_wallet.network}:${_wallet.address}',
                      style: TextStyle(fontSize: 13.sp, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _wallet.address));
                      },
                      child: Icon(Icons.copy_outlined, size: 16, color: Theme.of(context).colorScheme.onBackground),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '¥${_fmt2(_portfolioTotal(_fillteredTokensList))}',
                        style: TextStyle(fontSize: 40.sp, color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                      ),
                    ),
                    showBackupCTA
                        ? SizedBox(
                            child: Material(
                              borderRadius: BorderRadius.circular(_borderRadius.r),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () async {
                                  final result = await Get.to(
                                    BackUpHelperOnePage(title: t.wallet.please_remember, prohibit: false, backupAddress: _wallet.address),
                                    arguments: {"mnemonic": _wallet.mnemonic?.join(" ")},
                                  );
                                  debugPrint('已备份2');
                                  if (result == true) {
                                    await _getCurrentSelectWalletfn();
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.background,
                                    border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: _borderWidth),
                                    borderRadius: BorderRadius.circular(_borderRadius.r),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 15.w),
                                  child: _buildButtonContent(),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
                // SizedBox(height: 10.h),
                // Row(
                //   children: [
                //     Text(
                //       '¥10.00 (0.00%)',
                //       style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                //     ),
                //     Container(
                //       padding: EdgeInsets.symmetric(horizontal: 10.w),
                //       margin: EdgeInsets.symmetric(horizontal: 5),
                //       decoration: BoxDecoration(
                //         color: Theme.of(context).colorScheme.background,
                //         borderRadius: BorderRadius.circular(10.r),
                //         border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 1.h),
                //       ),
                //       child: Center(
                //         child: Row(
                //           children: [
                //             Text(t.common.today, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
            children: List.generate(titles.length, (index) {
              return GestureDetector(
                onTap: () {
                  if (index == 0) {
                    Get.to(SelectTransferCoinTypePage(), transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
                  } else if (index == 1) {
                    Get.to(SelectedPayeePage(), transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
                  } else if (index == 4) {
                    Get.to(TransactionHistory(), transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
                  }
                },
                child: SizedBox(
                  height: 80,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _navIcons[index],
                      SizedBox(height: 5),
                      Text(
                        titles[index],
                        style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onBackground),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 15.h),
          Divider(
            color: Theme.of(context).colorScheme.onSurface,
            height: 1, // 线的高度
            thickness: 1, // 线的粗细
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(titles, List<String> categories) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildTopView(titles)),
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
          child: IndexedStack(index: _tabController.index, children: [_buildHomePage(), _buildDeFiPage(), _buildNFTPage(), _buildBankCardPage()]),
        ),
      ],
    );
  }

  /// 代币筛选
  Widget _filterAddWidget() {
    return Container(
      width: double.infinity,
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.sort, color: Theme.of(context).colorScheme.onBackground),
          SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: t.wallet.token_name,
                hintStyle: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: EdgeInsets.only(right: 14),
                border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(25.r)),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onBackground),
              ),
              onChanged: (e) => _onSearchChange(e),
            ),
          ),
          SizedBox(width: 15),
          Icon(Icons.update_sharp, color: Theme.of(context).colorScheme.onBackground),
          SizedBox(width: 15),
          GestureDetector(
            onTap: () async {
              final added = await Get.to(AddingTokens(), transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
              if (added == true) {
                _loadingTokens();
                unawaited(_refreshTokenPrice());
                unawaited(_refreshTokenAmounts());
              }
            },
            child: Icon(Icons.add_circle_outline_sharp),
          ),
        ],
      ),
    );
  }

  // 代币
  Widget _buildHomePage() {
    if (_fillteredTokensList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            Image.asset('assets/images/no_transaction.png', width: 108, height: 92),
            SizedBox(height: 8),
            Text(t.wallet.no_token_added_yet, style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _filterAddWidget(),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return _buildTokenItem(index);
            },
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(height: 10);
            },
            itemCount: _fillteredTokensList.length,
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.color_2B6D16,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21.5.r)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 11),
              ),
              onPressed: () {},
              child: Text(
                t.common.manageToken,
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // DeFi
  Widget _buildDeFiPage() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '热门理财',
                  style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              Image.asset('assets/images/ic_arrows_right.png', width: 7, height: 12),
            ],
          ),
        ),
        SizedBox(
          height: 115.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return GestureDetector(onTap: () => {}, child: _buildHotCoinItemView());
            },
          ),
        ),
      ],
    );
  }

  // NFT
  Widget _buildNFTPage() {
    return Container(height: 200, padding: EdgeInsets.all(10), child: Text('NFT'));
  }

  // 银行卡
  Widget _buildBankCardPage() {
    return Container(height: 200, padding: EdgeInsets.all(10), child: Text('银行卡'));
  }

  Widget _buildTokenItem(int index) {
    final item = _fillteredTokensList[index];
    final number = double.tryParse(item.number);
    final price = double.tryParse(item.price);
    return GestureDetector(
      onTap: () => {Get.to(CoinDetailPage())},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadiusGeometry.circular(50), child: TokenIcon(item.image, size: 40)),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        // 'USDT',
                        item.title,
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground),
                      ),
                      SizedBox(width: 6),
                    ],
                  ),
                  Text(
                    item.price,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  toFixedTrunc(item.number, digits: 2),
                  style: TextStyle(fontSize: 16.sp, color: Theme.of(context).colorScheme.onBackground),
                ),
                Text(
                  toFixedTrunc((price! * number!).toString(), digits: 2),
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotCoinItemView() {
    return Container(
      height: 115.h,
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8EEEE), width: 1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.asset('assets/images/ic_home_bit_coin.png', width: 35.h, height: 35.h, fit: BoxFit.cover),
              ),
              SizedBox(width: 11.w),
              Text(
                'FARTCION',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 11.h),
          Text(
            '¥1.14',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 2.h),
          Text(
            '-10.22%',
            style: TextStyle(fontSize: 13.sp, color: AppColors.color_F3607B),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNetworkIcon(),
        SizedBox(width: 3.w),
        _buildNetworkText(),
      ],
    );
  }

  Widget _buildNetworkIcon() {
    return ClipOval(
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
        child: Image.asset('assets/images/ic_wallet_reminder.png', width: 14.w, height: 14.w),
      ),
    );
  }

  Widget _buildNetworkText() {
    return SizedBox(
      width: 40.w,
      child: Text(
        t.Mysettings.go_backup,
        style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _handleNetworkSelect(BuildContext context) {
    // 处理网络选择逻辑
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
