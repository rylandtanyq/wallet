import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:untitled1/core/AdvancedMultiChainWallet.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/pages/BackUpHelperPage.dart';
import 'package:untitled1/pages/CoinDetailPage.dart';
import 'package:untitled1/pages/SelectedPayeePage.dart';
import 'package:untitled1/pages/SelectTransferCoinTypePage.dart';
import 'package:solana_wallet/solana_package.dart';
import 'package:untitled1/state/app_provider.dart';
import 'package:untitled1/theme/app_textStyle.dart';
import '../../base/base_page.dart';
import '../../constants/AppColors.dart';
import '../../util/HiveStorage.dart';
import '../../entity/Token.dart';
import '../../entity/Wallet.dart';
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

  final List<Widget> _navIcons = [
    Image.asset('assets/images/ic_wallet_transfer.png', width: 48.w, height: 48.w),
    Image.asset('assets/images/ic_home_grid_collection.png', width: 48.w, height: 48.w),
    Image.asset('assets/images/ic_wallet_finance.png', width: 48.w, height: 48.w),
    Image.asset('assets/images/ic_wallet_gat_gas.png', width: 48.w, height: 48.w),
    Image.asset('assets/images/ic_wallet_transfer_record.png', width: 48.w, height: 48.w),
  ];
  late TabController _tabController;
  late PageController _pageController;
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

  late Wallet _wallet;

  static const double _borderRadius = 20;
  static const double _borderWidth = 1.0;

  final defaultNetwork = {"id": "Solana", "path": "assets/images/solana_logo.png"};
  late Map<String, String> _currentNetwork;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pageController = PageController();
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.jumpToPage(_tabController.index);
      }
    });
    _searchController.addListener(_filterItems);
    WidgetsBinding.instance.addObserver(this);
    _wallet = HiveStorage().getObject<Wallet>('currentSelectWallet') ?? Wallet.empty();
    _updataWalletBalance(_wallet);
    final currentNetworkResult = HiveStorage().getObject<Map>("currentNetwork");
    if (currentNetworkResult != null) {
      _currentNetwork = Map<String, String>.from(currentNetworkResult);
    } else {
      _currentNetwork = Map<String, String>.from(defaultNetwork);
      HiveStorage().putObject('currentNetwork', _currentNetwork);
    }
    debugPrint('新存的助记词${_wallet.mnemonic}');
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

  Future<void> _loadWalletData() async {
    if (!mounted) return;

    // setState(() {
    //   _isLoading = true;
    //   _errorMessage = null;
    // });

    try {
      final wallet = await HiveStorage().getObject<Wallet>('currentSelectWallet');

      if (wallet != null) {
        // final updatedWallet = await _updateWalletBalance(wallet);

        if (!mounted) return;

        setState(() {
          _wallet = wallet;
          // _isLoading = false;
        });

        // 更新Hive中的钱包数据
        // await HiveStorage().saveObject('currentSelectWallet', updatedWallet);
      } else {
        if (!mounted) return;
      }
    } catch (e) {
      if (!mounted) return;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _refreshController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 获取实时钱包余额
  Future<void> _updataWalletBalance(Wallet wallet) async {
    try {
      // NetworkType.Devnet  测试用
      // networktype: NetworkType.Mainnet   真实主网余额
      var solBalance = await solana.getbalance(address: wallet.address, networktype: NetworkType.Mainnet);
      debugPrint("Sol balance:- $solBalance");
      debugPrint("new address:- ${wallet.address}");
      wallet.balance = solBalance.toString();
      await HiveStorage().putObject('currentSelectWallet', wallet);
      if (mounted) {
        setState(() {
          _wallet = wallet;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        wallet.balance = "0.00";
      });
      await HiveStorage().putObject('currentSelectWallet', wallet);
      debugPrint("更新余额失败$e");
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
    final id = HiveStorage().getObject<Map>('currentNetwork')?['id'] ?? 'allNetworks';
    final languageNetName = _getCommonName(id);
    final List<String> titles = [t.home.transfer, t.home.receive, t.home.finance, t.home.getGas, t.home.transaction_history];
    final List<Map<String, String>> items = [
      {"id": "allNetworks", "path": "assets/images/all_network.png", "netName": t.common.allNetworks},
      {"id": "Solana", "path": "assets/images/solana_logo.png", "netName": t.common.Solana},
      {"id": "BNB", "path": "assets/images/BTC.png", "netName": t.common.BNB},
      {"id": "Bitcoin", "path": "assets/images/BTC.png", "netName": t.common.Bitcoin},
      {"id": "Base", "path": "assets/images/BTC.png", "netName": t.common.Base},
      {"id": "Ethereum", "path": "assets/images/BTC.png", "netName": t.common.Ethereum},
      {"id": "Polygon", "path": "assets/images/BTC.png", "netName": t.common.Polygon},
      {"id": "Arbitrum", "path": "assets/images/BTC.png", "netName": t.common.Arbitrum},
      {"id": "Sui", "path": "assets/images/BTC.png", "netName": t.common.Sui},
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
              SizedBox(
                width: 120.w,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                    padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.h),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 1.0, // 边框宽度
                    ),
                  ),
                  onPressed: () async {
                    final currentSelectNetwork = await showAnimatedFullScreenDialog(context, items);
                    if (currentSelectNetwork != null) {
                      HiveStorage().putObject('currentNetwork', currentSelectNetwork);
                    }
                  },
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          HiveStorage().getObject<Map>('currentNetwork')?['image'] ?? items[_selectedNetWorkIndex]["path"],
                          width: 25.w,
                          height: 25.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Text(
                          languageNetName,
                          style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Image.asset('assets/images/ic_arrows_right.png', width: 12.w, height: 12.w),
                    ],
                  ),
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
        child: _buildPageContent(titles, categories),
      ),
    );
  }

  //选择网络弹窗
  Future<Map<String, String>?> showAnimatedFullScreenDialog(BuildContext context, List<Map<String, String>> items) {
    _currentNetwork = Map<String, String>.from(HiveStorage().getObject<Map>("currentNetwork") ?? defaultNetwork);
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
                          Navigator.pop(context, {"id": "${itemCurrent['id']}", "image": "${itemCurrent['path']}"});
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

  void showSelectWalletDialog() async {
    final resultWallet = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SelectWalletDialog(
        onWalletSelected: () {
          _loadWalletData();
        },
      ),
    );

    if (resultWallet != null) {
      // 将选择的钱包返回给hive
      setState(() {
        _wallet = resultWallet;
      });

      await _updataWalletBalance(resultWallet);
    }
  }

  Widget _buildTopView(List<String> titles) {
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
                Text(
                  _wallet.address.length > 12
                      ? '${_wallet.network}:${_wallet.address.substring(0, 6)}...${_wallet.address.substring(_wallet.address.length - 6)}'
                      : '${_wallet.network}:${_wallet.address}',
                  style: TextStyle(fontSize: 13.sp, color: Theme.of(context).colorScheme.onSurface),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '¥${_wallet.balance}',
                        style: TextStyle(fontSize: 40.sp, color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      child: Material(
                        borderRadius: BorderRadius.circular(_borderRadius.r),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => {Get.to(BackUpHelperPage())},
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
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Text(
                      '¥10.00 (0.00%)',
                      style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 1.h),
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            Text(t.common.today, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
        SliverFillRemaining(
          child: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _tabController.animateTo(index)),
            children: [_buildHomePage(), _buildDeFiPage(), _buildNFTPage(), _buildBankCardPage()],
          ),
        ),
      ],
    );
  }

  // 代币
  Widget _buildHomePage() {
    return CustomScrollView(
      physics: NeverScrollableScrollPhysics(),
      slivers: [
        // SliverList(
        //   delegate: SliverChildBuilderDelegate(
        //         (_, index) => _buildTokenItem(index),
        //     childCount: 6,
        //   ),
        // ),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(children: List.generate(6, (index) => _buildTokenItem(index))),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.color_2B6D16, // 背景色 #286713
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(21.5.r), // 圆角21.5dp
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 11),
                ),
                onPressed: () {
                  // 按钮点击事件
                },
                child: Text(
                  t.common.manageToken,
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // DeFi
  Widget _buildDeFiPage() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
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
    return GestureDetector(
      onTap: () => {Get.to(CoinDetailPage())},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          children: [
            Stack(
              children: [
                ClipOval(
                  child: Image.asset('assets/images/ic_home_bit_coin.png', width: 45.w, height: 45.w),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  width: 10.w,
                  height: 10.w,
                  child: CircleAvatar(
                    radius: 55, // 总半径(图片半径+白边宽度)
                    backgroundColor: Colors.white, // 白边颜色
                    child: CircleAvatar(
                      radius: 50, // 图片半径
                      backgroundImage: AssetImage('assets/images/ic_home_bit_coin.png'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'USDT',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground),
                      ),
                      if (index < 3)
                        Container(
                          decoration: BoxDecoration(color: AppColors.color_B5DE5B, borderRadius: BorderRadius.circular(19.r)),
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          height: 17.h,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/images/ic_home_search.png', width: 10.w, height: 8.w),
                              SizedBox(width: 3.w),
                              Text(
                                '${index + 1}.98%APY',
                                style: TextStyle(fontSize: 11.sp, color: AppColors.color_286713),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '¥69$index,603.5',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '-0.${index}5%',
                        style: TextStyle(fontSize: 14.sp, color: AppColors.color_F3607B, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  '9.${index}0',
                  style: TextStyle(fontSize: 16.sp, color: Colors.black),
                ),
                Text(
                  '¥${index + 1}.00',
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
