import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/widget/base_page.dart';

/*
 * 交易子页面
 */
class TradeChildPage extends StatefulWidget {
  const TradeChildPage({super.key});

  @override
  State<StatefulWidget> createState() => _TradeChildPageState();
}

class _TradeChildPageState extends State<TradeChildPage> with BasePage<TradeChildPage>, AutomaticKeepAliveClientMixin {
  final EasyRefreshController _refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return EasyRefresh(
      controller: _refreshController,
      header: const ClassicHeader(),
      onRefresh: _onRefresh,
      child: SingleChildScrollView(child: Column(children: [Image.asset('assets/images/bg_jiaoyi.jpg')])),
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
