import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/pages/SettingWalletPage.dart';

import '../../entity/Wallet.dart';
import '../AddWalletPage.dart';
import '../view/CustomTextField.dart';

class UpdateWalletDialog extends StatefulWidget {
  @override
  _UpdateWalletDialogState createState() => _UpdateWalletDialogState();
}

class _UpdateWalletDialogState extends State<UpdateWalletDialog> {
  bool _isDIYNameMode = false; // 是否是自定义名字
  String _diyWalletName = '';
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        // color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 标题栏（固定高度）
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Center(
              child: Text(
                '修改钱包名称',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.all(15.w),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(22.r)),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                      backgroundColor: _isDIYNameMode
                          ? Theme.of(context).colorScheme.onSurface.withOpacity(.3)
                          : Theme.of(context).colorScheme.onSurface.withOpacity(.1),
                      foregroundColor: _isDIYNameMode ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onBackground,
                      minimumSize: Size(double.infinity, 40.h),
                      elevation: 0,
                      textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19.r)),
                    ),
                    onPressed: () {
                      setState(() {
                        _isDIYNameMode = false;
                      });
                    },
                    child: Text('使用域名'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                      backgroundColor: _isDIYNameMode
                          ? Theme.of(context).colorScheme.onSurface.withOpacity(.1)
                          : Theme.of(context).colorScheme.onSurface.withOpacity(.3),
                      foregroundColor: _isDIYNameMode ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.onSurface,
                      minimumSize: Size(double.infinity, 40.h),
                      elevation: 0,
                      textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19.r)),
                    ),
                    onPressed: () {
                      setState(() {
                        _isDIYNameMode = true;
                      });
                    },
                    child: Text('自定义名称'),
                  ),
                ),
              ],
            ),
          ),

          // 内容区域（自适应剩余空间）
          Expanded(child: _isDIYNameMode ? _buildDIYNameView() : _buildDomainNameView()),

          // 分割线
          Divider(height: 0.75.h, color: AppColors.color_EEEEEE),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
            margin: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.color_286713,
                      minimumSize: Size(double.infinity, 42.h),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      textStyle: TextStyle(fontSize: 18.sp),
                      side: BorderSide(color: AppColors.color_286713, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27.5)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text('取消'),
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.color_286713,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 42.h),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      textStyle: TextStyle(fontSize: 18.sp),
                    ),
                    onPressed: () {
                      // 确认逻辑
                    },
                    child: Text('确认'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainNameView() {
    return Container(
      padding: EdgeInsets.only(top: 20.h),
      child: Column(
        children: [
          Center(
            child: Text(
              '您还没有专属NFT域名\n去交易市场逛逛?',
              style: TextStyle(fontSize: 14.sp, color: AppColors.color_909090),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            margin: EdgeInsets.all(12.h),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: BorderRadius.circular(7.5.r)),
            child: Row(
              children: [
                Image.asset('assets/images/ic_home_bit_coin.png', width: 20.5.w, height: 20.5.w),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'ENS:Etherenum Name S',
                    style: TextStyle(fontSize: 13.sp, color: Theme.of(context).colorScheme.onBackground),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.arrow_forward_ios, size: 12.w, color: Colors.grey[400]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDIYNameView() {
    _textController.text = _diyWalletName;
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '输入新的钱包名称',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14.sp),
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              hintText: "请输入内容",
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
    );
  }
}
