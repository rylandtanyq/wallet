import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:untitled1/constants/app_colors.dart';
import 'package:untitled1/constants/hive_boxes.dart';
import 'package:untitled1/hive/Wallet.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/pages/BackUpHelperOnePage.dart';
import 'package:untitled1/util/HiveStorage.dart';
import 'package:untitled1/pages/SettingWalletPage.dart';
import 'package:untitled1/theme/app_textStyle.dart';
import 'package:untitled1/util/calcTotalBalanceReadable.dart';
import '../../pages/AddWalletPage.dart';

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
  String _calcTotalAdderessBalance = '0.00';

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _wallets = await HiveStorage().getList<Wallet>('wallets_data', boxName: boxWallet) ?? [];
    setState(() {
      _originalItems = List.from(_wallets);
    });
    _selectedWalletAddress = await HiveStorage().getValue<String>('selected_address', boxName: boxWallet) ?? '';
    _calcTotalAdderessBalance = await calcTotalBalanceReadable();
  }

  void _selectWallet(Wallet wallet) {
    HiveStorage().putValue('selected_address', wallet.address, boxName: boxWallet);
    HiveStorage().putObject('currentSelectWallet', wallet, boxName: boxWallet);
    widget.onWalletSelected?.call();
  }

  Future<void> _saveWalletOrder() async {
    // 保存新的顺序到 Hive
    HiveStorage().putList('wallets_data', _wallets, boxName: boxWallet);
    setState(() {
      _originalItems = List.from(_wallets);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
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
                        _isEditMode ? t.wallet.editWallet : t.wallet.selectWallet,
                        style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ),
                  ),
                  TextButton(
                    child: Text(
                      _isEditMode ? t.wallet.save : t.wallet.manage,
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
              Text(t.wallet.totalAssets, style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground)),
              IconButton(
                icon: Image.asset('assets/images/ic_wallet_exclamation.png', width: 13.w, height: 13.w),
                onPressed: () => Navigator.pop(context),
              ),
              Spacer(),
              Text('\$$_calcTotalAdderessBalance', style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
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
            child: Text('+${t.wallet.addWallet}', style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
          ),
        ),
      ],
    );
  }

  // 可拖拽列表视图
  Widget _buildDraggableList() {
    return ReorderableListView.builder(
      itemCount: _wallets.length,
      itemBuilder: (ctx, index) {
        final wallet = _wallets[index];
        return Container(
          key: ValueKey(wallet.address), // 放在 item 的最外层
          child: ReorderableDelayedDragStartListener(index: index, child: _buildDraggableView(wallet)),
        );
      },
      onReorder: (oldIndex, newIndex) async {
        setState(() {
          if (oldIndex < newIndex) newIndex--;
          final item = _wallets.removeAt(oldIndex);
          _wallets.insert(newIndex, item);
        });
        await _saveWalletOrder();
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
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.background : Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(8),
        ),
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
                  Text(
                    item.name,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  SizedBox(height: 4),
                  Text(item.balance, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
            ),
            // 右侧操作按钮
            IconButton(
              icon: Image.asset('assets/images/ic_wallet_edit.png', width: 20.h, height: 20.h),
              onPressed: () async {
                Navigator.pop(context);
                final result = await Get.to(SettingWalletPage(), arguments: item);
                if (!mounted) return;

                if (result == true) {
                  Navigator.pop(context, true);
                }
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
    final hasMnemonic = wallet.mnemonic?.isNotEmpty ?? false;
    final needsBackup = !wallet.isBackUp && hasMnemonic;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectWallet(wallet);
          Navigator.pop(context, wallet);
        });
      },
      child: Container(
        // padding: EdgeInsets.symmetric(horizontal: 12.w,vertical: 1.w),
        margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
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
                          Text(wallet.name, style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                          Text('\$${wallet.balance}', style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                        ],
                      ),
                      Spacer(),
                      // if (wallet.isBackUp)
                      needsBackup
                          ? SizedBox(
                              width: 70.w,
                              child: Material(
                                borderRadius: BorderRadius.circular(20.r),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Get.to(
                                      BackUpHelperOnePage(
                                        title: t.wallet.please_remember,
                                        prohibit: false,
                                        backupAddress: wallet.address,
                                        isBackUp: wallet.isBackUp,
                                      ),
                                      arguments: {"mnemonic": wallet.mnemonic?.join(" ")},
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(.1),
                                      border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(.3), width: 0.5),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 8.w),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ClipOval(
                                          child: ColorFiltered(
                                            colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
                                            child: Image.asset('assets/images/ic_wallet_reminder.png', width: 12.w, height: 12.w),
                                          ),
                                        ),
                                        SizedBox(width: 1.w),
                                        Expanded(
                                          child: Text(
                                            t.Mysettings.go_backup,
                                            style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.onBackground),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Text(
                        wallet.address.length > 12
                            ? '${wallet.network}:${wallet.address.substring(0, 6)}...${wallet.address.substring(wallet.address.length - 6)}'
                            : '${wallet.network}:${wallet.address}',
                        style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: wallet.address));
                        },
                        child: Icon(Icons.copy_outlined, size: 16, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ],
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
