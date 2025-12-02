import 'package:feature_wallet/hive/Wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_ui/widget/base_page.dart';
import 'package:shared_utils/app_routes.dart';
import 'package:shared_utils/hive_storage.dart';
import 'package:shared_utils/constants/app_value_notifier.dart';
import 'package:shared_utils/hive_boxes.dart';
import 'package:feature_wallet/i18n/strings.g.dart';
import 'package:shared_ui/widget/custom_appbar.dart';
import 'package:shared_ui/widget/custom_text_field.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'package:shared_utils/crypto_input_validator.dart';
import '../core/AdvancedMultiChainWallet.dart';

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
    bool success = false;

    try {
      showLoadingDialog();
      await _advWallet.initialize(networkId: 'solana');

      final cleaned = input.trim();
      _importKeyValue = cleaned;

      if (CryptoInputValidator.isMnemonic(cleaned)) {
        await importWalletByMnemonic(cleaned);
        success = true;
      } else {
        try {
          await importWalletByPrivateKey();
          success = true;
        } catch (_) {
          Fluttertoast.showToast(msg: '输入既不是助记词也不是私钥');
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '导入失败：$e');
    } finally {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (success) {
        OneShotFlag.value.value = true;
        Get.offAllNamed(AppRoutes.main, arguments: {'initialPageIndex': 4, 'refresh': true});
      }
    }
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
        network: wallet['currentNetwork'] ?? 'Solana',
        address: currentAddress ?? '',
        privateKey: _importKeyValue,
        isBackUp: true,
      );
      // 保存回 Hive
      await HiveStorage().putObject('currentSelectWallet', newWallet, boxName: boxWallet);
      await HiveStorage().putValue('selected_address', currentAddress, boxName: boxWallet);
      _wallets.add(newWallet);
      await HiveStorage().putList('wallets_data', _wallets, boxName: boxWallet);
      debugPrint('新钱包已添加: ${newWallet.address}');
    } else {
      Fluttertoast.showToast(msg: '钱包已存在，未添加: $currentAddress');
      debugPrint('钱包已存在，未添加: $currentAddress');
    }
  }

  /*
   * 助记词导入
   * TODO: 需要弹出选择网络弹窗
   */
  Future<void> importWalletByMnemonic(String mnemonicString) async {
    // 统一空格：连在一起的空白全部压成一个空格
    final normalizedMnemonic = mnemonicString.trim().replaceAll(RegExp(r'\s+'), ' ');

    // 这里不要再用 _importKeyValue 了，直接用当前这次的助记词
    final wallet = await _advWallet.restoreFromMnemonic(normalizedMnemonic);

    List<Wallet> wallets = await HiveStorage().getList<Wallet>('wallets_data', boxName: boxWallet) ?? [];

    final List<String> mnemonic = normalizedMnemonic.split(' ');
    final currentAddress = (wallet['currentAddress'] as String? ?? '').trim();
    if (currentAddress.isEmpty) {
      Fluttertoast.showToast(msg: '导入失败：地址为空');
      return;
    }

    final exists = wallets.any((w) => w.address == currentAddress);
    if (!exists) {
      final newWallet = Wallet(
        name: wallets.isEmpty ? '我的钱包' : '我的钱包(${wallets.length + 1})',
        balance: wallet['balance'] ?? '0.00',
        network: wallet['network'] ?? 'Solana',
        address: currentAddress,
        privateKey: wallet['privateKey'] ?? '',
        isBackUp: false,
        mnemonic: mnemonic,
      );

      // 先写当前选中 + 地址
      await HiveStorage().putObject('currentSelectWallet', newWallet, boxName: boxWallet);
      await HiveStorage().putValue('selected_address', currentAddress, boxName: boxWallet);
      await HiveStorage().putValue('currentSelectWallet_mnemonic', mnemonic.join(' '));

      wallets.add(newWallet);
      await HiveStorage().putList('wallets_data', wallets, boxName: boxWallet);

      debugPrint('新钱包已添加: ${newWallet.address}');
    } else {
      Fluttertoast.showToast(msg: '钱包已存在，未添加: $currentAddress');
      debugPrint('钱包已存在，未添加: $currentAddress');
    }
  }

  @override
  bool get wantKeepAlive => true;
}
