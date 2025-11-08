import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/widget/CustomAppBar.dart';
import 'package:untitled1/theme/app_textStyle.dart';

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

class _BackUpHelperPageState extends State<BackUpHelperPage> with BasePage<BackUpHelperPage>, AutomaticKeepAliveClientMixin {
  bool isSelected = true;
  final wallet = AdvancedMultiChainWallet();

  @override
  void initState() {
    super.initState();
    _createWallet();
  }

  /// 创建钱包
  void _createWallet() async {
    await wallet.initialize(networkId: "solana");
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: CustomAppBar(title: ''),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Container(
                  color: Theme.of(context).colorScheme.background,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.wallet.rememberBeforeBackup,
                              style: AppTextStyles.headline1.copyWith(color: Theme.of(context).colorScheme.onBackground),
                            ),
                            SizedBox(height: 10.h),
                            Wrap(
                              children: [
                                Row(
                                  children: [
                                    Image.asset('assets/images/ic_wallet_new_work_selected.png', width: 13.w, height: 10.h),
                                    SizedBox(width: 3.5.w),
                                    Text(
                                      t.wallet.handwriteRecommended,
                                      style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface),
                                    ),
                                    SizedBox(width: 20.w),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Image.asset('assets/images/ic_wallet_unselected.png', width: 10.w, height: 10.h),
                                    SizedBox(width: 3.5.w),
                                    Text(
                                      t.wallet.doNotCopy,
                                      style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface),
                                    ),
                                    SizedBox(width: 20.w),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Image.asset('assets/images/ic_wallet_unselected.png', width: 10.w, height: 10.h),
                                    SizedBox(width: 3.5.w),
                                    Text(
                                      t.wallet.doNotScreenshot,
                                      style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface),
                                    ),
                                    SizedBox(width: 20.w),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            _buildSuggestView('assets/images/ic_wallet_backup1.png', t.wallet.mnemonicIsPassword, t.wallet.mnemonicEqualsOwnership),
                            _buildSuggestView('assets/images/ic_wallet_backup2.png', t.wallet.handwriteOrColdWallet, t.wallet.copyOrScreenshotRisk),
                            _buildSuggestView('assets/images/ic_wallet_backup3.png', t.wallet.storeMnemonicSafely, t.wallet.lossIsIrrecoverable),
                          ],
                        ),
                      ),

                      /// 同意条款
                      Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                isSelected = value!;
                              });
                            },
                            shape: CircleBorder(),
                            fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                              if (states.contains(MaterialState.selected)) {
                                return Theme.of(context).colorScheme.primary;
                              }
                              return Colors.transparent;
                            }),
                          ),
                          Flexible(
                            child: Text(
                              t.wallet.personalResponsibility,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12.sp),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// 按钮
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
                onPressed: () => {createWalletToBackUp()},
                child: Text(
                  t.wallet.backupMnemonic,
                  style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestView(String icon, String title, String subTitle) {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      child: Row(
        children: [
          Image.asset(icon, width: 30.5.w, height: 45.h),
          SizedBox(width: 12.w),

          // 主副标题
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                SizedBox(height: 2.h),
                Text(subTitle, style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 备份助记词, 此处已创建钱包并生成助记词
  void createWalletToBackUp() async {
    showLoadingDialog();
    final walletData = await wallet.createNewWallet();
    debugPrint('New wallet created:');
    debugPrint('Mnemonic: ${walletData['mnemonic']}');
    debugPrint('privateKey: ${walletData['privateKey']}');
    debugPrint('Current address: ${walletData['currentAddress']}');
    debugPrint('currentNetwork: ${walletData['currentNetwork']}');
    dismissLoading();
    // 跳转备份助记词页面, 并将创建的Mnemonic(助记词)、privateKey(私钥)、currentAddress(当前地址)、currentNetwork(当前网络)转递到下一个页面
    Get.off(BackUpHelperOnePage(), arguments: walletData);
  }

  // 创建钱包, 并生成助记词
  // Future<Map<String, String>> createWallet() async {
  //   final newWallet = await wallet.createNewWallet();
  //   print('New wallet created:');
  //   print('Mnemonic: ${newWallet['mnemonic']}');
  //   print('privateKey: ${newWallet['privateKey']}');
  //   print('Current address: ${newWallet['currentAddress']}');
  //   print('currentNetwork: ${newWallet['currentNetwork']}');
  //   return newWallet;
  // }

  @override
  bool get wantKeepAlive => true;
}
