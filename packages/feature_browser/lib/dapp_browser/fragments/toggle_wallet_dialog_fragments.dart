import 'package:feature_wallet/hive/Wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'package:shared_ui/widget/wallet_avatar_smart.dart';
import 'package:shared_utils/format_solana_address.dart';
import 'package:shared_utils/hive_boxes.dart';
import 'package:shared_utils/hive_storage.dart';

class ToggleWalletDialogFragments extends StatefulWidget {
  const ToggleWalletDialogFragments({super.key});

  @override
  State<ToggleWalletDialogFragments> createState() => _ToggleWalletDialogFragmentsState();

  static Future<Wallet?> show(BuildContext context) async {
    return showModalBottomSheet<Wallet>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Material(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
            child: ToggleWalletDialogFragments(),
          ),
        );
      },
    );
  }
}

class _ToggleWalletDialogFragmentsState extends State<ToggleWalletDialogFragments> {
  List<Wallet> _wallets = [];
  String? _selectedWalletAddress;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    final wallets = await HiveStorage().getList<Wallet>('wallets_data', boxName: boxWallet) ?? [];
    final selectedAddress = await HiveStorage().getValue<String>('selected_address', boxName: boxWallet) ?? '';

    if (!mounted) return;
    setState(() {
      _wallets = wallets;
      _selectedWalletAddress = selectedAddress;
    });
  }

  Future<void> _selectWallet(Wallet wallet) async {
    await HiveStorage().putValue('selected_address', wallet.address, boxName: boxWallet);
    await HiveStorage().putObject('currentSelectWallet', wallet, boxName: boxWallet);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("选择钱包", style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
            SizedBox(height: 10.h),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _wallets.length,
              itemBuilder: (BuildContext context, int index) {
                Wallet item = _wallets[index];
                final isSelected = _selectedWalletAddress == item.address;
                return ListTile(
                  onTap: () async {
                    await _selectWallet(item);
                    if (!mounted) return;
                    Navigator.pop(context, item);
                  },
                  minVerticalPadding: 0,
                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  leading: WalletAvatarSmart(address: item.address, avatarImagePath: item.avatarImagePath, size: 37.5.w),
                  title: Text(item.name, style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                  subtitle: Text(
                    formatSolanaAddress(item.address),
                    style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onBackground),
                  ),
                  trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.onBackground) : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
