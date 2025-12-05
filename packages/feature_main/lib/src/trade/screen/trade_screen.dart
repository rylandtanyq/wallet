import 'package:easy_refresh/easy_refresh.dart';
import 'package:feature_main/i18n/strings.g.dart';
import 'package:feature_main/src/trade/fragments/trade_limit_order_fragments.dart';
import 'package:feature_main/src/trade/fragments/trade_quick_exchange_fragments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:shared_ui/widget/base_page.dart';

/*
 * 交易子页面
 */
class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _TradeChildPageState();
}

class _TradeChildPageState extends State<TradeScreen> with BasePage<TradeScreen>, AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final EasyRefreshController _refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return EasyRefresh(
      controller: _refreshController,
      header: const ClassicHeader(),
      onRefresh: _onRefresh,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 44.h,
              margin: EdgeInsets.only(top: 4.h),
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(50.r)),
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                tabAlignment: TabAlignment.fill,
                indicator: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: BorderRadius.circular(50.r)),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.zero,
                labelColor: Theme.of(context).colorScheme.onBackground,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                labelStyle: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                unselectedLabelStyle: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                tabs: [
                  Tab(text: t.trade.quickSwap),
                  Tab(text: t.trade.limitOrder),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [TradeQuickExchangeFragments(), TradeLimitOrderFragments()],
              ),
            ),
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
