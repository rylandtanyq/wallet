import 'package:easy_refresh/easy_refresh.dart';
import 'package:feature_main/i18n/strings.g.dart';
import 'package:feature_main/src/situation/fragments/FiltrateView.dart';
import 'package:feature_main/src/situation/fragments/HorizntalSelectList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/widget/base_page.dart';
import 'package:shared_utils/constants/app_colors.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'package:shared_ui/widget/sliver_header_delegate.dart';

/*
 * 行情子页面
 */
class SituationChildPage extends StatefulWidget {
  const SituationChildPage({super.key});

  @override
  State<StatefulWidget> createState() => _SituationChildPageState();
}

class _SituationChildPageState extends State<SituationChildPage> with BasePage<SituationChildPage>, SingleTickerProviderStateMixin {
  final EasyRefreshController _refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);
  final PageController _indicatorPageController = PageController();
  int _currentIndicatorPage = 0;
  final int _itemsPerPage = 3; // 每页显示的项目数

  // 模拟数据
  final List<Color> _items = List.generate(6, (index) {
    return Colors.primaries[index % Colors.primaries.length];
  });
  late TabController _tabController;
  late PageController _pageController;
  int _chainSubIndex = 0; // 0:全链, 1:合约
  int _collectSubIndex = 0; // 0:收藏, 1:浏览记录
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();

    // Tab切换时同步PageView
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.jumpToPage(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _indicatorPageController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageCount = (_items.length / _itemsPerPage).ceil();
    final List<String> tabs = [t.situation.favorites, t.situation.allChains, t.situation.contract];
    return Scaffold(
      body: SingleChildScrollView(child: Image.asset("assets/images/market.png")),
      // EasyRefresh(
      //   controller: _refreshController,
      //   header: ClassicHeader(),
      //   onRefresh: _onRefresh,
      //   child: CustomScrollView(
      //     slivers: [
      //       SliverToBoxAdapter(
      //         child: SizedBox(
      //           height: 50.h,
      //           child: Row(
      //             children: [
      //               Expanded(
      //                 child: Container(
      //                   margin: EdgeInsets.symmetric(horizontal: 15.h),
      //                   padding: EdgeInsets.all(10.w),
      //                   decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(19.r)),
      //                   height: 37.h,
      //                   child: Row(
      //                     mainAxisSize: MainAxisSize.min,
      //                     children: [
      //                       Icon(Icons.search, color: Theme.of(context).colorScheme.onBackground),
      //                       SizedBox(width: 8.w),
      //                       Text(t.situation.searchCoins, style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
      //                     ],
      //                   ),
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
      //       SliverToBoxAdapter(
      //         child: Column(
      //           children: [
      //             // 固定高度的PageView+GridView
      //             SizedBox(
      //               height: 100.h, // 正方形高度(根据宽度)
      //               child: PageView.builder(
      //                 controller: _indicatorPageController,
      //                 onPageChanged: (index) {
      //                   setState(() {
      //                     _currentIndicatorPage = index;
      //                   });
      //                 },
      //                 itemCount: pageCount,
      //                 itemBuilder: (context, pageIndex) {
      //                   return GridView.builder(
      //                     physics: const NeverScrollableScrollPhysics(), // 禁止GridView自身滚动
      //                     padding: const EdgeInsets.all(16),
      //                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //                       crossAxisCount: 3, // 每行4个项目
      //                       crossAxisSpacing: 10,
      //                       mainAxisSpacing: 10,
      //                       childAspectRatio: 1.0,
      //                     ),
      //                     itemCount: _itemsPerPage,
      //                     itemBuilder: (context, index) {
      //                       final itemIndex = pageIndex * _itemsPerPage + index;
      //                       if (itemIndex >= _items.length) return Container();
      //                       return _buildTopCoinItemView();
      //                     },
      //                   );
      //                 },
      //               ),
      //             ),
      //             // 分页指示器
      //             Padding(
      //               padding: const EdgeInsets.only(bottom: 20, top: 10),
      //               child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.center,
      //                 children: List.generate(pageCount, (index) {
      //                   return GestureDetector(
      //                     onTap: () {
      //                       _indicatorPageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      //                     },
      //                     child: AnimatedContainer(
      //                       duration: const Duration(milliseconds: 300),
      //                       width: _currentIndicatorPage == index ? 24 : 12, // 当前页线条更长
      //                       height: 4,
      //                       margin: const EdgeInsets.symmetric(horizontal: 2),
      //                       decoration: BoxDecoration(
      //                         borderRadius: BorderRadius.circular(2),
      //                         color: _currentIndicatorPage == index
      //                             ? Colors
      //                                   .black // 当前页颜色
      //                             : Colors.grey.withOpacity(0.3), // 其他页颜色
      //                       ),
      //                     ),
      //                   );
      //                 }),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       SliverPersistentHeader(
      //         pinned: true,
      //         delegate: SliverHeaderDelegate(
      //           maxHeight: 60,
      //           minHeight: 60,
      //           rebuildKey: _selectedIndex,
      //           child: Stack(
      //             children: [
      //               Container(
      //                 margin: EdgeInsets.only(top: 32.5.h), // 行高+间距，确保横线和指示器在同一行
      //                 height: 0.5,
      //                 width: double.infinity,
      //                 color: Color(0xFFEEEEEE),
      //               ),
      //               Row(
      //                 mainAxisSize: MainAxisSize.max,
      //                 mainAxisAlignment: MainAxisAlignment.start,
      //                 children: List.generate(tabs.length, (index) {
      //                   return GestureDetector(
      //                     onTap: () {
      //                       setState(() {
      //                         _selectedIndex = index;
      //                       });
      //                       _pageController.animateToPage(index, duration: Duration(milliseconds: 250), curve: Curves.ease);
      //                     },
      //                     child: Container(
      //                       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      //                       child: Column(
      //                         mainAxisSize: MainAxisSize.min,
      //                         crossAxisAlignment: CrossAxisAlignment.center,
      //                         children: [
      //                           Align(
      //                             alignment: Alignment.centerLeft,
      //                             child: Builder(
      //                               builder: (context) {
      //                                 final isSelected = _selectedIndex == index;
      //                                 return Text(
      //                                   tabs[index],
      //                                   style: AppTextStyles.size15.copyWith(
      //                                     color: isSelected ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.onSurface,
      //                                     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      //                                   ),
      //                                 );
      //                               },
      //                             ),
      //                           ),
      //                           SizedBox(height: 6.h),
      //                           AnimatedContainer(
      //                             duration: Duration(milliseconds: 200),
      //                             height: 2.5.h,
      //                             width: 33.w,
      //                             decoration: BoxDecoration(
      //                               color: _selectedIndex == index ? Theme.of(context).colorScheme.onBackground : Colors.transparent,
      //                               borderRadius: BorderRadius.circular(1.5.h),
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                     ),
      //                   );
      //                 }),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),

      //       SliverFillRemaining(
      //         child: PageView(
      //           controller: _pageController,
      //           physics: const NeverScrollableScrollPhysics(),
      //           onPageChanged: (index) {
      //             setState(() {
      //               _selectedIndex = index;
      //             });
      //           },
      //           children: [_buildOptionalPage(), _buildShopPage(), _buildProfilePage()],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  Widget _buildOptionalPage() {
    return Column(
      children: [
        // 子页面切换按钮
        Row(
          children: [
            SizedBox(width: 10.w),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _chainSubIndex == 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                side: BorderSide(
                  color: _chainSubIndex == 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface, // 边框颜色
                  width: 1.0, // 边框宽度
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.5.r), // 圆角21.5dp
                ),
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 4.h),
              ),
              onPressed: () => setState(() => _chainSubIndex = 0),
              child: Text(
                t.situation.allChains,
                style: TextStyle(
                  color: _chainSubIndex == 0 ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                  fontSize: 13.sp,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _chainSubIndex == 1 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                side: BorderSide(
                  color: _chainSubIndex == 1 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface, // 边框颜色
                  width: 1.0, // 边框宽度
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.5.r), // 圆角21.5dp
                ),
              ),
              onPressed: () => setState(() => _chainSubIndex = 1),
              child: Text(
                t.situation.contract,
                style: TextStyle(
                  color: _chainSubIndex == 1 ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
        // 子页面内容
        Expanded(
          child: IndexedStack(
            index: _chainSubIndex,
            children: [
              _buildAllLinkPage(), // 全链
              _buildContractPage(), // 合约
            ],
          ),
        ),
      ],
    );
  }

  // 自选 - 全链
  Widget _buildAllLinkPage() {
    return Column(
      children: [
        // 子页面切换按钮
        Row(
          children: [
            SizedBox(width: 10.w),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _collectSubIndex == 0
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.surface.withOpacity(.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11.5.r), // 圆角21.5dp
                ),
              ),
              onPressed: () => setState(() => _collectSubIndex = 0),
              child: Text(
                t.situation.myFavorites,
                style: TextStyle(
                  color: _collectSubIndex == 0 ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.onSurface,
                  fontSize: 11.sp,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _collectSubIndex == 1
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.surface.withOpacity(.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11.5.r), // 圆角21.5dp
                ),
                padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 4.h),
              ),
              onPressed: () => setState(() => _collectSubIndex = 1),
              child: Text(
                t.situation.history,
                style: TextStyle(
                  color: _collectSubIndex == 1 ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.onSurface,
                  fontSize: 11.sp,
                ),
              ),
            ),
          ],
        ),
        // 子页面内容
        Expanded(
          child: IndexedStack(
            index: _collectSubIndex,
            children: [
              _buildCollectionPage(), // 收藏页面
              _buildHistoryPage(), // 浏览记录页面
            ],
          ),
        ),
      ],
    );
  }

  // 自选 - 合约
  Widget _buildContractPage() {
    return CustomScrollView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      slivers: [
        // FiltrateView 只在合约页面显示
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverHeaderDelegate(
            maxHeight: 40,
            minHeight: 40,
            child: FiltrateView(
              onSortNameChanged: (value) {},
              onSortVolumeChanged: (value) {},
              onSortPriceChanged: (value) {},
              onSortLimitsChanged: (value) {},
            ),
          ),
        ),
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 80,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, index) => Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Image.asset('assets/images/ic_home_bit_coin.png', width: 35, height: 35),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('BTC')),
                  Image.asset('assets/images/ic_arrows_right.png', width: 13, height: 8),
                ],
              ),
            ),
            childCount: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionPage() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // 禁用独立滚动
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 80, mainAxisSpacing: 10, crossAxisSpacing: 10),
      itemCount: 6,
      itemBuilder: (_, index) => Container(
        height: 80,
        padding: EdgeInsets.all(10.w),
        child: Row(
          children: [
            Image.asset('assets/images/ic_home_bit_coin.png', width: 35.w, height: 35.w),
            SizedBox(width: 10.w),
            Expanded(
              child: Text('BTC', style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground)),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).colorScheme.onBackground, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryPage() {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverHeaderDelegate(
            maxHeight: 40,
            minHeight: 40,
            child: FiltrateView(
              onSortNameChanged: (value) {},
              onSortVolumeChanged: (value) {},
              onSortPriceChanged: (value) {},
              onSortLimitsChanged: (value) {},
            ),
          ),
        ),
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 80,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, index) => Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Image.asset('assets/images/ic_home_bit_coin.png', width: 35, height: 35),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('BTC', style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).colorScheme.onBackground, size: 16),
                ],
              ),
            ),
            childCount: 6,
          ),
        ),
      ],
    );
  }

  // 全链
  Widget _buildShopPage() {
    return CustomScrollView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: HorizontalSelectList(
            items: List.generate(10, (index) => '榜单 ${index + 1}'),
            onSelected: (index) {
              print('选中: $index');
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverList(delegate: SliverChildBuilderDelegate((_, index) => _buildTokenItem(index), childCount: 6)),
        ),
      ],
    );
  }

  Widget _buildTokenItem(int index) {
    return GestureDetector(
      onTap: () => {},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          children: [
            Stack(
              children: [
                ClipOval(
                  child: Image.asset('assets/images/ic_home_bit_coin.png', width: 45.w, height: 45.w),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  width: 10.w,
                  height: 10.w,
                  child: CircleAvatar(
                    radius: 55, // 总半径(图片半径+白边宽度)
                    backgroundColor: Colors.white, // 白边颜色
                    child: CircleAvatar(
                      radius: 50, // 图片半径
                      backgroundImage: AssetImage('assets/images/ic_home_bit_coin.png'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'USDT',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      if (index < 3)
                        Container(
                          decoration: BoxDecoration(color: AppColors.color_B5DE5B, borderRadius: BorderRadius.circular(19.r)),
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          height: 17.h,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/images/ic_home_search.png', width: 10.w, height: 8.w),
                              SizedBox(width: 3.w),
                              Text(
                                '${index + 1}.98%APY',
                                style: TextStyle(fontSize: 11.sp, color: Theme.of(context).colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '¥69$index,603.5',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '-0.${index}5%',
                        style: TextStyle(fontSize: 14.sp, color: AppColors.color_F3607B, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  '9.${index}0',
                  style: TextStyle(fontSize: 16.sp, color: Colors.black),
                ),
                Text(
                  '¥${index + 1}.00',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 合约 - 完全不同的布局
  Widget _buildProfilePage() {
    return CustomScrollView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverHeaderDelegate(
            maxHeight: 40,
            minHeight: 40,
            child: FiltrateView(
              onSortNameChanged: (SortType value) {},
              onSortVolumeChanged: (SortType value) {},
              onSortPriceChanged: (SortType value) {},
              onSortLimitsChanged: (SortType value) {},
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverList(delegate: SliverChildBuilderDelegate((_, index) => _buildTokenItem(index), childCount: 6)),
        ),
      ],
    );
  }

  Widget _buildTopCoinItemView() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(7.5.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('BTC', style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground)),
              ),
              Image.asset('assets/images/ic_home_bit_coin.png', width: 18.w, height: 18.w),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            '\$97,890.90',
            style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 3.h),
          Text(
            '+0.32%',
            style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
          ),
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
