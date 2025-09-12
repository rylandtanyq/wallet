import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/constants/AppColors.dart';
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
          child: Icon(Icons.arrow_back_ios_new, size: 20.w, color: Colors.black),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 12.w),
            child: Text(
              "更多设置",
              style: TextStyle(fontSize: 24.sp, color: Colors.black, fontWeight: FontWeight.w500),
            ),
          ),
          _setItemListTile(
            title: "需解锁打开App",
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
            title: "面容 / 指纹支付",
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
            title: "免密支付",
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
            title: "默认启动页设置",
            iconWidget: false,
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "首页",
                  style: TextStyle(fontSize: 15.sp, color: Color(0xFF757F7F)),
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
            title: "地址本管理",
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
            title: "节点设置",
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
            title: "切换线路",
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
            title: "用户使用协议",
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
            title: "隐私协议",
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
            title: "开源与审计",
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
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsetsGeometry.symmetric(horizontal: 12.w),
        leading: Row(
          mainAxisSize: MainAxisSize.min, // 只包裹内容
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.black),
            ),
            if (iconWidget)
              Padding(
                padding: EdgeInsets.only(left: 4),
                child: Transform.translate(
                  offset: Offset(0, 1), // x:0, y:2 向下偏移 2 像素
                  child: Icon(Icons.help_outline, size: 17.w, color: Color(0xFFA3ADAD)),
                ),
              ),
          ],
        ),
        trailing: trailing,
      ),
    );
  }
}
