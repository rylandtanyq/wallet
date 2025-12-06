import 'package:feature_browser/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:feature_wallet/hive/Wallet.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'package:shared_ui/widget/wallet_avatar_smart.dart';

class SolanaContractInteractionFragments extends StatelessWidget {
  final Map<dynamic, dynamic> txPreview;
  final Wallet wallet;
  final String dappUrl;
  const SolanaContractInteractionFragments({super.key, required this.txPreview, required this.wallet, required this.dappUrl});

  static Future<bool?> show(BuildContext context, {required Map<dynamic, dynamic> txPreview, required Wallet wallet, required String dappUrl}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Material(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
            child: SolanaContractInteractionFragments(txPreview: txPreview, wallet: wallet, dappUrl: dappUrl),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('txPreview: $txPreview');

    final programId = txPreview['programId']?.toString() ?? 'Unknown Program';
    final feePayer = txPreview['feePayer']?.toString() ?? '';

    // 从 preview 里拿数据
    final num? feeLamportsRaw = txPreview['feeLamports'] as num?;
    final num? walletBalanceRaw = txPreview['walletBalanceLamports'] as num?;
    final instructionCount = (txPreview['instructionCount'] as num?)?.toInt() ?? 0;

    // 没拿到就用 5000 lamports 兜底（Solana base fee）
    const int kBaseFeeLamports = 5000;
    final int feeLamports = (feeLamportsRaw ?? kBaseFeeLamports).toInt();

    // 余额直接用 JS 传来的 lamports
    final int? walletBalanceLamports = walletBalanceRaw?.toInt();

    // 如果暂时不算 ATA / 账户租金，就先不加：required = 纯网络 fee
    final int requiredLamports = feeLamports;

    final bool gasEnough = walletBalanceLamports != null && walletBalanceLamports >= requiredLamports;

    final double feeSol = feeLamports / 1e9;
    final double? walletSol = walletBalanceLamports != null ? walletBalanceLamports / 1e9 : null;

    debugPrint(
      'feeLamports=$feeLamports, wallet=$walletBalanceLamports, '
      'required=$requiredLamports, gasEnough=$gasEnough',
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 40.h,
                  alignment: Alignment.center,
                  child: Text(
                    t.dapp_browser.contractInteraction,
                    style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 10,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
              ],
            ),
            Divider(height: .5, color: Theme.of(context).colorScheme.onSurface.withOpacity(.3)),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.dapp_browser.requestContractInteraction,
                    style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground),
                  ),
                  SizedBox(height: 8.w),
                  Text.rich(
                    t.dapp_browser.requestFromUrl.text(
                      url: TextSpan(
                        text: dappUrl,
                        style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ),
                    style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  SizedBox(height: 8.w),
                  Text(
                    "${t.dapp_browser.recipient}: $programId",
                    style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(.7)),
                  ),
                  if (feePayer.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      "${t.dapp_browser.sender}: $feePayer",
                      style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(.7)),
                    ),
                  ],
                  if (instructionCount > 0) ...[
                    SizedBox(height: 4),
                    Text(
                      "${t.dapp_browser.amount}: $instructionCount",
                      style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(.7)),
                    ),
                  ],
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.05),
                border: Border(
                  top: BorderSide(width: .5, color: Theme.of(context).colorScheme.onSurface.withOpacity(.3)),
                  bottom: BorderSide(width: .5, color: Theme.of(context).colorScheme.onSurface.withOpacity(.3)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(.2),
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    child: Icon(Icons.event_note, color: Theme.of(context).colorScheme.onBackground),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(dappUrl, style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t.dapp_browser.wallet, style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WalletAvatarSmart(
                            address: wallet.address,
                            avatarImagePath: wallet.avatarImagePath,
                            size: 30,
                            radius: 30 / 2,
                            defaultAsset: 'assets/images/ic_clip_photo.png',
                          ),
                          SizedBox(width: 6),
                          Text(wallet.name, style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t.dapp_browser.network, style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      Text(wallet.network, style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t.dapp_browser.estimatedGasFee, style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      Text(
                        feeSol != null ? "${feeSol.toStringAsFixed(6)} SOL" : t.dapp_browser.estimating,
                        style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ],
                  ),
                  if (walletSol != null) ...[
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t.dapp_browser.currentBalance, style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                        Text(
                          "${walletSol.toStringAsFixed(6)} SOL",
                          style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onBackground),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            if (!gasEnough)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.error.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.dapp_browser.insufficientGasFeeDetail,
                          style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 12),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        height: 44.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Theme.of(context).colorScheme.onBackground),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          t.dapp_browser.transaction,
                          style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: gasEnough ? () => Navigator.of(context).pop(true) : null,
                      child: Opacity(
                        opacity: gasEnough ? 1.0 : 0.4,
                        child: Container(
                          height: 44.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(50)),
                          child: Text(
                            gasEnough ? t.dapp_browser.transaction : t.dapp_browser.insufficientGas,
                            style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
