import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/hive/tokens.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/pages/add_tokens_page/fragments/hint_fragments.dart';
import 'package:untitled1/pages/wallet_page/fragments/wallet_page_action_fragments.dart';
import 'package:untitled1/pages/wallet_page/fragments/wallet_page_token_item_fragments.dart';
import 'package:untitled1/pages/wallet_page/fragments/wallet_page_tool_fragments.dart';
import 'package:untitled1/pages/wallet_page/models/token_price_model.dart';
import 'package:untitled1/state/app_provider.dart';
import 'package:untitled1/theme/app_textStyle.dart';

class WalletPageTokenFragments extends ConsumerStatefulWidget {
  final bool hadLocalTokens;
  final WalletActions actions;
  final List<String> addresses;
  final List<Tokens> fillteredTokensList;
  final Map<String, String> lastPriceMap;
  final TextEditingController textEditingController;
  const WalletPageTokenFragments({
    super.key,
    required this.actions,
    required this.hadLocalTokens,
    required this.addresses,
    required this.fillteredTokensList,
    required this.lastPriceMap,
    required this.textEditingController,
  });

  @override
  ConsumerState<WalletPageTokenFragments> createState() => _WalletPageTokenFragmentsState();
}

class _WalletPageTokenFragmentsState extends ConsumerState<WalletPageTokenFragments> {
  @override
  Widget build(BuildContext context) {
    if (!widget.hadLocalTokens) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            Image.asset('assets/images/no_transaction.png', width: 108, height: 92),
            SizedBox(height: 8),
            Text(t.wallet.no_token_added_yet, style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
      );
    }

    final tokensPriceState = widget.addresses.isEmpty
        ? AsyncValue<TokenPriceModel>.data(TokenPriceModel(result: []))
        : ref.watch(getWalletTokensPriceProvide(widget.addresses));

    if (tokensPriceState.hasError) {
      return Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 12),
        child: HintFragments(
          icons: Icon(Icons.error, color: Theme.of(context).colorScheme.error),
          hitTitle: t.wallet.unknown_error_please_try_again_later,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WalletPageToolFragments(textEditingController: widget.textEditingController, actions: widget.actions),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return WalletPageTokenItemFragments(
                index: index,
                tokensPriceState: tokensPriceState,
                fillteredTokensList: widget.fillteredTokensList,
                lastPriceMap: widget.lastPriceMap,
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(height: 10);
            },
            itemCount: widget.fillteredTokensList.length,
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.color_2B6D16,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21.5.r)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 11),
              ),
              onPressed: () {},
              child: Text(
                t.common.manageToken,
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
