import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/pages/tabpage/SituationChildPage.dart';
import 'package:untitled1/pages/tabpage/SituationToChancePage.dart';
import 'package:untitled1/pages/tabpage/SituationToTrendPage.dart';
import 'package:untitled1/theme/app_textStyle.dart';

import '../../base/base_page.dart';

/*
 * 行情页面
 */
class SituationPage extends StatefulWidget {
  const SituationPage({super.key});

  @override
  State<StatefulWidget> createState() => _SituationPageState();
}

class _SituationPageState extends State<SituationPage> with BasePage<SituationPage>, AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  final List<Widget> _pages = [SituationChildPage(), SituationToChancePage(), SituationToTrendPage()];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [_buildTabText(0, t.situation.market), _buildTabText(1, t.situation.opportunity), _buildTabText(2, t.situation.trend)],
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
