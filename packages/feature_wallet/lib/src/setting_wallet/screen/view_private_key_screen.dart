import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:feature_wallet/i18n/strings.g.dart';
import 'package:shared_setting/state/app_provider.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'package:shared_utils/biometric_service.dart';

class ViewPrivateKeyScreen extends ConsumerStatefulWidget {
  final String title;
  final String privateKey;
  final String hideContent;
  const ViewPrivateKeyScreen({super.key, required this.privateKey, required this.title, required this.hideContent});

  @override
  ConsumerState<ViewPrivateKeyScreen> createState() => _ViewPrivateKeyScreenState();
}

class _ViewPrivateKeyScreenState extends ConsumerState<ViewPrivateKeyScreen> {
  bool _blueBool = true;

  @override
  Widget build(BuildContext context) {
    final biometricState = ref.watch(getBioMetricsProvide);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: GestureDetector(
          onTap: () => {Feedback.forTap(context), Navigator.of(context).pop()},
          child: Icon(Icons.arrow_back_ios_new, size: 20.w, color: Theme.of(context).colorScheme.onBackground),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(fontSize: 30, color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(t.wallet.private_key_warning),
                    SizedBox(height: 20),
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 180.h,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.surface),
                          child: Text(widget.privateKey, style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                        ),
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: widget.privateKey));
                              Fluttertoast.showToast(
                                msg: t.wallet.address_copied,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                textColor: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 16.0,
                              );
                            },
                            child: Icon(Icons.copy, size: 20, color: Theme.of(context).colorScheme.onBackground),
                          ),
                        ),
                        if (_blueBool)
                          Positioned.fill(
                            top: 0,
                            left: 0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.black.withOpacity(0.15)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.visibility_off_rounded, size: 44),
                                      SizedBox(height: 14.h),
                                      Text(
                                        t.wallet.ensure_not_being_watched,
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground),
                                      ),
                                      SizedBox(height: 16.h),
                                      GestureDetector(
                                        onTap: () async {
                                          if (biometricState) {
                                            final result = await BiometricService.instance.authenticate(reason: t.wallet.verifyIdentity);
                                            if (result == true) {
                                              setState(() => _blueBool = false);
                                            } else {
                                              Fluttertoast.showToast(
                                                msg: t.wallet.identityVerifyFailed,
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Theme.of(context).colorScheme.primary,
                                                textColor: Theme.of(context).colorScheme.onPrimary,
                                                fontSize: 16.0,
                                              );
                                            }
                                            return;
                                          }
                                          setState(() => _blueBool = false);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                          decoration: BoxDecoration(
                                            border: Border.all(width: 1, color: Theme.of(context).colorScheme.onSurface.withOpacity(.4)),
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          child: Text(
                                            t.wallet.view_private_key,
                                            style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onBackground),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    if (!_blueBool)
                      GestureDetector(
                        onTap: () => setState(() => _blueBool = true),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(width: 1, color: Theme.of(context).colorScheme.onSurface.withOpacity(.4)),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              child: Row(
                                children: [
                                  Icon(Icons.visibility_off_rounded, size: 18),
                                  SizedBox(width: 6.w),
                                  Text(
                                    widget.hideContent,
                                    style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onBackground),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  height: 40.h,
                  margin: EdgeInsets.only(bottom: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(50)),
                  child: Text(t.wallet.done, style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
