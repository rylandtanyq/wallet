// 新建一个独立的 StatefulDialog 组件

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/pages/BackUpHelperPage.dart';
import 'package:untitled1/theme/app_textStyle.dart';

import '../../constants/app_colors.dart';
import '../../entity/AddWalletEntity.dart';
import '../../pages/LinkHardwareWalletPage.dart';

class CreateWalletDialog extends StatefulWidget {
  final String title;
  final List<AddWallet> items;
  final Widget child;

  const CreateWalletDialog({Key? key, required this.title, required this.items, required this.child}) : super(key: key);

  @override
  State<CreateWalletDialog> createState() => _ToggleDialogState();
}

class _ToggleDialogState extends State<CreateWalletDialog> {
  bool _isTextVisible = false;
  bool _isPrivateKeyTextVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        // color: Theme.of(context).colorScheme.background,
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
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
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
                  // ListView.builder(
                  //   itemCount: widget.items.length,
                  //   itemBuilder: (context, index) {
                  //     return ItemWidget(
                  //       item: widget.items[index],
                  //       onTap: () {
                  //         setState(() {
                  //           widget.items[index].isExpanded = !widget.items[index].isExpanded;
                  //         });
                  //       },
                  //     );
                  //   },
                  // ),
                  widget.child,
                  _buildCreateCard(
                    'assets/images/ic_wallet_create.png',
                    t.wallet.mnemonicWallet,
                    '',
                    _isTextVisible,
                    () {
                      setState(() {
                        _isTextVisible = !_isTextVisible;
                      });
                    },
                    () {
                      Get.to(BackUpHelperPage());
                    },
                  ),
                  _buildCreateCard(
                    'assets/images/ic_wallet_create.png',
                    t.wallet.noPrivateKeyWallet,
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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.1),
              ),
              child: Row(
                children: [
                  Image.asset(icon, width: 50.w, height: 50.w, fit: BoxFit.cover),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.size17.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.h),
                        InkWell(
                          onTap: onTap,
                          child: Text(t.wallet.showDetails, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                        ),
                      ],
                    ),
                  ),
                  // Spacer(),
                  SizedBox(width: 8.w),
                  SizedBox(
                    width: 70.w,
                    child: InkWell(
                      onTap: onNextPage,
                      child: Container(
                        decoration: BoxDecoration(
                          // color: Colors.white,
                          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(.3), width: 1),
                          borderRadius: BorderRadius.circular(21.5.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                        child: Text(
                          t.wallet.create,
                          style: TextStyle(fontSize: 16.sp, color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                // color: Theme.of(context).colorScheme.background,
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
                          children: [
                            _buildItem(t.wallet.mostUsed),
                            _buildItem(t.wallet.mnemonicIs12Words),
                            _buildItem(t.wallet.mnemonicIsLikePassword),
                            _buildItem(t.wallet.keepItSafe),
                            _buildItem(t.wallet.handwrittenBackup),
                            _buildIconItem(t.wallet.support),
                          ],
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
      child: Text(
        text,
        style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  Widget _buildIconItem(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(.1), borderRadius: BorderRadius.circular(13.5.r)),
      child: Wrap(
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 12.sp, color: AppColors.color_757F7F),
          ),
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
