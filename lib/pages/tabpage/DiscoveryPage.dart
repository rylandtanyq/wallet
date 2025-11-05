import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/request/request.api.dart';
import 'package:untitled1/state/app_provider.dart';
import 'package:untitled1/theme/app_textStyle.dart';

import '../../base/base_page.dart';
import '../../widget/HorizntalSelectList.dart';
import 'DiscoveryDAppPage.dart';
import 'DiscoveryHotListPage.dart';
import 'DiscoveryMakingCoinCenterPage.dart';

/*
 *  tab-  发现 主页面
 */
class DiscoveryPage extends ConsumerStatefulWidget {
  const DiscoveryPage({super.key});

  @override
  ConsumerState<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends ConsumerState<DiscoveryPage> with BasePage<DiscoveryPage>, AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  final List<Widget> _pages = [DiscoveryDAppPage(), DiscoveryMakingCoinCenterPage(), DiscoveryHotListPage()];
  late final List<String> _addresses = const [
    'jtojtomepa8beP8AuQc6eXt5FriJwfFMwQx2v2f9mCL',
    'DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263',
    'EKpQGSJtjMFqKZ9KQanSqYXRcF8fBopzLHYxdM65zcjm',
  ];

  @override
  void initState() {
    super.initState();
    // request();
    // request2();
    ref.read(getWalletTokensPriceProvide(_addresses).notifier).fetchWalletTokenPriceData(_addresses);
  }

  Future<void> request() async {
    try {
      final asd = await WalletApi.walletTokensDataFetch('Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB');
      debugPrint('00900--- $asd');
    } catch (e) {
      debugPrint('wqe: $e');
    }
  }

  Future<void> request2() async {
    try {
      final asd = await WalletApi.listWalletTokenDataFetch([
        'jtojtomepa8beP8AuQc6eXt5FriJwfFMwQx2v2f9mCL',
        'DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263',
      ]);
      debugPrint("list 头像数据: $asd");
    } catch (e) {
      debugPrint('wqe2: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ret = ref.watch(getWalletTokensPriceProvide(_addresses));
    debugPrint('123qwe: $ret');

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [_buildTabText(0, 'DApp'), _buildTabText(1, '赚币中心'), _buildTabText(2, '热榜')],
        ),
      ),
      body: Column(
        children: [
          // _pages[_selectedIndex],
          ret.when(
            data: (data) {
              debugPrint('000>>??? $data');
              return Text("成功");
            },
            error: (err, e) {
              return Text("错误");
            },
            loading: () {
              return Text("记载");
            },
          ),
        ],
      ),
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
