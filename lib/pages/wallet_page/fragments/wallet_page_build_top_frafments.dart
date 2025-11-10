import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:untitled1/hive/Wallet.dart';
import 'package:untitled1/hive/tokens.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/pages/BackUpHelperOnePage.dart';
import 'package:untitled1/pages/SelectTransferCoinTypePage.dart';
import 'package:untitled1/pages/SelectedPayeePage.dart';
import 'package:untitled1/pages/transaction_history.dart';
import 'package:untitled1/pages/wallet_page/fragments/wallet_page_action_fragments.dart';
import 'package:untitled1/theme/app_textStyle.dart';

class WalletPageBuildTopFrafments extends StatefulWidget {
  final Wallet wallet;
  final List<Tokens> fillteredTokensList;
  final WalletActions actions;
  const WalletPageBuildTopFrafments({super.key, required this.wallet, required this.fillteredTokensList, required this.actions});

  @override
  State<WalletPageBuildTopFrafments> createState() => _WalletPageBuildTopFrafmentsState();
}

class _WalletPageBuildTopFrafmentsState extends State<WalletPageBuildTopFrafments> {
  final List<String> titles = [t.home.transfer, t.home.receive, t.home.finance, t.home.getGas, t.home.transaction_history];
  final List<Widget> _navIcons = [
    Image.asset('assets/images/ic_wallet_transfer.png', width: 48.w, height: 48.w),
    Image.asset('assets/images/ic_home_grid_collection.png', width: 48.w, height: 48.w),
    Image.asset('assets/images/ic_wallet_finance.png', width: 48.w, height: 48.w),
    Image.asset('assets/images/ic_wallet_gat_gas.png', width: 48.w, height: 48.w),
    Image.asset('assets/images/ic_wallet_transfer_record.png', width: 48.w, height: 48.w),
  ];

  @override
  Widget build(BuildContext context) {
    final hasMnemonic = widget.wallet.mnemonic?.isNotEmpty ?? false;
    final showBackupCTA = !widget.wallet.isBackUp && hasMnemonic;
    return Container(
      padding: EdgeInsets.only(top: 10.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 10.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.wallet.address.length > 12
                          ? '${widget.wallet.network}:${widget.wallet.address.substring(0, 6)}...${widget.wallet.address.substring(widget.wallet.address.length - 6)}'
                          : '${widget.wallet.network}:${widget.wallet.address}',
                      style: TextStyle(fontSize: 13.sp, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: widget.wallet.address));
                      },
                      child: Icon(Icons.copy_outlined, size: 16, color: Theme.of(context).colorScheme.onBackground),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '\$${widget.wallet.balance}',
                        style: TextStyle(fontSize: 40.sp, color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                      ),
                    ),
                    showBackupCTA
                        ? SizedBox(
                            child: Material(
                              borderRadius: BorderRadius.circular(20.r),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () async {
                                  final result = await Get.to(
                                    BackUpHelperOnePage(title: t.wallet.please_remember, prohibit: false, backupAddress: widget.wallet.address),
                                    arguments: {"mnemonic": widget.wallet.mnemonic?.join(" ")},
                                  );
                                  if (result == true) {
                                    await widget.actions.reloadCurrentSelectWalletfn();
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.background,
                                    border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 1.0),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 15.w),
                                  child: _buildButtonContent(),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
                // SizedBox(height: 10.h),
                // Row(
                //   children: [
                //     Text(
                //       '¥10.00 (0.00%)',
                //       style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                //     ),
                //     Container(
                //       padding: EdgeInsets.symmetric(horizontal: 10.w),
                //       margin: EdgeInsets.symmetric(horizontal: 5),
                //       decoration: BoxDecoration(
                //         color: Theme.of(context).colorScheme.background,
                //         borderRadius: BorderRadius.circular(10.r),
                //         border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 1.h),
                //       ),
                //       child: Center(
                //         child: Row(
                //           children: [
                //             Text(t.common.today, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
            children: List.generate(titles.length, (index) {
              return GestureDetector(
                onTap: () {
                  if (index == 0) {
                    Get.to(SelectTransferCoinTypePage(), transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
                  } else if (index == 1) {
                    Get.to(SelectedPayeePage(), transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
                  } else if (index == 4) {
                    Get.to(TransactionHistory(), transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
                  }
                },
                child: SizedBox(
                  height: 80,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _navIcons[index],
                      SizedBox(height: 5),
                      Text(
                        titles[index],
                        style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onBackground),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 15.h),
          Divider(
            color: Theme.of(context).colorScheme.onSurface,
            height: 1, // 线的高度
            thickness: 1, // 线的粗细
          ),
        ],
      ),
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNetworkIcon(),
        SizedBox(width: 3.w),
        _buildNetworkText(),
      ],
    );
  }

  Widget _buildNetworkIcon() {
    return ClipOval(
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
        child: Image.asset('assets/images/ic_wallet_reminder.png', width: 14.w, height: 14.w),
      ),
    );
  }

  Widget _buildNetworkText() {
    return SizedBox(
      width: 40.w,
      child: Text(
        t.Mysettings.go_backup,
        style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
