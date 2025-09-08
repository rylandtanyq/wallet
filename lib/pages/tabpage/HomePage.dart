import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/pages/LinkedWalletDApp.dart';
import 'package:untitled1/pages/MySettings.dart';
import 'package:untitled1/pages/NotificationPage.dart';

import '../../base/base_page.dart';
import '../../entity/FinancialItem.dart';
import '../../widget/VerticalMarquee.dart';
import '../SelectedPayeePage.dart';
import '../view/ContractTradingCard.dart';
import '../view/FinancialDataView.dart';
import '../view/HorizntalSelectList.dart';
import '../view/StatefulProductCard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with BasePage<HomePage>, AutomaticKeepAliveClientMixin {
  final List<String> _titles = ["赚币", "合约", "收款", "金狗雷达", "更多"];
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.to(Mysettings(), transition: Transition.leftToRight, popGesture: true),
                child: Image.asset('assets/images/ic_home_function.png', width: 16.w, height: 16.w),
              ),
              SizedBox(width: 22.w),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(19.r)),
                  padding: EdgeInsets.all(10),
                  height: 37.h,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/ic_home_search.png', width: 16.w, height: 16.w),
                      SizedBox(width: 8.w),
                      Text(
                        'BTC/USDT',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 22.w),
              GestureDetector(
                onTap: () {
                  Get.to(
                    Linkedwalletdapp(), // 要跳转的页面
                    transition: Transition.rightToLeft, // 设置从右到左的动画
                    // duration: const Duration(milliseconds: 300), // 可选：设置动画持续时间
                  );
                },
                child: Image.asset('assets/images/ic_home_link.png', width: 16.w, height: 16.w),
              ),
              SizedBox(width: 22.w),
              Image.asset('assets/images/ic_home_scan.png', width: 16.w, height: 16.w),
              SizedBox(width: 22.w),
              GestureDetector(
                onTap: () {
                  Get.to(
                    NotificationPage(), // 要跳转的页面
                    transition: Transition.rightToLeft, // 设置从右到左的动画
                    // duration: const Duration(milliseconds: 300), // 可选：设置动画持续时间
                  );
                },
                child: Image.asset('assets/images/ic_home_message.png', width: 16.w, height: 16.w),
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
                          '我的钱包',
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8.w),
                        Image.asset('assets/images/ic_arrows_down.png', width: 10.w, height: 6.w),
                      ],
                    ),
                  ),
                  Text(
                    '¥35.00',
                    style: TextStyle(fontSize: 35.sp, fontWeight: FontWeight.bold),
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
                    child: Text('去充值', style: TextStyle(fontSize: 17.sp)),
                  ),
                  SizedBox(height: 35.h),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8, // 调整宽高比例
                    children: List.generate(_titles.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          if (index == 2) {
                            Get.to(
                              SelectedPayeePage(), // 要跳转的页面
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
                                _titles[index],
                                style: TextStyle(fontSize: 12.sp, color: Colors.black),
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
                        child: Text(
                          '备份钱包, 确保资产安全',
                          style: TextStyle(color: Colors.black, fontSize: 17.sp, fontWeight: FontWeight.bold),
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
                                '立即备份',
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
                            '赚币中心',
                            style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                        Text(
                          '共3个活动',
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                        ),
                        SizedBox(width: 5.w),
                        Image.asset('assets/images/ic_arrows_right.png', width: 7, height: 12),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE8EEEE), width: 0.5),
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
                          '全链榜单',
                          style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold, color: Colors.black),
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
                          '热搜代币',
                          style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold, color: Colors.black),
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
                            '合约交易',
                            style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold, color: Colors.black),
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
                            '使用指南',
                            style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold, color: Colors.black),
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
        border: Border.all(color: const Color(0xFFE8EEEE), width: 1),
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
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 11.h),
          Text(
            '¥1.14',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 2.h),
          Text(
            '-10.22%',
            style: TextStyle(fontSize: 13.sp, color: AppColors.color_F3607B),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItemRow() {
    return Container(
      height: 130.h,
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8EEEE), width: 1),
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
                Text(
                  '创建第一个钱包开始',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2.h),
                Text(
                  '从创建钱包开始加密货币之旅',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                ),
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
