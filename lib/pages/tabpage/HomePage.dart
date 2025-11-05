import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/constants/hive_boxes.dart';
import 'package:untitled1/hive/tokens.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/pages/LinkedWalletDApp.dart';
import 'package:untitled1/pages/MoreServices.dart';
import 'package:untitled1/pages/MySettings.dart';
import 'package:untitled1/pages/NotificationPage.dart';
import 'package:untitled1/pages/SelectTransferCoinTypePage.dart';
import 'package:untitled1/pages/search_page/index.dart';
import 'package:untitled1/state/app_provider.dart';
import 'package:untitled1/theme/app_textStyle.dart';
import 'package:untitled1/util/HiveStorage.dart';

import '../../base/base_page.dart';
import '../../entity/FinancialItem.dart';
import '../SelectedPayeePage.dart';
import '../../widget/ContractTradingCard.dart';
import '../../widget/FinancialDataView.dart';
import '../../widget/HorizntalSelectList.dart';
import '../../widget/StatefulProductCard.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with BasePage<HomePage>, AutomaticKeepAliveClientMixin {
  final List<Widget> _navIcons = [
    Image.asset('assets/images/ic_home_grid_profitable.png', width: 46.w, height: 46.w),
    Image.asset('assets/images/ic_home_grid_contract.png', width: 46.w, height: 46.w),
    Image.asset('assets/images/ic_home_grid_collection.png', width: 46.w, height: 46.w),
    Image.asset('assets/images/ic_home_grid_radar.png', width: 46.w, height: 46.w),
    Image.asset('assets/images/ic_home_grid_more.png', width: 46.w, height: 46.w),
  ];

  final List<FinancialItem> items = [
    FinancialItem(name: 'NOM', amount: '\$982.07万', time: '1天前', price: '\$0.001817', change: '+275.88%', isPositive: true),
    FinancialItem(name: 'MCP', amount: '\$727.17万', time: '1天前', price: '\$0.005556', change: '+73.18%', isPositive: true),
    FinancialItem(name: 'TRENCHER', amount: '\$702.66万', time: '2天前', price: '\$0.004427', change: '+16.08%', isPositive: true),
    FinancialItem(name: 'TAI', amount: '\$558.74万', time: '', price: '\$0.1246', change: '+71.18%', isPositive: true),
    FinancialItem(name: 'CFX', amount: '\$1,140.69万', time: '23小时前', price: '\$0.002972', change: '+55780.77%', isPositive: true),
  ];

  final EasyRefreshController _refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);

  late Future<String> _totalFuture;

  @override
  void initState() {
    super.initState();
    _totalFuture = computeTotalFromHive2dp();
  }

  Future<String> computeTotalFromHive2dp() async {
    final raw = await HiveStorage().getList<Map>('tokens', boxName: boxTokens) ?? const <Map>[];
    final tokens = raw.map((e) => Tokens.fromJson(Map<String, dynamic>.from(e))).toList();
    final sum = tokens.fold<double>(
      0.0,
      (acc, t) => acc + (double.tryParse(t.price.replaceAll(',', '').trim()) ?? 0.0) * (double.tryParse(t.number.replaceAll(',', '').trim()) ?? 0.0),
    );
    return sum.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ref.watch(localeProvider);
    final List<String> titles = [t.home.transfer, t.home.contract, t.home.receive, t.home.golden_dog_radar, t.home.more];

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.to(Mysettings(), transition: Transition.leftToRight, popGesture: true),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
                  child: Image.asset('assets/images/ic_home_function.png', width: 16.w, height: 16.w),
                ),
              ),
              SizedBox(width: 22.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.to(SearchPage(), transition: Transition.rightToLeft, popGesture: true),
                  child: Container(
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
              SizedBox(width: 22.w),
              GestureDetector(
                onTap: () {
                  Get.to(
                    Linkedwalletdapp(), // 要跳转的页面
                    transition: Transition.rightToLeft, // 设置从右到左的动画
                    duration: const Duration(milliseconds: 300), // 可选：设置动画持续时间
                  );
                },
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
                  child: Image.asset('assets/images/ic_home_link.png', width: 16.w, height: 16.w),
                ),
              ),
              SizedBox(width: 22.w),
              ColorFiltered(
                colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
                child: Image.asset('assets/images/ic_home_scan.png', width: 16.w, height: 16.w),
              ),
              SizedBox(width: 22.w),
              GestureDetector(
                onTap: () {
                  Get.to(
                    NotificationPage(), // 要跳转的页面
                    transition: Transition.rightToLeft, // 设置从右到左的动画
                    duration: const Duration(milliseconds: 300), // 可选：设置动画持续时间
                  );
                },
                // child: Image.asset('assets/images/ic_home_message.png', width: 16.w, height: 16.w),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
                  child: Image.asset('assets/images/ic_home_message.png', width: 16.w, height: 16.w),
                ),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: EasyRefresh(
        controller: _refreshController,
        header: const ClassicHeader(),
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 30.h),
            padding: EdgeInsets.only(bottom: 40.h),
            child: Center(
              child: Column(
                children: [
                  ClipOval(
                    child: Image.asset('assets/images/ic_clip_photo.png', width: 60.w, height: 60.w, fit: BoxFit.cover),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () {
                      //弹出钱包Dialog
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.common.my_wallet,
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8.w),
                        // Image.asset('assets/images/ic_arrows_down.png', width: 10.w, height: 6.w),
                        Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.onBackground),
                      ],
                    ),
                  ),
                  FutureBuilder<String>(
                    future: _totalFuture,
                    builder: (_, snap) => Text(
                      '¥${snap.data ?? '0.00'}',
                      style: TextStyle(fontSize: 35.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/ic_home_app_icon.png', width: 20.w, height: 20.w),
                      SizedBox(width: 6.5.w),
                      Image.asset('assets/images/ic_home_app_icon1.png', width: 20.w, height: 20.w),
                      SizedBox(width: 6.5.w),
                      Image.asset('assets/images/ic_home_app_icon2.png', width: 20.w, height: 20.w),
                      SizedBox(width: 6.5.w),
                      Image.asset('assets/images/ic_home_app_icon3.png', width: 20.w, height: 20.w),
                      SizedBox(width: 6.5.w),
                      Icon(
                        Icons.circle,
                        size: 2.5.h,
                        color: Color(0xFF6F7470), // #6F7470 颜色
                      ),
                      SizedBox(width: 6.5.w),
                      Image.asset('assets/images/ic_home_visa.png', width: 49.w, height: 21.h),
                      SizedBox(width: 4.5.w),
                      Image.asset('assets/images/ic_home_master.png', width: 49.w, height: 21.h),
                      SizedBox(width: 4.5.w),
                      Image.asset('assets/images/ic_home_applepay.png', width: 49.w, height: 21.h),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  MaterialButton(
                    onPressed: () {
                      //弹出充值dialog
                    },
                    height: 40.h, // 设置高度
                    minWidth: 175.w,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
                    color: AppColors.color_2B6D16,
                    textColor: Colors.white,
                    child: Text(t.home.recharge, style: TextStyle(fontSize: 17.sp)),
                  ),
                  SizedBox(height: 35.h),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8, // 调整宽高比例
                    children: List.generate(titles.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          if (index == 0) {
                            Get.to(SelectTransferCoinTypePage(), transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
                          } else if (index == 2) {
                            Get.to(
                              SelectedPayeePage(), // 要跳转的页面
                              transition: Transition.rightToLeft, // 设置从右到左的动画
                              duration: const Duration(milliseconds: 300), // 可选：设置动画持续时间
                            );
                          } else if (index == 4) {
                            Get.to(
                              MoreServices(), // 要跳转的页面
                              transition: Transition.rightToLeft, // 设置从右到左的动画
                              duration: const Duration(milliseconds: 300), // 可选：设置动画持续时间
                            );
                          }
                        },
                        child: SizedBox(
                          // 添加固定高度约束
                          height: 80, // 根据需求调整
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // 重要：使Column只占用最小空间
                            children: [
                              _navIcons[index],
                              SizedBox(height: 5),
                              Text(
                                titles[index],
                                style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onBackground),
                                maxLines: 1, // 限制文本行数
                                overflow: TextOverflow.ellipsis, // 超出显示省略号
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 15.h),
                  Stack(
                    children: [
                      // 底层图片
                      Image.asset('assets/images/bg_home_banner.png', width: 350.w, height: 105.h, fit: BoxFit.cover),

                      Positioned(
                        top: 16,
                        left: 15,
                        child: SizedBox(
                          width: 180.w,
                          child: Text(
                            t.home.backup_wallet_tip,
                            style: TextStyle(color: Colors.black, fontSize: 17.sp, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      // 第二个文本（右下角）
                      Positioned(
                        bottom: 16,
                        left: 15,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17.r)),
                          padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                          height: 28.h,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                t.home.backup_now,
                                style: TextStyle(fontSize: 12.sp, color: Colors.black),
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                '>',
                                style: TextStyle(fontSize: 12.sp, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // VerticalMarquee(
                  //   items: ['35%返佣待开启！卓越邀请人项目来袭！', '222222222', '333333333'],
                  //   itemHeight: 40,
                  //   scrollDuration: Duration(seconds: 3),
                  // ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.all(10.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.home.earn_center,
                            style: AppTextStyles.size19.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(t.home.activity_count, style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                        SizedBox(width: 5.w),
                        Image.asset('assets/images/ic_arrows_right.png', width: 7, height: 12),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(.1), width: .5),
                      borderRadius: BorderRadius.circular(8.0), // 设置圆角
                    ),
                    child: StatefulProductCard(),
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Text(
                          t.home.cross_chain_rank,
                          style: AppTextStyles.size19.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  HorizontalSelectList(
                    items: List.generate(10, (index) => '榜单 ${index + 1}'),
                    onSelected: (index) {
                      print('选中: $index');
                    },
                  ),
                  FinancialDataPage(items: items),
                  SizedBox(height: 13.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Text(
                          t.home.trending_tokens,
                          style: AppTextStyles.size19.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 115.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(onTap: () => {}, child: _buildHotCoinItemView());
                      },
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.home.contract_trading,
                            style: AppTextStyles.size19.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Image.asset('assets/images/ic_arrows_right.png', width: 7, height: 12),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ContractTradingCard(),
                  SizedBox(height: 15.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.Mysettings.user_guide,
                            style: AppTextStyles.size19.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Image.asset('assets/images/ic_arrows_right.png', width: 7, height: 12),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 130.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(onTap: () => {}, child: _buildGuideItemRow());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  Widget _buildHotCoinItemView() {
    return Container(
      height: 115.h,
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(.4), width: 1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.asset('assets/images/ic_home_bit_coin.png', width: 35.h, height: 35.h, fit: BoxFit.cover),
              ),
              SizedBox(width: 11.w),
              Text(
                'FARTCION',
                style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 11.h),
          Text('¥1.14', style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          SizedBox(height: 2.h),
          Text('-10.22%', style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onError)),
        ],
      ),
    );
  }

  Widget _buildGuideItemRow() {
    return Container(
      height: 130.h,
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(.4), width: 1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            // 使用 Expanded 让图片占据剩余空间
            child: Image.asset(
              'assets/images/bg_home_banner.png',
              width: 233.w,
              fit: BoxFit.cover, // 确保图片适应
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.home.create_first_wallet, style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                SizedBox(height: 2.h),
                Text(t.home.start_crypto_journey, style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MySearchBar extends StatefulWidget {
  const MySearchBar({super.key, required this.onSubmit});

  final void Function(String) onSubmit;

  @override
  State<StatefulWidget> createState() => _MySearchState();
}

class _MySearchState extends State<MySearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white),
      child: TextField(
        autofocus: true,
        decoration: const InputDecoration(
          hintText: "搜索",
          contentPadding: EdgeInsets.only(bottom: 10),
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
        onSubmitted: (content) {
          widget.onSubmit(content);
        },
      ),
    );
  }
}

Widget _buildItemWithIcon(String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset('assets/images/ic_home_sound.png', width: 12.5.w, height: 11),
      SizedBox(width: 5.w),
      Expanded(
        child: Text(
          text,
          overflow: TextOverflow.ellipsis, // 超出显示...
          maxLines: 1,
          style: TextStyle(fontSize: 12.sp, color: Colors.black),
        ),
      ),
      SizedBox(width: 5.w),
      Image.asset('assets/images/ic_arrows_right.png', width: 7, height: 12),
    ],
  );
}
