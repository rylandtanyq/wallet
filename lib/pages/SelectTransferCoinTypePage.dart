
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:untitled1/pages/TransferPage.dart';
import 'package:untitled1/pages/view/CustomAppBar.dart';
import 'package:untitled1/pages/view/HorizntalSelectList.dart';
import '../constants/AppColors.dart';

class SelectTransferCoinTypePage extends StatefulWidget {
  

  const SelectTransferCoinTypePage({
    super.key,
  });

  @override
  State<SelectTransferCoinTypePage> createState() => _SelectTransferCoinTypePageState();
}

class _SelectTransferCoinTypePageState extends State<SelectTransferCoinTypePage> with TickerProviderStateMixin  {

  final List<String> _items = [
    'USDT',
    'USDC',
    'ETH',
    'SOL',
    'BNB',
    'BNB',
    'BNB',
    'BNB',
    'BNB',
    'BNB',
    'BNB',
    'BTC',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '选中转账币种',
      ),
      body: Container(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          children: [
              Row(
                children: [
                  Expanded(child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.w,vertical: 10.h),
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
            HorizontalSelectList(
              items: List.generate(10, (index) => '榜单 ${index + 1}'),
              onSelected: (index) {
                print('选中: $index');
              },
            ),
            SizedBox(height: 15.h,),
            Divider(height: 0.5,color: AppColors.color_EEEEEE,),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 代币列表
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        return _buildCoinTypeItem(index);
                      },
                    ),
                    
                    // 底部提示（紧接在列表后）
                    Padding(
                      padding: EdgeInsets.only(top: 20.h, bottom: 30.h),
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              '没找到相应的代币?\n可点击下方按钮添加',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.color_909090,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.color_2B6D16,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(21.5.r),
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
                                    '添加代币',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }


  Widget _buildCoinTypeItem(int index) {
    return GestureDetector(
      onTap: (){
        Navigator.pop(context);
        Get.to(TransferPage());
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
