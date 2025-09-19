import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/util/HiveStorage.dart';
import 'package:untitled1/pages/BackUpHelperPage.dart';
import 'package:untitled1/pages/SettingWalletPage.dart';
import 'package:untitled1/theme/app_textStyle.dart';
import '../../entity/Wallet.dart';
import '../AddWalletPage.dart';

/*
 * 选择钱包
 */
class SelectWalletDialog extends StatefulWidget {
  final VoidCallback? onWalletSelected;
  const SelectWalletDialog({Key? key, this.onWalletSelected}) : super(key: key);

  @override
  _SelectWalletDialogState createState() => _SelectWalletDialogState();
}

class _SelectWalletDialogState extends State<SelectWalletDialog> {
  bool _isEditMode = false; // 是否处于编辑模式
  List<Wallet> _wallets = [];
  List<Wallet> _originalItems = [];
  String? _selectedWalletAddress;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    // 初始化钱包数据（仅第一次运行）
    // if (walletBox.isEmpty) {
    //   await walletBox.addAll([
    //     Wallet(name: "我的钱包", balance: "￥0.00", network: 'eth',address: 'egh',privateKey: "0X01F0...459F39"),
    //     Wallet(name: "测试钱包", balance: "￥100.00", network: 'eth',address: 'egh',privateKey: "0X89A2...782B1C"),
    //   ]);
    // }

    setState(() {
      _wallets = HiveStorage().getList<Wallet>('wallets_data') ?? [];
      _originalItems = List.from(_wallets);
    });
    _selectedWalletAddress = HiveStorage().getValue('selected_address') ?? '';
  }

  void _selectWallet(Wallet wallet) {
    HiveStorage().putValue('selected_address', wallet.address);
    HiveStorage().putObject('currentSelectWallet', wallet);
    widget.onWalletSelected?.call();
  }

  Future<void> _saveWalletOrder() async {
    // 保存新的顺序到 Hive
    HiveStorage().putList('wallets_data', _wallets);
    setState(() {
      _originalItems = List.from(_wallets);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        // color: _isEditMode ? Theme.of(context).colorScheme.background : Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close, size: 30, color: Theme.of(context).colorScheme.onBackground),
                  onPressed: () => Navigator.pop(context),
                ),

                Expanded(
                  child: Center(
                    child: Text(
                      _isEditMode ? '编辑钱包' : '选择钱包',
                      style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground),
                    ),
                  ),
                ),
                TextButton(
                  child: Text(
                    _isEditMode ? '保存' : '管理',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: _isEditMode ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      if (_isEditMode) {
                        // 保存逻辑
                        _originalItems = List.from(_wallets); // 更新备份
                      }
                      _isEditMode = !_isEditMode;
                    });
                  },
                ),
              ],
            ),
          ),
          // 内容区域
          Expanded(child: _isEditMode ? _buildDraggableList() : _buildNormalList()),
        ],
      ),
    );
  }

  // 普通列表视图
  Widget _buildNormalList() {
    return Column(
      children: [
        // 顶部资产信息
        Container(
          margin: EdgeInsets.all(10.w),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: BorderRadius.circular(8.w)),
          child: Row(
            children: [
              Text('资产总额', style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground)),
              IconButton(
                icon: Image.asset('assets/images/ic_wallet_exclamation.png', width: 13.w, height: 13.w),
                onPressed: () => Navigator.pop(context),
              ),
              Spacer(),
              Text('¥0.00', style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: _wallets.length,
            itemBuilder: (_, index) => _buildWalletItem(_wallets[index], index),
          ),
        ),

        // 底部按钮
        Padding(
          padding: EdgeInsets.all(15.w),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onBackground,
              minimumSize: Size(double.infinity, 42.h),
              elevation: 0,
              shadowColor: Colors.transparent,
              textStyle: TextStyle(fontSize: 18.sp),
            ),
            onPressed: () => {Navigator.pop(context), Get.to(AddWalletPage())},
            child: Text('+添加钱包', style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  // 可拖拽列表视图
  Widget _buildDraggableList() {
    return ReorderableListView.builder(
      itemCount: _wallets.length,
      itemBuilder: (ctx, index) {
        return ReorderableDelayedDragStartListener(
          index: index,
          key: Key(_wallets[index].address), // 使用唯一ID作为key
          child: _buildDraggableView(_wallets[index]),
        );
      },
      onReorder: (oldIndex, newIndex) async {
        setState(() {
          if (oldIndex < newIndex) newIndex--;
          final item = _wallets.removeAt(oldIndex);
          _wallets.insert(newIndex, item);
        });
        await _saveWalletOrder(); // 保存新顺序
      },
    );
  }

  Widget _buildDraggableView(Wallet item) {
    final isSelected = _selectedWalletAddress == item.address;
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        height: 80, // 自定义高度
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(color: isSelected ? AppColors.color_F7F8F9 : Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset('assets/images/ic_clip_photo.png', width: 37.5.w, height: 37.5.w, fit: BoxFit.cover),
            ),
            SizedBox(width: 8.w),
            // 自定义内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(item.balance, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            // 右侧操作按钮
            IconButton(
              icon: Image.asset('assets/images/ic_wallet_edit.png', width: 20.h, height: 20.h),
              onPressed: () {
                Navigator.pop(context);
                Get.to(SettingWalletPage(), arguments: item);
              },
            ),
            SizedBox(width: 12),
            Image.asset('assets/images/ic_wallet_drag_handle.png', width: 20.h, height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletItem(Wallet wallet, int index) {
    final isSelected = _selectedWalletAddress == wallet.address;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectWallet(wallet);
          Navigator.pop(context);
        });
      },
      child: Container(
        // padding: EdgeInsets.symmetric(horizontal: 12.w,vertical: 1.w),
        margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: isSelected ? AppColors.color_286713 : Colors.transparent, width: 1.5.h),
        ),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset('assets/images/ic_clip_photo.png', width: 37.5.w, height: 37.5.w, fit: BoxFit.cover),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(wallet.name, style: TextStyle(fontSize: 16.sp)),
                          Text(
                            '¥${wallet.balance}',
                            style: TextStyle(fontSize: 13.sp, color: AppColors.color_909090),
                          ),
                        ],
                      ),
                      Spacer(),
                      if (!wallet.isBackUp)
                        SizedBox(
                          child: Material(
                            borderRadius: BorderRadius.circular(20.r),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => () {
                                Navigator.pop(context);
                                Get.to(BackUpHelperPage());
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: AppColors.color_E4E4E4, width: 0.5),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 8.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipOval(
                                      child: Image.asset('assets/images/ic_wallet_reminder.png', width: 14.w, height: 14.w),
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      '去备份',
                                      style: TextStyle(fontSize: 12.sp, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    wallet.address.length > 12
                        ? 'EVM:${wallet.address.substring(0, 6)}...${wallet.address.substring(wallet.address.length - 6)}'
                        : 'EVM:${wallet.address}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: -1.5,
                right: -1,
                child: Image.asset('assets/images/ic_wallet_selected.png', width: 34.w, height: 34.5.w, fit: BoxFit.cover),
              ),
          ],
        ),
      ),
    );
  }
}
