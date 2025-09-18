import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/theme/app_textStyle.dart';

import '../../base/base_page.dart';
import '../view/HorizntalSelectList.dart';
import 'DiscoveryDAppPage.dart';
import 'DiscoveryHotListPage.dart';
import 'DiscoveryMakingCoinCenterPage.dart';

/*
 *  tab-  发现 主页面
 */
class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<StatefulWidget> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> with BasePage<DiscoveryPage>, AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  final List<Widget> _pages = [DiscoveryDAppPage(), DiscoveryMakingCoinCenterPage(), DiscoveryHotListPage()];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [_buildTabText(0, 'DApp'), _buildTabText(1, '赚币中心'), _buildTabText(2, '热榜')],
        ),
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
