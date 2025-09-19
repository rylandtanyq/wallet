import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:untitled1/hive/create_solana_wallet.dart';
import 'package:untitled1/pages/CreateWalletPage.dart';
import 'package:untitled1/pages/SplashPage.dart';
import 'package:untitled1/pages/tabpage/DiscoveryPage.dart';
import 'package:untitled1/pages/tabpage/HomePage.dart';
import 'package:untitled1/pages/tabpage/SituationPage.dart';
import 'package:untitled1/pages/tabpage/TradePage.dart';
import 'package:untitled1/pages/tabpage/WalletPage.dart';
import 'package:untitled1/state/app_riverpod.dart';
import 'package:untitled1/theme/app_theme.dart';
import 'package:untitled1/util/CheckUpgrade.dart';

import 'util/HiveStorage.dart';
import 'entity/Wallet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化Hive并注册适配器
  await HiveStorage().init(adapters: [WalletHiveAdapter()]);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final solana_wallet = CreateSolanaWallet.empty();

    // @override
    // void initState() {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (solana_wallet.address.isEmpty) {
    //       debugPrint("没有创建钱包");
    //       Get.off(Createwalletpage());
    //     } else {
    //       Get.off(HomePage());
    //     }
    //   });
    // }

    return ScreenUtilInit(
      designSize: Size(375, 667),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          builder: FToastBuilder(),
          debugShowCheckedModeBanner: false,
          title: 'Wallet App',
          // theme: ThemeData(
          //   colorScheme: ColorScheme.light(
          //     primary: Colors.white, // 主要颜色
          //     surface: Colors.white, // 表面颜色（如卡片）
          //   ),
          //   scaffoldBackgroundColor: Colors.white, // 页面背景
          //   appBarTheme: AppBarTheme(
          //     backgroundColor: Colors.white, // AppBar背景
          //     elevation: 0, // 去除阴影
          //     iconTheme: IconThemeData(color: Colors.black), // 图标颜色
          //     titleTextStyle: TextStyle(
          //       color: Colors.black, // 标题文字颜色
          //       fontSize: 20,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          // ),
          home: solana_wallet.address.isEmpty ? Createwalletpage() : HomePage(),
          initialRoute: '/',
        );
      },
      child: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.initialPageIndex = 0});

  final int initialPageIndex;

  @override
  State<MainPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MainPage> {
  late int _selectedItemIndex;
  late PageController _pageController;

  final List<String> _titles = ["首页", "行情", "交易", "发现", "钱包"];
  final List<Widget> _navIcons = [
    ColorFiltered(
      colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
      child: Image.asset('assets/images/ic_tab_home.png', width: 24.w, height: 24.w),
    ),
    ColorFiltered(
      colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
      child: Image.asset('assets/images/ic_tab_situation.png', width: 24.w, height: 24.w),
    ),
    ColorFiltered(
      colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
      child: Image.asset('assets/images/ic_tab_trade.png', width: 24.w, height: 24.w),
    ),
    ColorFiltered(
      colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
      child: Image.asset('assets/images/ic_tab_discovery.png', width: 24.w, height: 24.w),
    ),
    ColorFiltered(
      colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
      child: Image.asset('assets/images/ic_tab_wallet.png', width: 24.w, height: 24.w),
    ),
  ];

  final List<Widget> _pages = [const HomePage(), const SituationPage(), const TradePage(), const DiscoveryPage(), const WalletPage()];

  @override
  void initState() {
    super.initState();
    _selectedItemIndex = widget.initialPageIndex;
    _pageController = PageController(initialPage: widget.initialPageIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdater.checkUpdate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _navIconsActive = [
      ColorFiltered(
        colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
        child: Image.asset('assets/images/ic_tab_home.png', width: 24.w, height: 24.w),
      ),
      ColorFiltered(
        colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
        child: Image.asset('assets/images/ic_tab_situation.png', width: 24.w, height: 24.w),
      ),
      ColorFiltered(
        colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
        child: Image.asset('assets/images/ic_tab_trade.png', width: 24.w, height: 24.w),
      ),
      ColorFiltered(
        colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
        child: Image.asset('assets/images/ic_tab_discovery.png', width: 24.w, height: 24.w),
      ),
      ColorFiltered(
        colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
        child: Image.asset('assets/images/ic_tab_wallet.png', width: 24.w, height: 24.w),
      ),
    ];
    return Scaffold(
      body: PageView.builder(
        itemBuilder: (context, index) {
          return _pages[index];
        },
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: _onPageChanged,
        controller: _pageController,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 14.sp,
        unselectedFontSize: 14.sp,
        iconSize: 24.w,
        backgroundColor: Theme.of(context).colorScheme.background,
        selectedItemColor: Theme.of(context).colorScheme.onBackground,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface,
        items: _generateBottomNavList(_navIconsActive),
        currentIndex: _selectedItemIndex,
        onTap: _onNavItemTapped,
      ),
      floatingActionButton: Transform.translate(
        offset: Offset(0, 10),
        child: FloatingActionButton(
          onPressed: () => _onNavItemTapped(2),
          backgroundColor: Colors.white,
          elevation: 0,
          child: Image.asset('assets/images/ic_tab_trade.png', width: 47.w, height: 47.h),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  List<BottomNavigationBarItem> _generateBottomNavList(List<Widget> _navIconsActive) {
    return List.generate(_titles.length, (index) {
      return BottomNavigationBarItem(icon: _navIcons[index], activeIcon: _navIconsActive[index], label: _titles[index]);
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedItemIndex = index;
    });
  }

  void _onNavItemTapped(int index) {
    // _pageController.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.ease);
    _pageController.jumpToPage(index);
  }
}
