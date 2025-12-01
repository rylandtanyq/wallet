import 'package:feature_main/i18n/strings.g.dart';
import 'package:feature_main/src/discovery/DiscoveryPage.dart';
import 'package:feature_main/src/home/home_page/index.dart';
import 'package:feature_main/src/situation/SituationPage.dart';
import 'package:feature_main/src/trade/TradePage.dart';
import 'package:feature_wallet/feature_wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_setting/state/app_provider.dart';
import 'package:shared_utils/check_upgrade.dart';

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
    final args = Get.arguments as Map<String, dynamic>?;
    final initIndex = (args?['initialPageIndex'] as int?) ?? 0;

    _selectedItemIndex = initIndex;
    _pageController = PageController(initialPage: initIndex);
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
        offset: Offset(0, 4),
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
