import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/widget/base_page.dart';
import 'package:feature_main/src/trade/TradeToContractPage.dart';
import 'package:feature_main/src/trade/TradeToGoldenDogRadarPage.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'TradeChildPage.dart';

class TradePage extends StatefulWidget {
  const TradePage({super.key});

  @override
  State<StatefulWidget> createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> with BasePage<TradePage>, AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  final List<Widget> _pages = [TradeChildPage(), TradeToGoldenDogRadarPage(), TradeToContractPage()];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [_buildTabText(0, '交易'), _buildTabText(1, '金狗雷达'), _buildTabText(2, '合约')]),
      ),
      body: _pages[_selectedIndex],
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
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
