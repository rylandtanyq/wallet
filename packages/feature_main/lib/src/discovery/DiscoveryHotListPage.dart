import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/widget/base_page.dart';

/*
 * 发现 赚币中心
 */
class DiscoveryHotListPage extends StatefulWidget {
  const DiscoveryHotListPage({super.key});

  @override
  State<StatefulWidget> createState() => _DiscoveryHotListPageState();
}

class _DiscoveryHotListPageState extends State<DiscoveryHotListPage> with BasePage<DiscoveryHotListPage>, AutomaticKeepAliveClientMixin {
  final EasyRefreshController _refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return EasyRefresh(
      controller: _refreshController,
      header: const ClassicHeader(),
      onRefresh: _onRefresh,
      child: SingleChildScrollView(child: Column(children: [Image.asset('assets/images/bg_hotlist.jpg')])),
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
