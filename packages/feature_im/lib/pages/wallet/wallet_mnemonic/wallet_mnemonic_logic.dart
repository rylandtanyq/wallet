import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:feature_im/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';

class WalletMnemonicLogic extends GetxController {
  final wallet = AdvancedMultiChainWallet();
  late String mnemonic = "";
  late String walletAddress = "";
  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void createMnemonic() async {
    try {
      LoadingView.singleton.wrap(asyncFunction: () async {
        // 1. 初始化钱包
        await wallet.initialize(networkId: 'solana');
        // 创建新钱包
        final newWallet = await wallet.createNewWallet();
        print('New wallet created:');
        print('Mnemonic: ${newWallet['mnemonic']}');
        print('Current address: ${newWallet['currentAddress']}');
        if (newWallet['mnemonic']!.isNotEmpty && newWallet['currentAddress']!.isNotEmpty) {
          mnemonic = newWallet['mnemonic']!;
          walletAddress = newWallet['currentAddress']!;
          AppNavigator.startWalletMnemonicbackup(mnemonicStr: mnemonic, walletAddress: walletAddress);
        } else {
          IMViews.showToast(StrRes.walletMnemonicCreateError);
        }
      });
    } catch (e) {
      print('Error: $e');
      IMViews.showToast(StrRes.walletMnemonicCreateError);
    } finally {
      wallet.dispose();
    }
    //AppNavigator.startWalletMnemonicbackup();
  }
}
