import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/pages/add_tokens_page/index.dart';
import 'package:untitled1/pages/wallet_page/fragments/wallet_page_action_fragments.dart';
import 'package:untitled1/theme/app_textStyle.dart';

class WalletPageToolFragments extends StatefulWidget {
  final TextEditingController textEditingController;
  final WalletActions actions;
  const WalletPageToolFragments({super.key, required this.textEditingController, required this.actions});

  @override
  State<WalletPageToolFragments> createState() => _WalletPageToolFragmentsState();
}

class _WalletPageToolFragmentsState extends State<WalletPageToolFragments> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.sort, color: Theme.of(context).colorScheme.onBackground),
          SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: widget.textEditingController,
              decoration: InputDecoration(
                hintText: t.wallet.token_name,
                hintStyle: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: EdgeInsets.only(right: 14),
                border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(25.r)),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onBackground),
              ),
              onChanged: (e) => widget.actions.onSearchChange(e),
            ),
          ),
          SizedBox(width: 15),
          GestureDetector(
            onTap: () {
              unawaited(widget.actions.reloadTokensPrice());
              if (mounted) setState(() {});
            },
            child: Icon(Icons.update_sharp, color: Theme.of(context).colorScheme.onBackground),
          ),
          SizedBox(width: 15),
          GestureDetector(
            onTap: () async {
              final added = await Get.to(AddingTokens(), transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
              if (added == true) {
                widget.actions.reloadTokens();
                unawaited(widget.actions.reloadTokensPrice());
                unawaited(widget.actions.reloadTokensAmount());
                if (mounted) setState(() {});
              }
            },
            child: Icon(Icons.add_circle_outline_sharp),
          ),
        ],
      ),
    );
  }
}
