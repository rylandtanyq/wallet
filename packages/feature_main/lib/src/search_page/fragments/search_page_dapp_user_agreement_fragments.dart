import 'package:feature_browser/dapp_browser/index.dart';
import 'package:feature_main/i18n/strings.g.dart';
import 'package:feature_main/src/search_page/screen/dapp_user_agreement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_ui/theme/app_textStyle.dart';

class SearchPageDappUserAgreementFragments extends StatefulWidget {
  final String textEditing;

  const SearchPageDappUserAgreementFragments({super.key, required this.textEditing});

  static Future<bool?> show(BuildContext context, {required String textEditing}) {
    return showModalBottomSheet<bool>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Material(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10.r), topRight: Radius.circular(10.r)),
            child: SearchPageDappUserAgreementFragments(textEditing: textEditing),
          ),
        );
      },
    );
  }

  @override
  State<SearchPageDappUserAgreementFragments> createState() => _SearchPageDappUserAgreementFragmentsState();
}

class _SearchPageDappUserAgreementFragmentsState extends State<SearchPageDappUserAgreementFragments> {
  bool _agree = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.search.leavingToThirdPartySite, style: AppTextStyles.headline3.copyWith(color: Theme.of(context).colorScheme.onBackground)),
            SizedBox(height: 14.h),
            Text(widget.textEditing, style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
            SizedBox(height: 6.h),
            Text(
              t.search.thirdPartyWarning,
              style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _agree = !_agree;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(_agree ? Icons.check_box : Icons.check_box_outline_blank, color: Theme.of(context).colorScheme.primary),
                      SizedBox(width: 4.w),
                      Text(t.search.iHaveReadAndAccept, style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(DappUserAgreementScreen(), transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
                  },
                  child: Text(
                    t.search.dappTermsOfUse,
                    style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).colorScheme.onBackground, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Theme.of(context).colorScheme.onBackground),
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                      child: Text(t.search.cancel, style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                    ),
                  ),
                ),
                SizedBox(width: 30.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!_agree) {
                        Fluttertoast.showToast(msg: t.search.pleaseAcceptAgreementFirst);
                        return;
                      }
                      Navigator.of(context).pop(true);
                      Get.to(
                        () => DappBrowser(dappUrl: widget.textEditing),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                      );
                    },
                    child: Container(
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(50.r)),
                      child: Text(t.search.confirm, style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
