import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/pages/RewardsAccount.dart';
import 'package:untitled1/pages/view/CustomAppBar.dart';

class Mysettings extends StatefulWidget {
  const Mysettings({super.key});

  @override
  State<Mysettings> createState() => _MysettingsState();
}

class _MysettingsState extends State<Mysettings> {
  final TextStyle titleStyle = TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black);

  final TextStyle trailingStyle = TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF757F7F));

  final _languages = ["English", "中文简体", "中文繁体", "日本语", "越南语", "Indonesia", "Tiéng Viet", "Jeol", "Turkge", "Español (Latinoamérica)", "Italiano"];

  final _currencyUnit = ["USD", "CNY", "NGN", "IDR", "INR", "BDT", "VND", "PKR", "RUB", "EUR", "UAH"];

  // final _themeModel = ["跟随系统", "日间模式", "夜间模式"];
  final List<Map<String, String>> _themeModel = [
    {"model": "跟随系统", "subtitle": "开启后，主题将跟随系统设置调整主题模式"},
    {"model": "日间模式", "subtitle": "日间模式"},
    {"model": "夜间模式", "subtitle": "夜间模式"},
  ];

  // final _riseAndFallCycleData = ["0 点涨跌幅", "24小时涨跌幅"];
  final List<Map<String, String>> _riseAndFallCycleData = [
    {"model": "0 点涨跌幅", "subtitle": "涨跌幅以自然天计算，与你所在时区一致 (UTC+8)"},
    {"model": "24小时涨跌幅", "subtitle": "涨跌幅以过去 24 小时滚动计算"},
  ];

  String _selectedLanguageTralingText = "中文简体";
  String _selectedCurrencyTralingText = "USD";
  String _selectedThemeModelText = "跟随系统";
  String _selectedRiseAndFallCycleText = "0 点涨跌幅";

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
                  _SettingItem(title: "语言", trailingText: _selectedLanguageTralingText, onTap: () => _onSelectLanguage()),
                  _SettingItem(title: "货币单位", trailingText: _selectedCurrencyTralingText, onTap: () => _onSelectedCurrencyUnit()),
                  _SettingItem(title: "主题模式", trailingText: _selectedThemeModelText, onTap: () => _changeThemeModel()),
                  _SettingItem(title: "涨跌幅周期", trailingText: _selectedRiseAndFallCycleText, onTap: () => _riseAndFallCycle()),
                  _SettingItem(title: "奖励账户", onTap: () => _rewardsAccount()),
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

  /// 语言
  void _onSelectLanguage() async {
    HapticFeedback.heavyImpact();
    final selected = await _showModalBottomSheet<String>(
      context: context,
      title: "选择语言",
      items: _languages,
      currentValue: _selectedLanguageTralingText,
    );
    if (selected != null) {
      setState(() {
        _selectedLanguageTralingText = selected;
      });
    }
  }

  /// 货币单位
  void _onSelectedCurrencyUnit() async {
    HapticFeedback.heavyImpact();
    final selected = await _showModalBottomSheet<String>(
      context: context,
      title: "选择货币单位",
      items: _currencyUnit,
      currentValue: _selectedCurrencyTralingText,
    );
    if (selected != null) {
      setState(() {
        _selectedCurrencyTralingText = selected;
      });
      print("用户选择了 $_selectedCurrencyTralingText 12货币");
    }
  }

  /// 主题模式
  void _changeThemeModel() async {
    HapticFeedback.heavyImpact();
    final selected = await _themeModelOrRiseAndFallCycle(
      context: context,
      title: "选择主题模式",
      contentList: _themeModel,
      currentValue: _selectedThemeModelText,
    );
    if (selected != null) {
      setState(() {
        _selectedThemeModelText = selected;
      });
    }
  }

  /// 涨幅周期
  void _riseAndFallCycle() async {
    HapticFeedback.heavyImpact();
    final selected = await _themeModelOrRiseAndFallCycle(
      context: context,
      title: "涨跌幅周期",
      contentList: _riseAndFallCycleData,
      currentValue: _selectedRiseAndFallCycleText,
    );
    if (selected != null) {
      setState(() {
        _selectedRiseAndFallCycleText = selected;
      });
    }
  }

  /// 奖励账户
  void _rewardsAccount() {
    HapticFeedback.heavyImpact();
    Get.to(Rewardsaccount());
  }

  /// 多语言 / 货币单位通用弹窗
  Future<T?> _showModalBottomSheet<T>({required BuildContext context, required String title, required List<T> items, T? currentValue}) {
    T? selectedValue = currentValue;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Material(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
              color: Colors.white,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 标题
                      Padding(
                        padding: EdgeInsets.only(left: 14, right: 14, top: 17, bottom: 12.h),
                        child: Text(
                          title,
                          style: TextStyle(fontSize: 18.sp, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Divider(color: const Color(0xFFE7E7E7), height: .5.h),
                      // 语言列表
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            children: items.map((lang) {
                              return ListTile(
                                minVerticalPadding: 0,
                                contentPadding: EdgeInsets.symmetric(horizontal: 14),
                                title: Text(
                                  lang.toString(),
                                  style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                                trailing: selectedValue == lang ? Icon(Icons.check, color: Colors.black) : null,
                                onTap: () {
                                  HapticFeedback.heavyImpact();
                                  setState(() {
                                    selectedValue = lang;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      // 底部关闭按钮
                      InkWell(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          Navigator.of(context).pop(selectedValue);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 60.h,
                          alignment: Alignment.center,
                          child: Text(
                            "关闭",
                            style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((selected) {
      if (selected != null) {
        print("选中了: $selected");
      }
      return selected;
    });
  }

  /// 主题模式 / 涨跌幅周期 popup
  Future<T?> _themeModelOrRiseAndFallCycle<T>({
    required BuildContext context,
    required String title,
    required List<Map<String, String>> contentList,
    required T? currentValue,
  }) {
    T? selectedValue = currentValue;
    return showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Material(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
              color: Colors.white,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 14, right: 14, top: 17, bottom: 12.h),
                        child: Text(
                          title,
                          style: TextStyle(fontSize: 18.sp, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Divider(color: const Color(0xFFE7E7E7), height: .5.h),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            children: List.generate(contentList.length, (index) {
                              final item = contentList[index];
                              final model = item["model"];
                              final subtitle = item["subtitle"];
                              return ListTile(
                                title: Text(
                                  "$model",
                                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                subtitle: Text(
                                  "$subtitle",
                                  style: TextStyle(fontSize: 13.sp, color: Color(0xFF757F7F)),
                                ),
                                trailing: selectedValue == model ? Icon(Icons.check, color: Colors.black) : null,
                                onTap: () {
                                  HapticFeedback.heavyImpact();
                                  setState(() {
                                    selectedValue = model! as T?;
                                  });
                                },
                              );
                            }),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          Navigator.of(context).pop(selectedValue);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 60.h,
                          alignment: Alignment.center,
                          child: Text(
                            "关闭",
                            style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
