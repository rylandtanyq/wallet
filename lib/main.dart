import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:untitled1/constants/hive_boxes.dart';
import 'package:untitled1/hive/tokens.dart';
import 'package:untitled1/hive/transaction_record.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/pages/AddWalletPage.dart';
import 'package:untitled1/pages/tabpage/DiscoveryPage.dart';
import 'package:untitled1/pages/tabpage/HomePage.dart';
import 'package:untitled1/pages/tabpage/SituationPage.dart';
import 'package:untitled1/pages/tabpage/TradePage.dart';
import 'package:untitled1/pages/tabpage/WalletPage.dart';
import 'package:untitled1/state/app_provider.dart';
import 'package:untitled1/theme/app_theme.dart';
import 'package:untitled1/util/CheckUpgrade.dart';

import 'util/HiveStorage.dart';
import 'hive/Wallet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();

  final hiveStorage = HiveStorage();
  await hiveStorage.init(adapters: [WalletAdapter(), TransactionRecordAdapter(), TokensAdapter()]);
  await HiveStorage().ensureOpen(boxWallet);
  await HiveStorage().ensureOpen(boxTokens);
  await HiveStorage().ensureOpen(boxTx, lazy: true);
  final wallets = await HiveStorage().getList<Wallet>('wallets_data', boxName: boxWallet);
  final bool hasWallets = wallets != null && wallets.isNotEmpty;
  runApp(
    ProviderScope(
      child: TranslationProvider(child: MyApp(hasWallets: hasWallets)),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final bool hasWallets;
  const MyApp({super.key, required this.hasWallets});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    return ScreenUtilInit(
      designSize: Size(375, 667),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          locale: locale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          builder: FToastBuilder(),
          debugShowCheckedModeBanner: false,
          title: 'Wallet App',
          home: hasWallets ? MainPage() : AddWalletPage(),
          initialRoute: '/',
        );
      },
      child: const MainPage(),
    );
  }
}

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key, this.initialPageIndex = 0});

  final int initialPageIndex;

  @override
  ConsumerState<MainPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MainPage> {
  late int _selectedItemIndex;
  late PageController _pageController;

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
    ref.watch(localeProvider);
    final List<String> _titles = [t.tabbar.home, t.tabbar.markets, t.tabbar.trade, t.tabbar.discover, t.tabbar.wallet];

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
        items: _generateBottomNavList(_titles, _navIconsActive),
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

  List<BottomNavigationBarItem> _generateBottomNavList(List<String> titles, List<Widget> navIconsActive) {
    return List.generate(titles.length, (index) {
      return BottomNavigationBarItem(icon: _navIcons[index], activeIcon: navIconsActive[index], label: titles[index]);
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
