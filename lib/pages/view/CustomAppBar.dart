import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading; // 左侧自定义组件（默认是返回箭头）
  final List<Widget>? actions; // 右侧操作按钮列表
  final bool showBackButton; // 是否显示返回按钮
  final Color backgroundColor; // 背景色
  final Color textColor; // 文字颜色
  final bool centerTitle; // 是否显示返回按钮
  final VoidCallback? onBackPressed; // 自定义返回逻辑

  const CustomAppBar({
    Key? key,
    required this.title,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.centerTitle = true,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: textColor),
      ),
      leading: _buildLeading(context),
      actions: actions ?? [],
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (showBackButton) {
      return IconButton(
        icon: Icon(Icons.arrow_back_ios_new, size: 20.w, color: textColor),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      );
    }
    return null;
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight.h);
}
