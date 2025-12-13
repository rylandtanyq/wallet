import 'package:feature_main/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_setting/state/app_provider.dart';
import 'package:shared_ui/widget/base_page.dart';
import 'package:feature_main/src/trade/screen/trade_contract_screen.dart';
import 'package:feature_main/src/trade/screen/trade_golden_dog_radar_screen.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'screen/trade_screen.dart';

class TradePage extends ConsumerStatefulWidget {
  const TradePage({super.key});

  @override
  ConsumerState<TradePage> createState() => _TradePageState();
}

class _TradePageState extends ConsumerState<TradePage> with BasePage<TradePage>, AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
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
            Tab(child: Text(t.trade.transaction)),
            Tab(child: Text(t.trade.jingouRadar)),
            Tab(child: Text(t.trade.contract)),
          ],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [TradeScreen(), TradeGoldenDogRadarScreen(), TradeContractScreen()]),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
