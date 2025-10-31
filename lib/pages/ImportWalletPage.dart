import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/constants/hive_boxes.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/widget/CustomAppBar.dart';
import 'package:untitled1/widget/CustomTextField.dart';
import 'package:untitled1/theme/app_textStyle.dart';

import '../../base/base_page.dart';
import '../core/AdvancedMultiChainWallet.dart';
import '../util/HiveStorage.dart';
import '../hive/Wallet.dart';
import '../main.dart';
import '../util/CryptoInputValidator.dart';
import 'BackUpHelperOnePage.dart';

/*
 * 导入钱包
 */
class ImportWalletPage extends StatefulWidget {
  const ImportWalletPage({super.key});

  @override
  State<StatefulWidget> createState() => _ImportWalletPageState();
}

class _ImportWalletPageState extends State<ImportWalletPage> with BasePage<ImportWalletPage>, AutomaticKeepAliveClientMixin {
  String _importKeyValue = '';
  final TextEditingController _textController = TextEditingController();
  bool isSelected = true;
  final _advWallet = AdvancedMultiChainWallet();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        actions: [
          IconButton(
            icon: Image.asset('assets/images/ic_wallet_exclamation.png', width: 17.w, height: 17.w),
            onPressed: () => {setState(() {})},
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        padding: EdgeInsets.only(bottom: 20.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.wallet.enterMnemonicOrPrivateKey,
                      style: AppTextStyles.headline1.copyWith(color: Theme.of(context).colorScheme.onBackground),
                    ),
                    SizedBox(height: 10.h),
                    Text(t.wallet.mnemonicHint, style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                    SizedBox(height: 10.h),
                    Stack(
                      children: [
                        CustomTextField(
                          hintText: t.wallet.pleaseEnterContent,
                          controller: _textController,
                          minLines: 5,
                          onChanged: (text) {
                            setState(() {
                              _importKeyValue = text;
                            });
                          },
                        ),
                        Positioned(
                          right: 12.w,
                          bottom: 16.h,
                          child: Image.asset('assets/images/ic_wallet_import_scan.png', width: 30.5.w, height: 30.5.w),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.all(15.w),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          minimumSize: Size(double.infinity, 44.h),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          textStyle: TextStyle(fontSize: 18.sp),
                        ),
                        onPressed: () => {importWallet(_importKeyValue)},
                        child: Text(t.wallet.confirmImport, style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
                      ),
                    ),
                    Text(t.wallet.notice, style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 6.h,
                          color: Theme.of(context).colorScheme.surface, // #6F7470 颜色
                        ),
                        SizedBox(width: 11.w),
                        Flexible(
                          child: Text(t.wallet.securityWarning, style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 6.h,
                          color: Color(0xFFA3ADAD), // #6F7470 颜色
                        ),
                        SizedBox(width: 11.w),
                        Flexible(
                          child: Text(t.wallet.safetyAdvice, style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> importWallet(String input) async {
    showLoadingDialog();
    await _advWallet.initialize();
    if (CryptoInputValidator.isMnemonic(input)) {
      print('importWallet --- 助记词导入');
      await importWalletByMnemonic(input);
      debugPrint('input: $input');
    } else if (CryptoInputValidator.isPrivateKey(input)) {
      print('importWallet --- 私钥导入');
      await importWalletByPrivateKey();
    }
    dismissLoading();
    Get.offAll(() => MainPage(initialPageIndex: 4));
  }

  /*
   * 私钥导入
   */
  Future<void> importWalletByPrivateKey() async {
    final wallet = await _advWallet.importWalletFromPrivateKey(_importKeyValue);
    final currentAddress = wallet['currentAddress'];
    List<Wallet> _wallets = await HiveStorage().getList<Wallet>('wallets_data', boxName: boxWallet) ?? [];
    bool exists = _wallets.any((item) => item.address == currentAddress);
    if (!exists) {
      // 创建新钱包对象
      final newWallet = Wallet(
        name: _wallets.isEmpty ? '我的钱包' : '我的钱包(${_wallets.length + 1})',
        balance: wallet['balance'] ?? '0.00', // 默认余额或从 wallet 中获取
        network: wallet['currentNetwork'] ?? 'Ethereum',
        address: currentAddress ?? '',
        privateKey: _importKeyValue,
        isBackUp: true,
      );
      // 保存回 Hive
      await HiveStorage().putObject('currentSelectWallet', newWallet, boxName: boxWallet);
      await HiveStorage().putValue('selected_address', currentAddress, boxName: boxWallet);
      _wallets.add(newWallet);
      await HiveStorage().putList('wallets_data', _wallets, boxName: boxWallet);
      print('新钱包已添加: ${newWallet.address}');
    } else {
      Fluttertoast.showToast(msg: '钱包已存在，未添加: $currentAddress');
      print('钱包已存在，未添加: $currentAddress');
    }
  }

  /*
   * 助记词导入
   * TODO: 需要弹出选择网络弹窗
   */
  Future<void> importWalletByMnemonic(String mnemonicString) async {
    final wallet = await _advWallet.restoreFromMnemonic(_importKeyValue);
    List<Wallet> _wallets = await HiveStorage().getList<Wallet>('wallets_data', boxName: boxWallet) ?? [];
    final List<String> mnemonic = mnemonicString.trim().split(' ');
    final currentAddress = wallet['currentAddress'];
    bool exists = _wallets.any((item) => item.address == currentAddress);
    if (!exists) {
      // 创建新钱包对象
      final newWallet = Wallet(
        name: _wallets.isEmpty ? '我的钱包' : '我的钱包(${_wallets.length + 1})',
        balance: wallet['balance'] ?? '0.00',
        network: wallet['network'] ?? 'Ethereum',
        address: currentAddress ?? '',
        privateKey: wallet['privateKey'] ?? '',
        isBackUp: false,
        mnemonic: mnemonic,
      );
      // 保存回 Hive
      await HiveStorage().putObject('currentSelectWallet', newWallet, boxName: boxWallet);
      await HiveStorage().putValue('selected_address', currentAddress, boxName: boxWallet);
      await HiveStorage().putValue('currentSelectWallet_mnemonic', mnemonic.join(" "));
      _wallets.add(newWallet);
      await HiveStorage().putList('wallets_data', _wallets, boxName: boxWallet);
      debugPrint('新钱包已添加: ${newWallet.address}');
    } else {
      // 钱包已存在，不添加
      Fluttertoast.showToast(msg: '钱包已存在，未添加: $currentAddress');
      debugPrint('钱包已存在，未添加: $currentAddress');
    }
  }

  @override
  bool get wantKeepAlive => true;
}
