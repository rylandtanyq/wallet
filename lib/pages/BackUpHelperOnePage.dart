import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:untitled1/constants/app_colors.dart';
import 'package:untitled1/constants/hive_boxes.dart';
import 'package:untitled1/hive/Wallet.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/pages/wallet_page/index.dart';
import 'package:untitled1/util/HiveStorage.dart';
import 'package:untitled1/widget/CustomAppBar.dart';
import 'package:untitled1/theme/app_textStyle.dart';

import '../../base/base_page.dart';
import 'BackUpHelperVerifyPage.dart';

/*
 * 备份助记词
 */
class BackUpHelperOnePage extends StatefulWidget {
  final String? title;
  final bool? prohibit;
  final String? backupAddress;
  final bool? isBackUp;
  const BackUpHelperOnePage({super.key, this.title, this.prohibit = true, this.backupAddress, this.isBackUp});

  @override
  State<StatefulWidget> createState() => _BackUpHelperOnePageState();
}

class _BackUpHelperOnePageState extends State<BackUpHelperOnePage> with BasePage<BackUpHelperOnePage>, AutomaticKeepAliveClientMixin {
  bool isSelected = true;

  bool _showBlur = true; // 控制模糊层显示

  // 模拟数据, 接受上一个页面传递的助记词、私钥、钱包地址、当前的网络(例如Eth)
  late List<String> mnemonics;

  List<Wallet> _wallets = [];

  @override
  void initState() {
    super.initState();
    final newWallet = Get.arguments;
    String mnemonic = newWallet['mnemonic'];
    mnemonics = mnemonic.split(' ');
  }

  Future<void> oneClickBackup() async {
    if (widget.prohibit == false) {
      final addrRaw = widget.backupAddress ?? '';
      final addr = addrRaw.trim();
      if (addr.isEmpty) {
        Get.snackbar(t.wallet.tip, t.wallet.no_wallet_address_to_backup);
        return;
      }

      // 读取列表
      final wallets = await HiveStorage().getList<Wallet>('wallets_data', boxName: boxWallet) ?? <Wallet>[];

      // 先忽略大小写找（适合 EVM），找不到再精确匹配（兼容 Solana）
      int idx = wallets.indexWhere((e) => e.address.toLowerCase() == addr.toLowerCase());
      if (idx == -1) {
        idx = wallets.indexWhere((e) => e.address == addr);
      }

      if (idx == -1) {
        Get.snackbar(t.wallet.tip, t.wallet.wallet_address_not_found_local);
        return;
      }

      // 标记列表
      if (!wallets[idx].isBackUp) {
        wallets[idx].isBackUp = true;
        await HiveStorage().putList<Wallet>('wallets_data', wallets, boxName: boxWallet);
      }

      // 同步 currentSelectWallet
      final current = await HiveStorage().getObject<Wallet>('currentSelectWallet', boxName: boxWallet);
      if (current != null) {
        final same = current.address.toLowerCase() == addr.toLowerCase() || current.address == addr;
        if (same && !current.isBackUp) {
          current.isBackUp = true;
          await HiveStorage().putObject<Wallet>('currentSelectWallet', current, boxName: boxWallet);
        }
      }

      Get.closeAllSnackbars();
      Get.snackbar(t.wallet.success, t.wallet.marked_as_backed_up);

      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.key.currentState?.canPop() ?? false) {
          Get.back(result: true);
        } else {
          // 如果不是 Get.to 进来的，没有上一页可返回
          Get.offAll(() => WalletPage());
        }
      });
    } else {
      // 去助记词验证页
      final _ = await Get.to(() => BackUpHelperVerifyPage(), arguments: Get.arguments);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: CustomAppBar(title: ''),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.background,
          padding: EdgeInsets.only(bottom: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部说明区域（非模糊部分）
              Container(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title ?? t.wallet.rememberBeforeBackupExclaim,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      children: [
                        _buildTipItem(t.wallet.handwriteRecommended, true),
                        SizedBox(width: 20),
                        _buildTipItem(t.wallet.doNotCopy, false),
                        SizedBox(width: 20),
                        _buildTipItem(t.wallet.doNotScreenshot, false),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),

              // 动态高度的GridView + 模糊层
              Expanded(
                // 用Expanded让GridView自适应高度
                child: Stack(
                  children: [
                    // 底层GridView
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // 计算每个item高度（文本高度+padding），如40
                        double itemHeight = 40.w;
                        int rowCount = (mnemonics.length / 2).ceil();
                        double gridHeight = itemHeight * rowCount - 10; // 额外padding
                        bool needScroll = gridHeight > constraints.maxHeight;
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          height: needScroll ? null : gridHeight,
                          child: GridView.builder(
                            physics: needScroll ? ScrollPhysics() : NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.all(15.w),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 5,
                            ),
                            itemCount: mnemonics.length,
                            itemBuilder: (context, index) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '${index + 1}',
                                    style: TextStyle(fontSize: 14.sp, color: AppColors.color_909090),
                                  ),
                                  SizedBox(width: 15.w),
                                  Text(mnemonics[index], style: TextStyle(fontSize: 14.sp)),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),

                    // 高斯模糊层
                    if (_showBlur) ...[
                      Positioned.fill(
                        child: ClipRect(
                          // 确保模糊不溢出GridView
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                            child: Container(
                              color: Colors.black.withOpacity(0.3),
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: () => setState(() => _showBlur = false),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Image.asset('assets/images/ic_wallet_un_eye.png', width: 42.w, height: 34.h),
                                    ColorFiltered(
                                      colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
                                      child: Image.asset('assets/images/ic_wallet_un_eye.png', width: 42.w, height: 34.h),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      t.wallet.clickToViewMnemonic,
                                      style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.background,
                    minimumSize: Size(double.infinity, 42.h),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    textStyle: TextStyle(fontSize: 18.sp),
                  ),
                  onPressed: () => oneClickBackup(),
                  child: Text(
                    widget.prohibit! == false ? t.wallet.one_click_backup : t.wallet.backupMnemonic,
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String text, bool isChecked) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(isChecked ? 'assets/images/ic_wallet_new_work_selected.png' : 'assets/images/ic_wallet_unselected.png', width: 13, height: 10),
        SizedBox(width: 4),
        Text(text, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
