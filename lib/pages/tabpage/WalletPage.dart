import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:untitled1/pages/BackUpHelperPage.dart';
import 'package:untitled1/pages/CoinDetailPage.dart';
import 'package:untitled1/pages/SelectedPayeePage.dart';
import 'package:untitled1/pages/SelectTransferCoinTypePage.dart';
import '../../base/base_page.dart';
import '../../constants/AppColors.dart';
import '../../dao/HiveStorage.dart';
import '../../entity/Token.dart';
import '../../entity/Wallet.dart';
import '../dialog/SelectWalletDialog.dart';
import '../dialog/FullScreenDialog.dart';
import '../view/StickyTabBarDelegate.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<StatefulWidget> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage>
    with BasePage<WalletPage>, TickerProviderStateMixin,WidgetsBindingObserver {

  final EasyRefreshController _refreshController = EasyRefreshController(
      controlFinishRefresh: true, controlFinishLoad: true);

  final List<String> _titles = ["转账", "收款", "理财", "GetGas","交易历史"];
  final List<Widget> _navIcons = [
    Image.asset('assets/images/ic_wallet_transfer.png',width: 48.w,height:  48.w,),
    Image.asset('assets/images/ic_home_grid_collection.png',width:  48.w,height:  48.w),
    Image.asset('assets/images/ic_wallet_finance.png',width: 48.w,height: 48.w),
    Image.asset('assets/images/ic_wallet_gat_gas.png',width: 48.w,height: 48.w),
    Image.asset('assets/images/ic_wallet_transfer_record.png',width: 48.w,height: 48.w)
  ];
  late TabController _tabController;
  late PageController _pageController;
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;

  final List<String> categories = ['代币','DeFi', 'NFT', '银行卡'];
  final List<List<Token>> tokenLists = [
    [
      Token(name: 'USDT', apy: '3.07%', price: '¥7.25', change: '0.00%'),
      Token(name: 'USDC', apy: '3.07%', price: '¥7.25', change: '0.00%'),
      Token(name: 'Q', price: '¥0.00', change: '0.00%'),
    ],
    [
      // NFT 分类的代币数据
      Token(name: 'NFT1', price: '¥10.00', change: '+5.00%'),
    ],
    [
      // 银行卡分类的代币数据
      Token(name: 'VISA', price: '¥100.00', change: '0.00%'),
    ],

  ];

  int _selectedNetWorkIndex =0; // 存储选中的索引
  final List<String> _items = [
    '选项1',
    '选项2',
    '选项3',
    '选项4',
    '选项5',
  ];

  int _selectedWalletIndex = 0;

  late Wallet _wallet;

  static const double _borderRadius = 20;
  static const double _borderWidth = 1.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _pageController = PageController();
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.jumpToPage(_tabController.index);
      }
    });
    _searchController.addListener(_filterItems);
    WidgetsBinding.instance.addObserver(this);
    _wallet = HiveStorage().getObject<Wallet>('currentSelectWallet') ?? Wallet.empty();

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 当应用从后台返回前台时调用
      _loadWalletData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 监听路由的显示状态
    ModalRoute? route = ModalRoute.of(context);
    if (route != null) {
      route.addScopedWillPopCallback(() async {
        return true;
      });
    }
  }

  @override
  void didUpdateWidget(WalletPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当页面重新进入视图时调用
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      _loadWalletData();
    }
  }

  Future<void> _loadWalletData() async {
    if (!mounted) return;

    // setState(() {
    //   _isLoading = true;
    //   _errorMessage = null;
    // });

    try {
      final wallet = await HiveStorage().getObject<Wallet>('currentSelectWallet');

      if (wallet != null) {
        // final updatedWallet = await _updateWalletBalance(wallet);

        if (!mounted) return;

        setState(() {
          _wallet = wallet;
          // _isLoading = false;
        });

        // 更新Hive中的钱包数据
        // await HiveStorage().saveObject('currentSelectWallet', updatedWallet);
      } else {
        if (!mounted) return;
      }
    } catch (e) {
      if (!mounted) return;
    }
  }


  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _refreshController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Padding(padding: EdgeInsets.all(5),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
              onTap: (){
                //弹出钱包Dialog
                showSelectWalletDialog();
              },
              child: Row(
                children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/images/ic_clip_photo.png',
                        width: 30.w,
                        height: 30.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 8.w,),
                    Text(_wallet.name,style: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.bold),),
                    SizedBox(width: 8.w,),
                    Image.asset('assets/images/ic_arrows_down.png',width: 8.w,height: 4.w),
                  ],
                ),
              ),
            ),
            SizedBox(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 5.h,horizontal: 5.h),
                    side: BorderSide(
                      color: Colors.grey,
                      width: 1.0, // 边框宽度
                    )
                ),
                onPressed: ()=>{
                  showAnimatedFullScreenDialog(context)
                },
                child: Row(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/images/ic_wallet_grid.png',
                        width: 25.w,
                        height: 25.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 5.w,),
                    Text(_items[_selectedNetWorkIndex],style: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.bold,color: Colors.black),),
                    SizedBox(width: 8.w,),
                    Image.asset('assets/images/ic_arrows_right.png',width: 9.w,height: 5.5.w),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
     ),
      body: EasyRefresh(
        controller: _refreshController,
        header: const ClassicHeader(),
        onRefresh: _onRefresh,
        child: _buildPageContent()
    ),
    );
  }

  //选择网络弹窗
  void showAnimatedFullScreenDialog(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullScreenDialog(
            title: '选择网络',
            child:Column(
              children: [
                // 搜索框
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '搜索...',
                      hintStyle: TextStyle(color: Color(0xFF909090)), // 提示文字颜色
                      prefixIcon: Icon(Icons.search, color: Color(0xFF909090)),
                      filled: true,
                      fillColor: Color(0xFFF3F3F3), // 背景颜色
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22.r), // 圆角22
                        borderSide: BorderSide.none, // 去除边框线
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 12.w,
                      ),
                    ),
                  ),
                ),
                // 列表
                Expanded(
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Image.asset('assets/images/ic_home_bit_coin.png', width: 37.5.w, height: 37.5.w),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(_items[index],style: TextStyle(fontSize: 16.sp,color: index == _selectedNetWorkIndex?AppColors.color_286713:Colors.black),),
                            ),
                            if(index == _selectedNetWorkIndex)
                              Image.asset('assets/images/ic_wallet_new_work_selected.png', width: 24, height: 24),
                          ],
                        ),
                        contentPadding: EdgeInsetsGeometry.symmetric(vertical: 10,horizontal: 10),
                        onTap: () {
                          setState(() {
                            _selectedNetWorkIndex = index;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }


  void showSelectWalletDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SelectWalletDialog(
        onWalletSelected: () {
          _loadWalletData();
        },
      ),
    );
  }

  Widget _buildTopView(){
    return Container(
      padding: EdgeInsets.only(top: 10.h,),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left:10.w,right: 10.w,top: 10.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_wallet.address.length > 12 
                    ? 'EVM:${_wallet.address.substring(0, 6)}...${_wallet.address.substring(_wallet.address.length - 6)}'
                    : 'EVM:${_wallet.address}',
                    style: TextStyle(fontSize: 13.sp,color: AppColors.color_757F7F),),
                Row(
                  children: [
                    Expanded(child: Text('¥${_wallet.balance}',style: TextStyle(fontSize: 40.sp,color: Colors.black,fontWeight: FontWeight.bold))),
                    SizedBox(
                      child: Material(
                        borderRadius: BorderRadius.circular(_borderRadius.r),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => {
                            Get.to(BackUpHelperPage())
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey,
                                width: _borderWidth,
                              ),
                              borderRadius: BorderRadius.circular(_borderRadius.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 15.w,
                            ),
                            child: _buildButtonContent(),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10.h,),
                Row(
                  children: [
                    Text(
                      '¥10.00 (0.00%)',
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.color_2B6D16
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w,),
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.h,
                        ),
                      ),
                      child: Center(
                          child: Row(
                            children: [

                              Text(
                                '今天',
                                style: TextStyle(
                                  color: AppColors.color_757F7F,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          )
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h,),
          GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
              children: List.generate(_titles.length, (index) {
                return GestureDetector(
                  onTap: (){
                    if(index == 0){
                      Get.to(
                        SelectTransferCoinTypePage(),
                        transition: Transition.downToUp,
                        duration: const Duration(milliseconds: 300),
                      );
                    }else if(index==1){
                      Get.to(
                        SelectedPayeePage(),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                      );
                    }
                  },
                  child: 
                    SizedBox(
                      height: 80,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _navIcons[index],
                          SizedBox(height: 5),
                          Text(
                            _titles[index],
                            style: TextStyle(fontSize: 12.sp, color: Colors.black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),
                );
              },
              )
          ),
          SizedBox(height: 15.h,),
          Divider(
            color: Color(0xFFEFEFEF),
            height: 1,  // 线的高度
            thickness: 1,  // 线的粗细
          ),


        ],
      ),
    );
  }

  Widget _buildPageContent(){
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildTopView(),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: StickyTabBarDelegate(
            child: TabBar(
              controller: _tabController,
              tabs: categories.map((tab) => Tab(text: tab)).toList(),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              dividerColor: Colors.transparent,
              labelStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.normal,
              ),

              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 1.5.h,
                  color: Colors.black,
                ),

              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 5.h,
              indicatorPadding: EdgeInsets.symmetric(horizontal: 15),
            ),
          ),
        ),
        SliverFillRemaining(
          child: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _tabController.animateTo(index)),
            children: [
              _buildHomePage(),
              _buildDeFiPage(),
              _buildNFTPage(),
              _buildBankCardPage(),
            ],
          ),
        )
      ],
    );
  }


  // 代币
  Widget _buildHomePage() {
    return CustomScrollView(
      physics: NeverScrollableScrollPhysics(),
      slivers: [

        // SliverList(
        //   delegate: SliverChildBuilderDelegate(
        //         (_, index) => _buildTokenItem(index),
        //     childCount: 6,
        //   ),
        // ),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: List.generate(
                  6, (index) => _buildTokenItem(index)),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.color_2B6D16, // 背景色 #286713
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(21.5.r), // 圆角21.5dp
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 11,
                    ),
                  ),
                  onPressed: () {
                    // 按钮点击事件
                  },
                  child: const Text(
                    '管理代币',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  )
              ),
            ),
          ),
        ),
      ],
    );
  }

  // DeFi
  Widget _buildDeFiPage() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                child: Row(
                  children: [
                    Expanded(child: Text('热门理财',style: TextStyle(fontSize: 19.sp,fontWeight: FontWeight.bold,color: Colors.black),),),
                    Image.asset('assets/images/ic_arrows_right.png',width: 7,height: 12,),
                  ],
                ),
              ),
              SizedBox(
                height: 115.h,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => {

                        },
                        child:_buildHotCoinItemView(),
                      );
                    }
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  // NFT
  Widget _buildNFTPage() {
    return Container(
      height: 200,
      padding: EdgeInsets.all(10),
      child:Text('NFT'),
    );
  }

  // 银行卡
  Widget _buildBankCardPage() {
    return Container(
      height: 200,
      padding: EdgeInsets.all(10),
      child:Text('银行卡'),
    );
  }

  Widget _buildTokenItem(int index) {
    return GestureDetector(
      onTap: ()=>{
        Get.to(CoinDetailPage())
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12,horizontal: 10),
        child: Row(
          children: [
            Stack(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/ic_home_bit_coin.png',
                    width: 45.w,
                    height: 45.w,
                  ),
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
                )),
              ],
            ),
            SizedBox(width: 10.w,),
            Expanded(child: Column(
              children: [
                Row(
                  children: [
                    Text('USDT',style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.bold,color: Colors.black),),
                    if(index<3)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.color_B5DE5B,
                          borderRadius: BorderRadius.circular(19.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 2,horizontal: 4),
                        height: 17.h,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/images/ic_home_search.png',width: 10.w,height: 8.w),
                            SizedBox(width: 3.w),
                            Text('${index+1}.98%APY',style: TextStyle(fontSize: 11.sp, color: AppColors.color_286713),),
                          ],
                        ),
                      )
                  ],
                ),
                Row(
                  children: [
                    Text('¥69$index,603.5',style: TextStyle(fontSize: 14.sp,color: Colors.grey,fontWeight: FontWeight.bold),),
                    Text('-0.${index}5%',style: TextStyle(fontSize: 14.sp,color: AppColors.color_F3607B,fontWeight: FontWeight.bold),),
                  ],
                ),
              ],
            )),
            Column(
              children: [
                Text('9.${index}0',style: TextStyle(fontSize: 16.sp,color: Colors.black,),),
                Text('¥${index+1}.00',style: TextStyle(fontSize: 14.sp,color: Colors.grey,fontWeight: FontWeight.bold),),
              ],
            )

          ],
        ),
      ),
    );
  }

  Widget _buildHotCoinItemView(){
    return Container(
      height: 115.h,
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE8EEEE),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/ic_home_bit_coin.png',
                  width: 35.h,
                  height: 35.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 11.w),
              Text(
                'FARTCION',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 11.h),
          Text(
            '¥1.14',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            '-10.22%',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.color_F3607B,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNetworkIcon(),
        SizedBox(width: 3.w),
        _buildNetworkText(),
      ],
    );
  }

  Widget _buildNetworkIcon() {
    return ClipOval(
      child: Image.asset(
        'assets/images/ic_wallet_reminder.png',
        width: 14.w,
        height: 14.w,
      ),
    );
  }

  Widget _buildNetworkText() {
    return Text(
      '去备份',
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  void _handleNetworkSelect(BuildContext context) {
    // 处理网络选择逻辑
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