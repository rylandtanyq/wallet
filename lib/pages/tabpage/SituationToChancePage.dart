import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../base/base_page.dart';

/*
 * 行情子页面 --机会
 */
class SituationToChancePage extends StatefulWidget {
  const SituationToChancePage({super.key});

  @override
  State<StatefulWidget> createState() => _SituationToChancePageState();
}

class _SituationToChancePageState extends State<SituationToChancePage>
    with BasePage<SituationToChancePage>, AutomaticKeepAliveClientMixin {
  final EasyRefreshController _refreshController = EasyRefreshController(
      controlFinishRefresh: true, controlFinishLoad: true);

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return EasyRefresh(
      controller: _refreshController,
      header: const ClassicHeader(),
      onRefresh: _onRefresh,
      child: Column(
        children: [

        ],
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