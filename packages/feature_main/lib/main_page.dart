import 'package:feature_main/i18n/strings.g.dart';
import 'package:feature_main/src/discovery/index.dart';
import 'package:feature_main/src/home_page/index.dart';
import 'package:feature_main/src/situation/SituationPage.dart';
import 'package:feature_main/src/trade/index.dart';
import 'package:feature_wallet/feature_wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_setting/state/app_provider.dart';
import 'package:shared_ui/widget/wallet_icon.dart';
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

  bool _inited = false;

  Map<String, dynamic>? _readArgs(BuildContext context) {
    final a = ModalRoute.of(context)?.settings.arguments ?? Get.arguments;
    if (a is Map<String, dynamic>) return a;
    if (a is Map) return Map<String, dynamic>.from(a);
    return null;
  }

  @override
  void initState() {
    super.initState();
    _selectedItemIndex = widget.initialPageIndex;
    _pageController = PageController(initialPage: _selectedItemIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdater.checkUpdate(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;

    final args = _readArgs(context);
    final initIndex = (args?['initialPageIndex'] as int?) ?? widget.initialPageIndex;

    if (initIndex != _selectedItemIndex) {
      _selectedItemIndex = initIndex;

      // 这里用 jumpToPage，比重新 new PageController 改动更小
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pageController.jumpToPage(initIndex);
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _navIcons = [
    ColorFiltered(colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn), child: Icon(WalletIcon.home, size: 24)),
    ColorFiltered(colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn), child: Icon(WalletIcon.market, size: 24)),
    ColorFiltered(colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn), child: Icon(WalletIcon.transaction, size: 30)),
    ColorFiltered(colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn), child: Icon(WalletIcon.discover, size: 24)),
    ColorFiltered(colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn), child: Icon(WalletIcon.wallet, size: 24)),
  ];

  final List<Widget> _pages = [const HomePage(), const SituationPage(), const TradePage(), const DiscoveryPage(), const WalletPage()];

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final List<String> titles = [t.tabbar.home, t.tabbar.markets, t.tabbar.trade, t.tabbar.discover, t.tabbar.wallet];

    final List<Widget> navIconsActive = [
      ColorFiltered(colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn), child: Icon(WalletIcon.home, size: 24)),
      ColorFiltered(colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn), child: Icon(WalletIcon.market, size: 24)),
      ColorFiltered(
        colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn),
        child: Icon(WalletIcon.transaction, size: 30),
      ),
      ColorFiltered(
        colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn),
        child: Icon(WalletIcon.discover, size: 24),
      ),
      ColorFiltered(colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn), child: Icon(WalletIcon.wallet, size: 24)),
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
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface,
        items: _generateBottomNavList(titles, navIconsActive),
        currentIndex: _selectedItemIndex,
        onTap: _onNavItemTapped,
      ),
      // floatingActionButton: Transform.translate(
      //   offset: Offset(0, 4),
      //   child: FloatingActionButton(onPressed: () => _onNavItemTapped(2), elevation: 0, child: Icon(WalletIcon.transaction, size: 47)),
      // ),
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
