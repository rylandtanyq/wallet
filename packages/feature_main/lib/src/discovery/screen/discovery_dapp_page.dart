import 'package:easy_refresh/easy_refresh.dart';
import 'package:feature_main/i18n/strings.g.dart';
import 'package:feature_main/src/discovery/fragments/discovery_exchange_fragmnets.dart';
import 'package:feature_main/src/discovery/fragments/discovery_gamefi_fragments.dart';
import 'package:feature_main/src/discovery/fragments/discovery_mine_fragments.dart';
import 'package:feature_main/src/discovery/fragments/discovery_nft_fragments.dart';
import 'package:feature_main/src/discovery/fragments/discovery_selected_fragments.dart';
import 'package:feature_main/src/search_page/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_setting/state/app_provider.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'package:shared_ui/widget/base_page.dart';
import 'package:shared_ui/widget/sticky_tabbar_delegate.dart';
import 'package:carousel_slider/carousel_slider.dart';

/*
 * 发现 DApp
 */
class DiscoveryDAppPage extends ConsumerStatefulWidget {
  const DiscoveryDAppPage({super.key});

  @override
  ConsumerState<DiscoveryDAppPage> createState() => _DiscoveryDAppPageState();
}

class _DiscoveryDAppPageState extends ConsumerState<DiscoveryDAppPage>
    with BasePage<DiscoveryDAppPage>, AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final EasyRefreshController _refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ref.watch(localeProvider);

    final images = ["assets/images/banner_one.jpg", "assets/images/banner_two.jpg"];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () => Get.to(SearchPage(), transition: Transition.rightToLeft, popGesture: true),
                child: Container(
                  margin: EdgeInsets.only(top: 12),
                  width: double.infinity,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(19.r)),
                  padding: EdgeInsets.all(10),
                  height: 37.h,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, color: Theme.of(context).colorScheme.onBackground),
                      SizedBox(width: 8.w),
                      Text(
                        t.discovery.dappSearchPlaceholder,
                        style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.only(top: 22),
                width: double.infinity,
                height: 180.h,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: CarouselSlider(
                    items: images.map((e) => Image.asset(e, fit: BoxFit.cover, width: double.infinity)).toList(),
                    options: CarouselOptions(
                      height: 180.h,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 44, bottom: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Image.asset("assets/images/earn_coin_center.png", width: 44, height: 44),
                        SizedBox(height: 4),
                        Text(t.discovery.earnCenter),
                      ],
                    ),
                    Column(
                      children: [
                        Image.asset("assets/images/earn_coin_center.png", width: 44, height: 44),
                        SizedBox(height: 4),
                        Text(t.discovery.shopping),
                      ],
                    ),
                    Column(
                      children: [
                        Image.asset("assets/images/water_conservancy_center.png", width: 44, height: 44),
                        SizedBox(height: 4),
                        Text(t.discovery.faucetCenter),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyTabBarDelegate(
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: Theme.of(context).colorScheme.onBackground,
                  // indicatorPadding: EdgeInsets.only(bottom: -6),
                  indicatorSize: TabBarIndicatorSize.label,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                  labelColor: Theme.of(context).colorScheme.onBackground,
                  padding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.only(right: 22.w),
                  labelStyle: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  unselectedLabelStyle: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  dividerColor: Colors.transparent,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  tabs: [
                    Tab(text: t.discovery.featured),
                    Tab(text: t.discovery.myDapps),
                    Tab(text: t.discovery.categoryGameFi),
                    Tab(text: t.discovery.categoryNft),
                    Tab(text: t.discovery.categoryExchange),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            DiscoverySelectedFragments(),
            DiscoveryMineFragments(),
            DiscoveryGamefiFragments(),
            DiscoveryNftFragments(),
            DiscoveryExchangeFragmnets(),
          ],
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
