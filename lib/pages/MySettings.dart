import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/pages/view/CustomAppBar.dart';

class Mysettings extends StatefulWidget {
  const Mysettings({super.key});

  @override
  State<Mysettings> createState() => _MysettingsState();
}

class _MysettingsState extends State<Mysettings> {
  final TextStyle titleStyle = TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black);

  final TextStyle trailingStyle = TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF757F7F));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "",
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 14.w),
            child: Icon(Icons.mode_night, size: 18.w, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.w),
        child: Column(
          children: [
            _buildHeader(),

            _buildBindExchangeCard(),

            Expanded(
              child: ListView(
                children: [
                  SizedBox(height: 22.h),
                  _SectionTitle("偏好设置"),
                  _SettingItem(title: "语言", trailingText: "简体中文", onTap: _onTap),
                  _SettingItem(title: "货币单位", trailingText: "USD", onTap: _onTap),
                  _SettingItem(title: "主题模式", trailingText: "跟随系统", onTap: _onTap),
                  _SettingItem(title: "涨跌幅周期", trailingText: "0点涨跌幅", onTap: _onTap),
                  _SettingItem(title: "奖励账户", onTap: _onTap),
                  _SettingItem(title: "更多设置", onTap: _onTap),
                  const _SectionDivider(),

                  SizedBox(height: 22.h),
                  _SectionTitle("学习"),
                  _SettingItem(title: "使用指南", onTap: _onTap),
                  _SettingItem(title: "钱包学院", onTap: _onTap),
                  _SettingItem(title: "帮助中心", onTap: _onTap),
                  _SettingItem(title: "用户反馈", onTap: _onTap),
                  _SettingItem(title: "安全与隐私", onTap: _onTap),
                  const _SectionDivider(),

                  SizedBox(height: 22.h),
                  _SectionTitle("加入我们"),
                  _SettingItem(title: "全球社区", onTap: _onTap),
                  _SettingItem(title: "工作机会", onTap: _onTap),
                  _SettingItem(title: "关于我们", trailingText: "v 8.32.0", onTap: _onTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 点击回调：带震动反馈
  void _onTap() {
    HapticFeedback.heavyImpact();
  }

  /// 顶部头像昵称 + 去备份
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.0),
      width: double.infinity,
      height: 55.h,
      child: Row(
        children: [
          const CircleAvatar(radius: 32, backgroundImage: AssetImage("assets/images/ic_clip_photo.png")),
          SizedBox(width: 12.w),
          Expanded(
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "我的钱包",
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "ID: deed...27dc",
                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF757F7F)),
                    ),
                  ],
                ),
                SizedBox(width: 31.w),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 9, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.w, color: const Color(0xFFE5E5E5)),
                    borderRadius: BorderRadius.circular(45.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_rounded, size: 14.w, color: Colors.black),
                      SizedBox(width: 3.w),
                      Text(
                        "去备份",
                        style: TextStyle(fontSize: 13.sp, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.keyboard_arrow_right_rounded, size: 17.h, color: Colors.black),
        ],
      ),
    );
  }

  /// 绑定交易所卡片
  Widget _buildBindExchangeCard() {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 14),
      child: Container(
        margin: EdgeInsets.only(top: 34),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        width: double.infinity,
        height: 96.h,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), color: const Color(0xFFF9F9F9)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "绑定交易所账号",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 16.w),
                  decoration: BoxDecoration(color: AppColors.color_286713, borderRadius: BorderRadius.circular(25.r)),
                  child: Row(
                    children: [
                      Text(
                        "去绑定",
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      Icon(Icons.keyboard_arrow_right_rounded, color: Colors.white, size: 17.h),
                    ],
                  ),
                ),
              ],
            ),
            Image.asset("assets/images/bind_count_image.png", width: 72.w, height: 78.h),
          ],
        ),
      ),
    );
  }
}

/// 分组标题
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Text(
        text,
        style: TextStyle(fontSize: 13.sp, color: const Color(0xFF757F7F)),
      ),
    );
  }
}

/// 分组分割线
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(color: const Color(0xFFE7E7E7), height: .5.h);
  }
}

/// 通用设置项
class _SettingItem extends StatelessWidget {
  final String title;
  final String? trailingText;
  final VoidCallback? onTap;

  const _SettingItem({required this.title, this.trailingText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 0,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.0),
      title: Text(
        title,
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText!,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF757F7F)),
            ),
          if (trailingText != null) SizedBox(width: 8.w),
          Icon(Icons.arrow_forward_ios, size: 15, color: const Color(0xFFA3ADAD)),
        ],
      ),
      onTap: onTap,
    );
  }
}
