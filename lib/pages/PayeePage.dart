import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/pages/view/CustomAppBar.dart';
import 'package:untitled1/pages/view/CustomTextField.dart';

import '../../base/base_page.dart';

/*
 * 收款
 */
class PayeePage extends StatefulWidget {
  const PayeePage({super.key});

  @override
  State<StatefulWidget> createState() => _PayeePageState();
}

class _PayeePageState extends State<PayeePage>
    with BasePage<PayeePage>, AutomaticKeepAliveClientMixin {

    String _diyWalletName = '';
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          icon: Icon(Icons.close, size: 20.h),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: '',
      ),
      body: Column(
        children: [
          // 可滚动内容部分
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(), // 更流畅的滚动效果
              padding: EdgeInsets.only(bottom: 20.h, right: 16.w, left: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40.h),
                  Image.asset('assets/images/ic_clip_photo.png', width: 55.h, height: 55.h),
                  SizedBox(height: 15.h),
                  Text('USDT收款', style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 10.h),
                  Text('收款网络 Solana', style: TextStyle(fontSize: 14.sp)),
                  SizedBox(height: 36.h),
                  Image.asset('assets/images/ic_home_visa.png', width: 182.w, height: 182.w, fit: BoxFit.fill),
                  SizedBox(height: 22.h),
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
                    onPressed: () {},
                    child: Row(
                      children: [
                        Expanded(child: Text('JBngZcyupoMocY8MCe3n', style: TextStyle(fontSize: 14.sp, color: AppColors.color_909090))),
                        SizedBox(width: 30.w),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12.w,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.color_E7EDED, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 12.5.w, vertical: 20.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/ic_wallet_create.png',
                                  width: 50.w,
                                  height: 50.w,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(width: 8.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('从交易平台收款', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8.h),
                                    InkWell(
                                      onTap: () {},
                                      child: Text('支持从你的账户直接充值，方便快捷', style: TextStyle(fontSize: 12.sp, color: AppColors.color_A3ADAD)),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12.w,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(12.0),
                            decoration: const BoxDecoration(
                              color: AppColors.color_F8F8F8,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/ic_wallet_reminder.png',
                                  width: 14.w,
                                  height: 14.w,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  '仅支持接收USDT(Solana)资产到',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 添加底部间距，避免内容被按钮遮挡
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(15.w),
            margin: EdgeInsets.only(bottom: 15.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -5)),
              ],
            ),
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
              child: Text('分享'),
            ),
          ),
        ],
      ),
    );
}


  @override
  bool get wantKeepAlive => true;

}