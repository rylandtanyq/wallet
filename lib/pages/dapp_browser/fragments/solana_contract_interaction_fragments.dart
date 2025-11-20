import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/hive/Wallet.dart';
import 'package:untitled1/theme/app_textStyle.dart';
import 'package:untitled1/widget/wallet_avatar_smart.dart';

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
    final feeLamports = (txPreview['feeLamports'] as num?)?.toInt();
    final walletBalanceLamports = (txPreview['walletBalanceLamports'] as num?)?.toInt();
    final instructionCount = (txPreview['instructionCount'] as num?)?.toInt() ?? 0;

    final feeSol = feeLamports != null ? feeLamports / 1e9 : null;
    final walletSol = walletBalanceLamports != null ? walletBalanceLamports / 1e9 : null;

    // 判断 Gas 是否足够
    bool gasEnough = true;
    if (feeLamports != null) {
      // 确保余额字段不为空
      if (walletBalanceLamports == null) {
        gasEnough = false;
      } else {
        // 余额 < 预估 fee
        gasEnough = walletBalanceLamports >= (feeLamports * 1.5);
      }
    } else {
      // fee 估不出来, 暂时放行
      gasEnough = true; // 暂时先放行
    }

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
                  child: Text("合约交互", style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
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
                  Text("请求合约交互", style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                  SizedBox(height: 8.w),
                  Text.rich(
                    TextSpan(
                      text: "来自 ",
                      style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                      children: [
                        TextSpan(
                          text: dappUrl,
                          style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onBackground),
                        ),
                        TextSpan(
                          text: " 的请求",
                          style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.w),
                  Text(
                    "Program: $programId",
                    style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(.7)),
                  ),
                  if (feePayer.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      "Fee Payer: $feePayer",
                      style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(.7)),
                    ),
                  ],
                  if (instructionCount > 0) ...[
                    SizedBox(height: 4),
                    Text(
                      "指令数量: $instructionCount",
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
                    child: Text("Wpos.pro", style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
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
                      Text("Wallet", style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onSurface)),
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
                      Text("Network", style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      Text(wallet.network, style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("预估 Gas 费", style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      Text(
                        feeSol != null ? "${feeSol.toStringAsFixed(6)} SOL" : "估算中...",
                        style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ],
                  ),
                  if (walletSol != null) ...[
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("当前余额", style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onSurface)),
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
                          "Gas费不足，无法完成交易，请先充值少量 SOL 再重试。",
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
                        child: Text("取消", style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
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
                            gasEnough ? "交易" : "Gas不足",
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
