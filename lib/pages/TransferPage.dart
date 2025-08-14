import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/pages/view/CustomAppBar.dart';
import 'package:untitled1/pages/view/CustomTextField.dart';

import '../../base/base_page.dart';

/*
 * 转账
 */
class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<StatefulWidget> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage>
    with BasePage<TransferPage>, AutomaticKeepAliveClientMixin {

    String _diyWalletName = '';
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('转账',style: TextStyle(fontSize: 24.sp,fontWeight: FontWeight.w600),),
                    SizedBox(height: 10.h,),
                    Text('选择币种和网络'),
                    SizedBox(height: 10.h,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 45.h),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        side: BorderSide(
                          color: AppColors.color_EEEEEE,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                      ),
                      onPressed: (){

                      },
                      child: Row(
                        children: [
                          Image.asset('assets/images/ic_home_bit_coin.png',width: 20.5.w,height: 20.5.w),
                          SizedBox(width: 8.w),
                          Expanded(child: Text('ARB',style: TextStyle(fontSize: 16.sp,color: Colors.black,fontWeight: FontWeight.w600),)),
                          Text('转账网络 Arbitrum',style: TextStyle(fontSize: 13.sp,color: AppColors.color_757F7F),),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12.w,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h,),
                    Row(
                      children: [
                        Expanded(child: Text('收款地址',),),
                        Image.asset('assets/images/ic_home_bit_coin.png',width: 20.5.w,height: 20.5.w),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Divider(height: 8.h,color: AppColors.color_757F7F,),
                        ),
                        Image.asset('assets/images/ic_home_bit_coin.png',width: 20.5.w,height: 20.5.w),
                      ],
                    ),
                    SizedBox(height: 12.h,),
                    CustomTextField(
                      hintText: "请输入收款地址",
                      controller: _textController,
                      onChanged: (text) {
                        setState(() {
                          _diyWalletName = text;
                        });
                      },
                    ),

                    SizedBox(height: 12.h,),
                    Row(
                      children: [
                        Expanded(child: Text('转账数量',),),
                        Text('可用:0.01 ARB',style: TextStyle(fontSize: 13.sp,color: AppColors.color_757F7F),),
                        SizedBox(width: 5.w,),
                        Image.asset('assets/images/ic_home_bit_coin.png',width: 20.5.w,height: 20.5.w),
                      ],
                    ),
                    SizedBox(height: 6.h,),
                    CustomTextField(
                      hintText: "0.00",
                      controller: _textController,
                      onChanged: (text) {
                        setState(() {
                          _diyWalletName = text;
                        });
                      },
                    ),

                    SizedBox(height: 16.h,),
                    Text('Gas费',),
                    SizedBox(height: 6.h,),
                    CustomTextField(
                      hintText: "<¥0.01",
                      controller: _textController,
                      onChanged: (text) {
                        setState(() {
                          _diyWalletName = text;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(15.w),
            margin: EdgeInsets.only(bottom: 10.h),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27.5.r),
                ),
              ),
              onPressed: () {},
              child: Text('确认',),
            ),
          ),
        ],
      )
    );
  }


  @override
  bool get wantKeepAlive => true;

}