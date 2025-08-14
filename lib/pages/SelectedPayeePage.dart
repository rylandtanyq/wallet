import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/pages/dialog/PayeeSelectNetworkDialog.dart';
import 'package:untitled1/pages/view/CustomAppBar.dart';
import '../constants/AppColors.dart';

class SelectedPayeePage extends StatefulWidget {
  

  const SelectedPayeePage({
    super.key,
  });

  @override
  State<SelectedPayeePage> createState() => _SelectedPayeePageState();
}

class _SelectedPayeePageState extends State<SelectedPayeePage> with TickerProviderStateMixin  {
  final List<String> categories = ['按币种','按网络'];
    int _selectedIndex = 0;
  late PageController _pageController;
  final List<String> _items = [
    'USDT',
    'USDC',
    'ETH',
    'SOL',
    'BNB',
    'BTC',
  ];

  final List<NetworkItem> _allItems = [
    NetworkItem(name: "微信", isHot: true, pinyin: "weixin"),
    NetworkItem(name: "支付宝", isHot: true, pinyin: "zhifubao"),
    NetworkItem(name: "抖音", isHot: true, pinyin: "douyin"),
    NetworkItem(name: "Apple", pinyin: "apple"),
    NetworkItem(name: "Banana", pinyin: "banana"),
    NetworkItem(name: "阿里巴巴", pinyin: "alibaba"),
    NetworkItem(name: "百度", pinyin: "baidu"),
    NetworkItem(name: "腾讯", pinyin: "tengxun"),
    NetworkItem(name: "京东", pinyin: "jingdong"),
    NetworkItem(name: "美团", pinyin: "meituan"),
    NetworkItem(name: "Zoom", pinyin: "zoom"),
    NetworkItem(name: "Xbox", pinyin: "xbox"),
    NetworkItem(name: "Cat", pinyin: "cat"),
    NetworkItem(name: "Dog", pinyin: "dog"),
  ];


  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '收款',
        centerTitle: false,
      ),
      body: Container(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(categories.length, (index) {
                final selected = _selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    _pageController.animateToPage(index, duration: Duration(milliseconds: 250), curve: Curves.ease);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            categories[index],
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                              color: selected ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: 2.5.h,
                          width: 60.w,
                          decoration: BoxDecoration(
                            color: selected ? Colors.black : Colors.transparent,
                            borderRadius: BorderRadius.circular(1.5.h),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: [
                  _buildCoinTypePage(),
                  _buildNetworkPage(),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinTypePage(){
    return Column(
      children: [
          Row(
            children: [
              Expanded(child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15.w,vertical: 15.h),
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(19.r),
                ),
                height: 37.h,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/ic_home_search.png',width: 16.w,height: 16.w),
                    SizedBox(width: 8.w),
                    Text('代币名称或者合约地址',style: TextStyle(fontSize: 14.sp, color: Colors.grey),),

                  ],
                ),
              )
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return _buildCoinTypeItem(index);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCoinTypeItem(int index) {
    return GestureDetector(
      onTap: (){
        showPayeeSelectNetworkDialog(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12,horizontal: 10),
        color: Colors.white,
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/ic_home_bit_coin.png',
                width: 40.w,
                height: 40.h,
              ),
            ),
            SizedBox(width: 10.w,),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_items[index],style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.w600,color: Colors.black),),
                Text('多链',style: TextStyle(fontSize: 13.sp,color: AppColors.color_909090,),),
              ],
            )),
            Column(
              children: [
                Text('9.${index}0',style: TextStyle(fontSize: 16.sp,color: Colors.black,fontWeight: FontWeight.bold),),
                Text('¥${index+1}.00',style: TextStyle(fontSize: 13.sp,color: AppColors.color_909090,fontWeight: FontWeight.bold),),
              ],
            )

          ],
        ),
      ),
    );
  }

  Widget _buildNetworkPage(){
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15.h,vertical: 15.h),
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(19.r),
          ),
          height: 37.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('assets/images/ic_home_search.png',width: 16.w,height: 16.w),
              SizedBox(width: 8.w),
              Text('网络名称',style: TextStyle(fontSize: 14.sp, color: AppColors.color_909090),),

            ],
          ),
        ),
        Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return _buildNetwrokItem(index);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildNetwrokItem(int index) {
    return GestureDetector(
      onTap: (){
        // Navigator.pop(context);
        showPayeeSelectNetworkDialog(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12,horizontal: 10),
        color: Colors.white,
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/ic_home_bit_coin.png',
                width: 40.w,
                height: 40.h,
              ),
            ),
            SizedBox(width: 10.w,),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BNB Chain',style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.w600,color: Colors.black),),
                Text('多链',style: TextStyle(fontSize: 13.sp,color: AppColors.color_909090,),),
              ],
            )),
            Image.asset(
                'assets/images/ic_home_bit_coin.png',
                width: 32.5.w,
                height: 32.5.h,
            )

          ],
        ),
      ),
    );
  }


  //选择网络弹窗
  void showPayeeSelectNetworkDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => PayeeSelectNetworkDialog(
        title: '选择网络',
        items:_items,
      ),
      isScrollControlled: true,
    );
  }


}


class NetworkItem {
  final String name;
  final bool isHot;
  final String pinyin;

  NetworkItem({
    required this.name,
    this.isHot = false,
    required this.pinyin,
    });
}
