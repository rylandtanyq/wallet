// 新建一个独立的 StatefulDialog 组件
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:untitled1/pages/BackUpHelperPage.dart';
import 'package:untitled1/pages/ImportWalletPage.dart';
import 'package:untitled1/theme/app_textStyle.dart';

import '../../constants/AppColors.dart';
import '../../entity/AddWalletEntity.dart';
import '../LinkHardwareWalletPage.dart';

class ImportWalletDialog extends StatefulWidget {
  final String title;
  final List<AddWallet> items;
  final Widget child;

  const ImportWalletDialog({Key? key, required this.title, required this.items, required this.child}) : super(key: key);

  @override
  State<ImportWalletDialog> createState() => _ImportWalletDialogState();
}

class _ImportWalletDialogState extends State<ImportWalletDialog> {
  bool _isTextVisible = false;
  bool _isPrivateKeyTextVisible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 30, color: Theme.of(context).colorScheme.onBackground),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ),
                  widget.child,
                  _buildCreateCard(
                    'assets/images/ic_wallet_create.png',
                    '助记词或私钥钱包',
                    '',
                    _isTextVisible,
                    () {
                      setState(() {
                        _isTextVisible = !_isTextVisible;
                      });
                    },
                    () {
                      Navigator.pop(context);
                      Get.to(ImportWalletPage());
                    },
                  ),
                  _buildCreateCard(
                    'assets/images/ic_wallet_create.png',
                    '无私钥钱包',
                    '',
                    _isPrivateKeyTextVisible,
                    () {
                      setState(() {
                        _isPrivateKeyTextVisible = !_isPrivateKeyTextVisible;
                      });
                    },
                    () {
                      Navigator.pop(context);
                      Get.to(LinkHardwareWalletPage());
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateCard(String icon, String name, String infoDetail, bool isTextVisible, VoidCallback onTap, VoidCallback onNextPage) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12), // 整体外边框圆角
      child: Container(
        margin: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(.1), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.5.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.1),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Image.asset(icon, width: 50.w, height: 50.w, fit: BoxFit.cover),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.size17.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground),
                      ),
                      SizedBox(height: 8.h),
                      InkWell(
                        onTap: onTap,
                        child: Text('显示详情', style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      ),
                    ],
                  ),
                  Spacer(),
                  SizedBox(
                    child: InkWell(
                      onTap: onNextPage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(.3), width: 1),
                          borderRadius: BorderRadius.circular(21.5.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 22.w),
                        child: Text('导入', style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth, // 继承父级最大宽度
                        child: Wrap(
                          spacing: 12.0,
                          runSpacing: 5.0,
                          alignment: WrapAlignment.start,
                          children: [_buildItem("支持 12 /24 位助记词"), _buildItem("支持数百种网络的私钥"), _buildIconItem("支持")],
                        ),
                      );
                    },
                  ),
                  AnimatedSize(
                    duration: Duration(milliseconds: 100),
                    child: isTextVisible
                        ? Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              '非常非常长的文本内容，非常非常长的文本内容，非常非常长的文本内容，非常非常长的文本内容，非常非常长的文本内容，非常非常长的文本内容',
                              style: TextStyle(color: AppColors.color_757F7F, fontSize: 12.sp),
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(.1), borderRadius: BorderRadius.circular(13.5.r)),
      child: Text(text, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
    );
  }

  Widget _buildIconItem(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(.1), borderRadius: BorderRadius.circular(13.5.r)),
      child: Wrap(
        children: [
          Text(text, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          SizedBox(width: 2.w),
          Image.asset('assets/images/ic_home_app_icon.png', width: 17.w, height: 17.w),
          SizedBox(width: 2.w),
          Image.asset('assets/images/ic_home_app_icon1.png', width: 17.w, height: 17.w),
          SizedBox(width: 2.w),
          Image.asset('assets/images/ic_home_app_icon2.png', width: 17.w, height: 17.w),
        ],
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  final AddWallet item;
  final VoidCallback onTap;

  const ItemWidget({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            title: Text(item.name),
            trailing: IconButton(icon: Icon(item.isExpanded ? Icons.expand_less : Icons.expand_more), onPressed: onTap),
          ),
          AnimatedSize(
            duration: Duration(milliseconds: 200),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              child: item.isExpanded ? Text(item.infoDetails) : null,
            ),
          ),
        ],
      ),
    );
  }
}
