import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/hive/Wallet.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/theme/app_textStyle.dart';
import 'package:untitled1/widget/wallet_avatar_smart.dart';

class SolanaSignBottomSheetFragments extends StatelessWidget {
  final Wallet wallet;
  final Map<dynamic, dynamic> network;
  final String message;
  final String dappName;

  const SolanaSignBottomSheetFragments({super.key, required this.wallet, required this.network, required this.message, this.dappName = 'wpos.pro'});

  static Future<bool?> show(
    BuildContext context, {
    required Wallet wallet,
    required Map<dynamic, dynamic> network,
    required String message,
    String dappName = 'wpos.pro',
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Material(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
            child: SolanaSignBottomSheetFragments(wallet: wallet, network: network, message: message, dappName: dappName),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部标题 + 关闭按钮
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text(t.dapp_browser.signatureInfo, style: AppTextStyles.headline3.copyWith(color: theme.colorScheme.onBackground))],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Icon(Icons.close, size: 28, color: theme.colorScheme.onBackground),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: const Color(0xFFE7E7E7), height: .5.h),

          // 内容
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.dapp_browser.requestSignature, style: AppTextStyles.headline4.copyWith(color: theme.colorScheme.onBackground)),
                SizedBox(height: 8.w),
                Text.rich(
                  t.dapp_browser.requestFromUrl.text(
                    url: TextSpan(
                      text: dappName,
                      style: AppTextStyles.labelMedium.copyWith(color: theme.colorScheme.onBackground),
                    ),
                  ),
                  style: AppTextStyles.labelMedium.copyWith(color: theme.colorScheme.onSurface),
                ),
                SizedBox(height: 16.w),

                // 消息内容区域
                Container(
                  width: double.infinity,
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
                  child: SingleChildScrollView(
                    child: Text(message, style: AppTextStyles.labelMedium.copyWith(color: theme.colorScheme.onSurface)),
                  ),
                ),
                SizedBox(height: 16.w),

                // Wallet 行
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t.dapp_browser.wallet, style: AppTextStyles.labelMedium.copyWith(color: theme.colorScheme.onSurface)),
                    Row(
                      children: [
                        WalletAvatarSmart(
                          address: wallet.address,
                          avatarImagePath: wallet.avatarImagePath,
                          size: 30,
                          radius: 30 / 2,
                          defaultAsset: 'assets/images/ic_clip_photo.png',
                        ),
                        SizedBox(width: 8.w),
                        Text(wallet.name, style: AppTextStyles.labelMedium.copyWith(color: theme.colorScheme.onBackground)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.w),

                // Network 行
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t.dapp_browser.network, style: AppTextStyles.labelMedium.copyWith(color: theme.colorScheme.onSurface)),
                    Row(
                      children: [
                        if (network["path"] != null) Image.asset(network["path"], width: 20, height: 20),
                        SizedBox(width: 8.w),
                        Text(network["id"]?.toString() ?? '', style: AppTextStyles.labelMedium.copyWith(color: theme.colorScheme.onBackground)),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 20.w),

                // 按钮行
                Row(
                  children: [
                    // 取消
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: Container(
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: theme.colorScheme.onBackground),
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          child: Text(t.dapp_browser.cancel, style: AppTextStyles.headline4.copyWith(color: theme.colorScheme.onBackground)),
                        ),
                      ),
                    ),
                    SizedBox(width: 30.w),

                    // 签名
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(true),
                        child: Container(
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(50.r)),
                          child: Text(t.dapp_browser.sign, style: AppTextStyles.headline4.copyWith(color: theme.colorScheme.onPrimary)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
