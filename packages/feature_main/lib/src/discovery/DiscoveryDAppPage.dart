import 'package:easy_refresh/easy_refresh.dart';
import 'package:feature_main/src/search_page/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'package:shared_ui/widget/base_page.dart';

/*
 * 发现 DApp
 */
class DiscoveryDAppPage extends StatefulWidget {
  const DiscoveryDAppPage({super.key});

  @override
  State<StatefulWidget> createState() => _DiscoveryDAppPageState();
}

class _DiscoveryDAppPageState extends State<DiscoveryDAppPage> with BasePage<DiscoveryDAppPage>, AutomaticKeepAliveClientMixin {
  final EasyRefreshController _refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return EasyRefresh(
      controller: _refreshController,
      header: const ClassicHeader(),
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 14.w),
              child: GestureDetector(
                onTap: () => Get.to(SearchPage(), transition: Transition.rightToLeft, popGesture: true),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(19.r)),
                  padding: EdgeInsets.all(10),
                  height: 37.h,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, color: Theme.of(context).colorScheme.onBackground),
                      SizedBox(width: 8.w),
                      Text('BTC/USDT', style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                    ],
                  ),
                ),
              ),
            ),
            Image.asset('assets/images/dapp.jpg'),
            SizedBox(height: 300),
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
