import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/widget/base_page.dart';

/*
 * 行情子页面 --趋势
 */
class SituationToTrendPage extends StatefulWidget {
  const SituationToTrendPage({super.key});

  @override
  State<StatefulWidget> createState() => _SituationToTrendPageState();
}

class _SituationToTrendPageState extends State<SituationToTrendPage> with BasePage<SituationToTrendPage>, AutomaticKeepAliveClientMixin {
  final EasyRefreshController _refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return EasyRefresh(
      controller: _refreshController,
      header: const ClassicHeader(),
      onRefresh: _onRefresh,
      child: SingleChildScrollView(child: Column(children: [Image.asset('assets/images/bg_hangqingqushi.jpg')])),
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
