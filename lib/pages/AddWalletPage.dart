import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/entity/AddWalletEntity.dart';
import 'package:untitled1/pages/LinkHardwareWalletPage.dart';
import 'package:untitled1/pages/dialog/CreateWalletDialog.dart';
import 'package:untitled1/pages/view/CustomAppBar.dart';

import '../../base/base_page.dart';
import 'ObserveWalletPage.dart';
import 'dialog/ImportWalletDialog.dart';

/*
 * 添加钱包
 */
class AddWalletPage extends StatefulWidget {
  const AddWalletPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddWalletPageState();
}

class _AddWalletPageState extends State<AddWalletPage>
    with BasePage<AddWalletPage>, AutomaticKeepAliveClientMixin {

  final List<Map<String, dynamic>> items = [
    {
      'icon': 'assets/images/ic_wallet_create.png',
      'mainTitle': '创建钱包',
      'subTitle': '创建新的助记词或无私钥钱包',
      'action': () => Get.to(LinkHardwareWalletPage()),
    },
    {
      'icon': 'assets/images/ic_wallet_import.png',
      'mainTitle': '导入钱包',
      'subTitle': '通过助记词、私钥或备份导入已有钱包',
      'action': () => Get.toNamed('/profile'),
    },
    {
      'icon': 'assets/images/ic_wallet_hardware.png',
      'mainTitle': '连接硬件钱包',
      'subTitle': '通过扫描二维码连接硬件钱包',
      'action': () => Get.to(LinkHardwareWalletPage()),
    },
    {
      'icon': 'assets/images/ic_wallet_observe.png',
      'mainTitle': '使用观察钱包',
      'subTitle': '通过钱包地址追踪钱包资产动态',
      'action': () => Get.to(ObserveWalletPage()),
    },
  ];

  final List<AddWallet> _wallets = [
    AddWallet(name: "我的钱包", balance: "￥0.00", address: "EVM: 0X01F0...459F39",infoDetails: "超长的文本---------",isExpanded: false),
    AddWallet(name: "测试钱包", balance: "￥100.00", address: "EVM: 0X89A2...782B1C",infoDetails: "超长的文本---------",isExpanded: false),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        backgroundColor: AppColors.color_F7F8F9,
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/ic_wallet_exclamation.png',
              width: 17.w,
              height: 17.w,
            ),
            onPressed: () => {
              setState(() {

              })
            },
          ),

        ],
      ),
      body: Container(
        color: AppColors.color_F7F8F9,
        padding: EdgeInsets.all(10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('添加钱包',style: TextStyle(fontSize: 24.sp,fontWeight: FontWeight.bold),),
            SizedBox(height: 10.h,),
            Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return _buildListItem(
                      icon: item['icon'],
                      mainTitle: item['mainTitle'],
                      subTitle: item['subTitle'],
                      onTap: (){
                        if (index == 0) {
                          showCreateWalletDialog(context);
                        }else if (index == 1) {
                          showImportWalletDialog();
                        } else {
                          item['action']();
                        };
                      },
                    );
                  },
                ),
            )

          ],
        ),
      ),
    );
  }

  // 调用方式
  void showCreateWalletDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => CreateWalletDialog(
        title: '创建钱包',
        items:_wallets,
        child: SizedBox(),
      ),
      isScrollControlled: true,
    );
  }

  void showImportWalletDialog(){
    showModalBottomSheet(
      context: context,
      builder: (context) => ImportWalletDialog(
        title: '导入钱包',
        items:_wallets,
        child: SizedBox(),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildListItem({
    required String icon,
    required String mainTitle,
    required String subTitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.blue.withOpacity(0.1), // 点击效果
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.w),
        ),
        margin: EdgeInsets.symmetric(vertical: 5.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            // 左侧图标
            // Container(
            //   width: 40.w,
            //   height: 40.w,
            //   decoration: BoxDecoration(
            //     color: Colors.blue.withOpacity(0.1),
            //     borderRadius: BorderRadius.circular(8.w),
            //   ),
            //   child: Icon(icon, size: 20.w, color: Colors.blue),
            // ),
            Image.asset(icon,width: 51.5.w,height: 51.5.w,),
            SizedBox(width: 13.w),

            // 主副标题
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainTitle,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    subTitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color:AppColors.color_757F7F,
                    ),
                  ),
                ],
              ),
            ),

            // 右侧箭头
            Icon(
              Icons.arrow_forward_ios,
              size: 12.w,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

}