import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/constants/hive_boxes.dart';
import 'package:untitled1/core/AdvancedMultiChainWallet.dart';
import 'package:untitled1/entity/BackUpEntity.dart';
import 'package:untitled1/hive/Wallet.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/main.dart';
import 'package:untitled1/widget/CustomAppBar.dart';
import 'package:untitled1/theme/app_textStyle.dart';
import '../../base/base_page.dart';
import '../util/HiveStorage.dart';

/*
 * 验证备份助记词。
 */
class BackUpHelperVerifyPage extends StatefulWidget {
  const BackUpHelperVerifyPage({super.key});

  @override
  State<StatefulWidget> createState() => _BackUpHelperVerifyPageState();
}

class _BackUpHelperVerifyPageState extends State<BackUpHelperVerifyPage> with BasePage<BackUpHelperVerifyPage>, AutomaticKeepAliveClientMixin {
  bool isSelected = true;

  int _selectedIndex = 0;
  List<String> mnemonics = [];
  List<String> _orderlyMnemonics = [];
  final List<BackUp> randomMnemonics = [];
  List<int> verifyPosition = [];
  String address = '';
  String privateKey = '';
  String network = '';

  @override
  void initState() {
    super.initState();
    final random = Random();
    final range = List.generate(12, (i) => i + 1); // 生成1到12的数字列表
    range.shuffle(random); // 打乱顺序
    verifyPosition = range.take(3).toList();
    randomMnemonics.add(
      BackUp(
        name: t.wallet.verifyWordPosition(index: range[0]),
        value: "",
      ),
    );
    randomMnemonics.add(
      BackUp(
        name: t.wallet.verifyWordPosition(index: range[1]),
        value: "",
      ),
    );
    randomMnemonics.add(
      BackUp(
        name: t.wallet.verifyWordPosition(index: range[2]),
        value: "",
      ),
    );
    final newWallet = Get.arguments;
    address = newWallet['currentAddress'] ?? '';
    privateKey = newWallet['privateKey'] ?? '';
    network = newWallet['currentNetwork'] ?? '';
    print('init --address:${address}');
    print('init --privateKey:${privateKey}');
    print('init --network:${network}');
    String mnemonic = newWallet['mnemonic'];
    mnemonics = mnemonic.split(' ');
    _orderlyMnemonics = List.from(mnemonics);
    mnemonics.shuffle(random);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: CustomAppBar(title: t.wallet.backupMnemonic),
      body: Container(
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
                  Text(t.wallet.verifyMnemonic, style: AppTextStyles.headline1.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                  SizedBox(height: 10),
                  Text(t.wallet.verifyMnemonicTip, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                  SizedBox(height: 10),
                ],
              ),
            ),

            LayoutBuilder(
              builder: (context, constraints) {
                final rowCount = (randomMnemonics.length / 3).ceil();
                const itemHeight = 60.0;

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  height:
                      rowCount * itemHeight + // 所有行高度
                      (rowCount - 1) * 24 + // 行间距
                      8, // 底部额外空间
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: randomMnemonics.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIndex == index;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              randomMnemonics[index].name,
                              style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onBackground),
                              // textAlign: TextAlign.center,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _selectedIndex = index),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 10.w),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                                  width: 1,
                                ),
                              ),
                              child: Center(child: Text(randomMnemonics[index].value)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),

            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 20.h),
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                    mainAxisExtent: 44.h,
                  ),
                  itemCount: mnemonics.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => {
                        setState(() {
                          randomMnemonics[_selectedIndex].value = mnemonics[index];
                          for (var i = 0; i < randomMnemonics.length; i++) {
                            if (randomMnemonics[i].value == mnemonics[index]) {
                              //把已存在的助记词设置成不可点击
                              // mnemonics[i].isSelected = true;
                            }
                            if (randomMnemonics[i].value.isEmpty) {
                              _selectedIndex = i;
                              break;
                            }
                          }
                        }),
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Center(
                          child: Text(mnemonics[index], style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

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
                onPressed: () => {
                  // Get.off(),
                  verifyMnemonic(_orderlyMnemonics),
                },
                child: Text(
                  '确认',
                  style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void verifyMnemonic(List<String> orderlyMnemonics) async {
    showLoadingDialog();
    List<String> values = randomMnemonics.map((e) => e.value).toList();
    final advWallet = AdvancedMultiChainWallet();
    await advWallet.initialize();
    String mnemonicStr = values.join(' ');
    print('选中的助记词: $mnemonicStr');
    final isVerifySuccess = await advWallet.verifyMnemonicByRandomPositions(verifyPosition, mnemonicStr) == true;
    print('验证是否通过: ${isVerifySuccess}');
    if (!isVerifySuccess) {
      Fluttertoast.showToast(msg: '助记词验证失败,请选择正确的助记词');
    } else {
      // final balance = await advWallet.getNativeBalanceByAddress(blockchain: network,address: address);
      // print('\nNative balance:${balance}');
      List<Wallet> _wallets = await HiveStorage().getList<Wallet>('wallets_data', boxName: 'boxWallet') ?? [];
      final name = _wallets.isEmpty ? '我的钱包' : '我的钱包(${_wallets.length})';
      final walletEntity = Wallet(
        name: name,
        balance: '0.00',
        network: network,
        address: address,
        privateKey: privateKey,
        isBackUp: true,
        mnemonic: orderlyMnemonics,
      );
      // debugPrint('新存入的钱包信息$walletEntity');
      await HiveStorage().putObject<Wallet>('currentSelectWallet', walletEntity, boxName: boxWallet);
      await HiveStorage().putValue('selected_address', address, boxName: boxWallet);

      _wallets.add(walletEntity);
      await HiveStorage().putList<Wallet>('wallets_data', _wallets, boxName: boxWallet);
      // print('currentSelectWallet:${HiveStorage().getObject('currentSelectWallet').toString()}');
      dismissLoading();
      Get.offAll(() => MainPage(initialPageIndex: 4));
    }
  }

  @override
  bool get wantKeepAlive => true;
}
