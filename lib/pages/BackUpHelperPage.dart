import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/pages/view/CustomAppBar.dart';

import '../../base/base_page.dart';
import '../core/AdvancedMultiChainWallet.dart';
import 'BackUpHelperOnePage.dart';

/*
 * 备份助记词
 */
class BackUpHelperPage extends StatefulWidget {
  const BackUpHelperPage({super.key});

  @override
  State<StatefulWidget> createState() => _BackUpHelperPageState();
}

class _BackUpHelperPageState extends State<BackUpHelperPage>
    with BasePage<BackUpHelperPage>, AutomaticKeepAliveClientMixin {

  bool isSelected = true;
  final wallet = AdvancedMultiChainWallet();

  @override
  void initState() {
    super.initState();
    wallet.initialize();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: '',
      ),
      body:  Container(
        color: Colors.white,
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Container(
             padding: EdgeInsets.all(12.w),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text('备份前请谨记!',style: TextStyle(fontSize: 24.sp,fontWeight: FontWeight.bold),),
                 SizedBox(height: 10.h,),
                 Row(
                   children: [
                     Image.asset('assets/images/ic_wallet_new_work_selected.png',width: 13.w,height: 10.h,),
                     SizedBox(width: 3.5.w,),
                     Text('建议手写抄录',style: TextStyle(color: AppColors.color_757F7F,fontSize: 12.sp),),
                     SizedBox(width: 20.w,),
                     Image.asset('assets/images/ic_wallet_unselected.png',width: 10.w,height: 10.h,),
                     SizedBox(width: 3.5.w,),
                     Text('请勿复制保存',style: TextStyle(color: AppColors.color_757F7F,fontSize: 12.sp),),
                     SizedBox(width: 20.w,),
                     Image.asset('assets/images/ic_wallet_unselected.png',width: 10.w,height: 10.h,),
                     SizedBox(width: 3.5.w,),
                     Text('请勿截屏保存!',style: TextStyle(color: AppColors.color_757F7F,fontSize: 12.sp),),
                     SizedBox(width: 20.w,),
                   ],
                 ),
                 SizedBox(height: 10,),
                 _buildSuggestView('assets/images/ic_wallet_backup1.png',"助记词相当于你的钱包密码","获得助记词等于获得资产所有权，一旦泄露资"),
                 _buildSuggestView('assets/images/ic_wallet_backup2.png',"请手写抄录或存储于冷钱包等离线设备 中","若复制或截屏保存，助记词有可能泄露"),
                 _buildSuggestView('assets/images/ic_wallet_backup3.png',"将助记词存放在安全的地方","一旦丢失资产将无法找回资"),
               ],
             ),
           ),

            Expanded( // 自动填充剩余空间
              child: Container(color: Colors.white),
            ),

            Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      isSelected = value!;
                    });
                  },
                  shape: CircleBorder(), // 圆形
                  fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.selected)) {
                      return const Color(0xFF286713); // 选中颜色 #286713
                    }
                    return Colors.transparent; // 未选中颜色
                  }),
                ),
                Flexible( // 或 Expanded
                  child: Text('助记词由您个人保管，请务必备份!一旦丢失资产将无法找回!',
                    style: TextStyle(color: AppColors.color_757F7F,fontSize: 12.sp),),
                ),


              ],
            ),
            Padding(
              padding: EdgeInsets.all(15.w),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.color_286713,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 42.h),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                  ),
                ),
                onPressed: ()=>{
                  createWalletToBackUp()
                },
                child: Text('备份助记词'),
              ),
            )


          ],
        ),
      ),
    );
  }

  Widget _buildSuggestView(String icon,String title,String subTitle){
    return Container(
      margin: EdgeInsets.only(top: 20,bottom: 20),
      child: Row(
        children: [

          Image.asset(icon,width: 30.5.w,height: 45.h,),
          SizedBox(width: 12.w),

          // 主副标题
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subTitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color:AppColors.color_757F7F,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  void createWalletToBackUp() async{
    showLoadingDialog();
    final walletData = await createWallet();
    dismissLoading();
    Get.off(BackUpHelperOnePage(),arguments:walletData);
  }

  Future<Map<String,String>> createWallet() async {
    final newWallet = await wallet.createNewWallet();
    print('New wallet created:');
    print('Mnemonic: ${newWallet['mnemonic']}');
    print('privateKey: ${newWallet['privateKey']}');
    print('Current address: ${newWallet['currentAddress']}');
    print('currentNetwork: ${newWallet['currentNetwork']}');
    return newWallet;
  }

  @override
  bool get wantKeepAlive => true;

}