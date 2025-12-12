import 'package:feature_main/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_setting/state/app_provider.dart';
import 'package:shared_ui/widget/base_page.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'screen/discovery_dapp_page.dart';
import 'screen/discovery_hot_list_page.dart';
import 'screen/discovery_making_coin_center_page.dart';

/*
 *  tab-  发现 主页面
 */
class DiscoveryPage extends ConsumerStatefulWidget {
  const DiscoveryPage({super.key});

  @override
  ConsumerState<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends ConsumerState<DiscoveryPage> with BasePage<DiscoveryPage>, AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<Widget> _pages = [DiscoveryDAppPage(), DiscoveryMakingCoinCenterPage(), DiscoveryHotListPage()];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Theme.of(context).colorScheme.onBackground,
          indicatorSize: TabBarIndicatorSize.label,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
          labelColor: Theme.of(context).colorScheme.onBackground,
          padding: EdgeInsets.zero,
          labelPadding: EdgeInsets.only(right: 22.w),
          labelStyle: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.w600),
          dividerColor: Colors.transparent,
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          tabs: [
            Tab(child: Text("Dapp")),
            Tab(child: Text(t.discovery.earnCenter)),
            Tab(child: Text(t.discovery.hotList)),
          ],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [DiscoveryDAppPage(), DiscoveryMakingCoinCenterPage(), DiscoveryHotListPage()]),
    );
  }

  Widget _buildTabText(int index, String text) {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: EdgeInsets.only(right: 30.w),
        padding: EdgeInsets.all(5.w),
        child: Text(
          text,
          style: AppTextStyles.headline4.copyWith(
            color: _selectedIndex == index ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
