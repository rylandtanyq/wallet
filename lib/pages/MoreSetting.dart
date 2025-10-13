import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/theme/app_textStyle.dart';
import 'package:untitled1/widget/CustomSwitch.dart';

/// 更多设置
class Moresetting extends StatefulWidget {
  const Moresetting({super.key});

  @override
  State<Moresetting> createState() => _MoresettingState();
}

class _MoresettingState extends State<Moresetting> {
  bool _unlockApp = false;
  bool _faceID = false;
  bool _passwordFreePayment = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: GestureDetector(
          onTap: () => {Feedback.forTap(context), Navigator.of(context).pop()},
          child: Icon(Icons.arrow_back_ios_new, size: 20.w, color: Theme.of(context).colorScheme.onBackground),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 12.w),
            child: Text(
              t.Mysettings.more_settings,
              style: AppTextStyles.headline1.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
            ),
          ),
          _setItemListTile(
            title: t.Mysettings.unlock_to_open_app,
            iconWidget: false,
            trailing: CustomSwitch(
              value: _unlockApp,
              onChanged: (val) {
                setState(() {
                  Feedback.forTap(context);
                  HapticFeedback.heavyImpact();
                  _unlockApp = val;
                });
              },
            ),
          ),
          _setItemListTile(
            title: t.Mysettings.face_fingerprint_payment,
            iconWidget: false,
            trailing: CustomSwitch(
              value: _faceID,
              onChanged: (val) {
                setState(() {
                  Feedback.forTap(context);
                  HapticFeedback.heavyImpact();
                  _faceID = val;
                });
              },
            ),
          ),
          _setItemListTile(
            title: t.Mysettings.password_free_payment,
            iconWidget: true,
            trailing: CustomSwitch(
              value: _passwordFreePayment,
              onChanged: (val) {
                setState(() {
                  Feedback.forTap(context);
                  HapticFeedback.heavyImpact();
                  _passwordFreePayment = val;
                });
              },
            ),
          ),
          _setItemListTile(
            onTap: () {
              HapticFeedback.heavyImpact();
            },
            title: t.Mysettings.default_start_page_setting,
            iconWidget: false,
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.tabbar.home,
                  // style: TextStyle(fontSize: 15.sp, color: Color(0xFF757F7F)),
                  style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
                SizedBox(width: 8.w),
                Transform.translate(
                  offset: Offset(0, 2), // x:0, y:2 向下偏移 2 像素
                  child: Icon(Icons.arrow_forward_ios, size: 15.w, color: Color(0xFFA3ADAD)),
                ),
              ],
            ),
          ),
          _setItemListTile(
            onTap: () {
              HapticFeedback.heavyImpact();
            },
            title: t.Mysettings.address_book_management,
            iconWidget: false,
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 8.w),
                Icon(Icons.arrow_forward_ios, size: 15.w, color: const Color(0xFFA3ADAD)),
              ],
            ),
          ),
          _setItemListTile(
            onTap: () {
              HapticFeedback.heavyImpact();
            },
            title: t.Mysettings.node_settings,
            iconWidget: false,
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 8.w),
                Icon(Icons.arrow_forward_ios, size: 15.w, color: const Color(0xFFA3ADAD)),
              ],
            ),
          ),
          _setItemListTile(
            onTap: () {
              HapticFeedback.heavyImpact();
            },
            title: t.Mysettings.switch_network,
            iconWidget: false,
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 8.w),
                Icon(Icons.arrow_forward_ios, size: 15.w, color: const Color(0xFFA3ADAD)),
              ],
            ),
          ),
          Divider(color: const Color(0xFFE7E7E7), height: .5.h),
          _setItemListTile(
            onTap: () {
              HapticFeedback.heavyImpact();
            },
            title: t.Mysettings.user_agreement,
            iconWidget: false,
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 8.w),
                Icon(Icons.arrow_forward_ios, size: 15.w, color: const Color(0xFFA3ADAD)),
              ],
            ),
          ),
          _setItemListTile(
            onTap: () {
              HapticFeedback.heavyImpact();
            },
            title: t.Mysettings.privacy_policy,
            iconWidget: false,
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 8.w),
                Icon(Icons.arrow_forward_ios, size: 15.w, color: const Color(0xFFA3ADAD)),
              ],
            ),
          ),
          _setItemListTile(
            onTap: () {
              HapticFeedback.heavyImpact();
            },
            title: t.Mysettings.open_source_and_audit,
            iconWidget: false,
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 8.w),
                Icon(Icons.arrow_forward_ios, size: 15.w, color: const Color(0xFFA3ADAD)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _setItemListTile extends StatelessWidget {
  final String title;
  final bool iconWidget;
  final Widget trailing;
  final VoidCallback? onTap;

  const _setItemListTile({required this.title, this.iconWidget = false, required this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (iconWidget)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.help_outline, size: 17.w, color: const Color(0xFFA3ADAD)),
              ),
          ],
        ),
        trailing: trailing,
      ),
    );
  }
}
