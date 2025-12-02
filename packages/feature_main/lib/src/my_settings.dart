import 'package:feature_main/src/about_us.dart';
import 'package:flutter/material.dart';
import 'package:feature_main/src/more_setting.dart';
import 'package:feature_main/src/rewards_account.dart';
import 'package:feature_main/src/usage_guidelines.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:shared_setting/i18n/strings.g.dart';
import 'package:shared_setting/state/app_notifier.dart';
import 'package:shared_setting/state/app_provider.dart';
import 'package:shared_utils/constants/app_colors.dart';
import 'package:shared_ui/widget/custom_appbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'package:feature_main/i18n/strings.g.dart';
import 'package:shared_setting/i18n/strings.g.dart' as gt;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

class Mysettings extends ConsumerStatefulWidget {
  const Mysettings({super.key});

  @override
  ConsumerState<Mysettings> createState() => _MysettingsState();
}

class _MysettingsState extends ConsumerState<Mysettings> {
  final _currencyUnit = ["USD", "CNY", "NGN", "IDR", "INR", "BDT", "VND", "PKR", "RUB", "EUR", "UAH"];
  String _selectedCurrencyTralingText = "USD";
  String _selectedThemeModelText = t.Mysettings.follow_system;
  Version? _appVersion;

  @override
  void initState() {
    super.initState();
    _packageInfo();
  }

  Future<void> _packageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersionStr = packageInfo.version;
    Version currentVersion = Version.parse(currentVersionStr);
    if (mounted) {
      setState(() {
        _appVersion = currentVersion;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final riseAndFallKey = ref.watch(riseAndFallCycleProvide);
    final riseAndFallNotifier = ref.read(riseAndFallCycleProvide.notifier);
    ref.watch(localeProvider);

    final appLocale = LocaleSettings.currentLocale;
    String selectedRiseAndFallCycleText = riseAndFallKey == t.Mysettings.zero_clock_change
        ? t.Mysettings.zero_clock_change
        : t.Mysettings.twenty_four_hour_change;

    final languages = [
      t.common.english,
      t.common.simplified_Chinese,
      t.common.traditional_Chinese,
      t.common.spanish,
      t.common.japanese,
      t.common.russian,
    ];

    final languageLocaleMap = {
      t.common.english: gt.AppLocale.en,
      t.common.simplified_Chinese: gt.AppLocale.zhHans,
      t.common.traditional_Chinese: gt.AppLocale.zhHant,
      t.common.spanish: gt.AppLocale.es,
      t.common.japanese: gt.AppLocale.ja,
      t.common.russian: gt.AppLocale.ru,
    };

    final trailingText =
        {
          AppLocale.en: t.common.english,
          AppLocale.zhHans: t.common.simplified_Chinese,
          AppLocale.zhHant: t.common.traditional_Chinese,
          AppLocale.es: t.common.spanish,
          AppLocale.ja: t.common.japanese,
          AppLocale.ru: t.common.russian,
        }[appLocale] ??
        t.common.english;

    final List<Map<String, String>> themeModel = [
      {"model": t.Mysettings.follow_system, "subtitle": t.Mysettings.follow_system_desc},
      {"model": t.Mysettings.light_mode, "subtitle": t.Mysettings.light_mode},
      {"model": t.Mysettings.dark_mode, "subtitle": t.Mysettings.dark_mode},
    ];

    final List<Map<String, String>> riseAndFallCycleData = [
      {"model": t.Mysettings.zero_clock_change, "subtitle": t.Mysettings.zero_clock_change_desc},
      {"model": t.Mysettings.twenty_four_hour_change, "subtitle": t.Mysettings.twenty_four_hour_change_desc},
    ];

    _selectedThemeModelText = themeMode == ThemeMode.light
        ? t.Mysettings.light_mode
        : themeMode == ThemeMode.dark
        ? t.Mysettings.dark_mode
        : t.Mysettings.follow_system;

    return Scaffold(
      appBar: CustomAppBar(
        title: "",
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 14.w),
            child: GestureDetector(
              onTap: () {
                ref.read(themeProvider.notifier).toggleTheme();
                setState(() {
                  if (themeMode == ThemeMode.dark) {
                    _selectedThemeModelText = t.Mysettings.light_mode;
                  } else if (themeMode == ThemeMode.light) {
                    _selectedThemeModelText = t.Mysettings.dark_mode;
                  } else {
                    _selectedThemeModelText = t.Mysettings.follow_system;
                  }
                });
              },
              child: themeMode == ThemeMode.light
                  ? Icon(Icons.mode_night, size: 18.w, color: Theme.of(context).appBarTheme.foregroundColor)
                  : Icon(Icons.sunny, size: 18.w, color: Theme.of(context).appBarTheme.foregroundColor),
            ),
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
                  _SectionTitle(t.Mysettings.preferences),
                  _SettingItem(
                    title: t.Mysettings.language,
                    trailingText: trailingText,
                    onTap: () => _onSelectLanguage(languages, languageLocaleMap, trailingText),
                  ),
                  _SettingItem(title: t.Mysettings.currency_unit, trailingText: _selectedCurrencyTralingText, onTap: () => _onSelectedCurrencyUnit()),
                  _SettingItem(title: t.Mysettings.theme_mode, trailingText: _selectedThemeModelText, onTap: () => _changeThemeModel(themeModel)),
                  _SettingItem(
                    title: t.Mysettings.change_period,
                    trailingText: selectedRiseAndFallCycleText,
                    onTap: () => _riseAndFallCycle(riseAndFallCycleData, riseAndFallKey, riseAndFallNotifier),
                  ),
                  _SettingItem(title: t.Mysettings.rewards_account, onTap: () => _rewardsAccount()),
                  _SettingItem(title: t.Mysettings.more_settings, onTap: () => _moreSetting()),
                  const _SectionDivider(),

                  SizedBox(height: 22.h),
                  _SectionTitle(t.Mysettings.learn),
                  _SettingItem(title: t.Mysettings.user_guide, onTap: () => _usageGuidelines()),
                  _SettingItem(title: t.Mysettings.wallet_academy, onTap: _onTap),
                  _SettingItem(title: t.Mysettings.help_center, onTap: _onTap),
                  _SettingItem(title: t.Mysettings.user_feedback, onTap: _onTap),
                  _SettingItem(title: t.Mysettings.security_privacy, onTap: _onTap),
                  const _SectionDivider(),

                  SizedBox(height: 22.h),
                  _SectionTitle(t.Mysettings.join_us),
                  _SettingItem(title: t.Mysettings.global_community, onTap: _onTap),
                  _SettingItem(title: t.Mysettings.career_opportunities, onTap: _onTap),
                  _SettingItem(title: t.Mysettings.about_us, trailingText: "v $_appVersion", onTap: () => _aboutUs(_appVersion!)),
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
  void _onSelectLanguage(List<String> languages, Map<String, gt.AppLocale> languageLocaleMap, String trailingText) async {
    HapticFeedback.heavyImpact();
    final selected = await _showModalBottomSheet<String>(
      context: context,
      title: t.common.select_Language,
      items: languages,
      currentValue: trailingText,
    );

    if (selected != null) {
      final locale = languageLocaleMap[selected];
      if (locale != null) {
        // 这里传的就是 shared_setting 的 AppLocale
        ref.read(localeProvider.notifier).changeLocale(locale);
      }
    }
  }

  /// 货币单位
  void _onSelectedCurrencyUnit() async {
    HapticFeedback.heavyImpact();
    final selected = await _showModalBottomSheet<String>(
      context: context,
      title: t.Mysettings.select_currency_unit,
      items: _currencyUnit,
      currentValue: _selectedCurrencyTralingText,
    );
    if (selected != null) {
      setState(() {
        _selectedCurrencyTralingText = selected;
      });
      debugPrint("用户选择了 $_selectedCurrencyTralingText 12货币");
    }
  }

  /// 主题模式
  void _changeThemeModel(List<Map<String, String>> themeModel) async {
    HapticFeedback.heavyImpact();
    final selected = await _themeModelOrRiseAndFallCycle(
      context: context,
      title: t.Mysettings.select_theme_mode,
      contentList: themeModel,
      currentValue: _selectedThemeModelText,
    );
    if (selected != null) {
      if (selected == t.Mysettings.dark_mode) {
        ref.read(themeProvider.notifier).setTheme(ThemeMode.dark);
      } else if (selected == t.Mysettings.light_mode) {
        ref.read(themeProvider.notifier).setTheme(ThemeMode.light);
      } else {
        ref.read(themeProvider.notifier).setTheme(ThemeMode.system);
      }
      setState(() {
        _selectedThemeModelText = selected;
      });
    }
  }

  /// 涨幅周期
  void _riseAndFallCycle(List<Map<String, String>> riseAndFallCycleData, String riseAndFallKey, RiseAndFallCycleNotifier riseAndFallNotifier) async {
    HapticFeedback.heavyImpact();
    final selected = await _themeModelOrRiseAndFallCycle(
      context: context,
      title: t.Mysettings.change_period,
      contentList: riseAndFallCycleData,
      currentValue: riseAndFallKey == t.Mysettings.zero_clock_change ? t.Mysettings.zero_clock_change : t.Mysettings.twenty_four_hour_change,
    );
    if (selected != null) {
      setState(() {
        riseAndFallKey = selected == t.Mysettings.zero_clock_change ? t.Mysettings.zero_clock_change : t.Mysettings.twenty_four_hour_change;
        riseAndFallNotifier.setRiseAndFallCycle(selected);
      });
    }
  }

  /// 奖励账户
  void _rewardsAccount() {
    HapticFeedback.heavyImpact();
    Get.to(Rewardsaccount(), transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
  }

  /// 更多设置
  void _moreSetting() {
    HapticFeedback.heavyImpact();
    Get.to(Moresetting(), transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
  }

  /// 使用指南
  void _usageGuidelines() {
    HapticFeedback.heavyImpact();
    Get.to(Usageguidelines(), transition: Transition.rightToLeft, duration: Duration(milliseconds: 300));
  }

  void _aboutUs(Version version) {
    HapticFeedback.heavyImpact();
    Get.to(
      AboutUs(version: version),
      transition: Transition.rightToLeft,
      duration: Duration(milliseconds: 300),
    );
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
              // color: Theme.of(context).colorScheme.background,
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
                          style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
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
                                  style: AppTextStyles.headline4.copyWith(
                                    color: Theme.of(context).colorScheme.onBackground,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: selectedValue == lang ? Icon(Icons.check, color: Theme.of(context).colorScheme.onBackground) : null,
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
                            t.common.close,
                            style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
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
              // color: Theme.of(context).colorScheme.background,
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
                          style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
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
                                  style: AppTextStyles.headline4.copyWith(
                                    color: Theme.of(context).colorScheme.onBackground,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "$subtitle",
                                  style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                                ),
                                trailing: selectedValue == model ? Icon(Icons.check, color: Theme.of(context).colorScheme.onBackground) : null,
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
                            t.common.close,
                            style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
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
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.common.my_wallet,
                        style: AppTextStyles.headline3.copyWith(color: Theme.of(context).colorScheme.onBackground),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "ID: deed...27dc",
                        // style: TextStyle(fontSize: 12.sp, color: const Color(0xFF757F7F)),
                        style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 31.w),
                Container(
                  width: 90.w,
                  padding: EdgeInsets.symmetric(vertical: 9, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.w, color: Theme.of(context).colorScheme.onSurface),
                    borderRadius: BorderRadius.circular(45.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_rounded, size: 14.w, color: Theme.of(context).appBarTheme.foregroundColor),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          t.Mysettings.go_backup,
                          style: TextStyle(fontSize: 13.sp, color: Theme.of(context).colorScheme.onBackground),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.keyboard_arrow_right_rounded, size: 17.h, color: Theme.of(context).appBarTheme.foregroundColor),
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
                Text(t.Mysettings.bind_exchange_account, style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 16.w),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(25.r)),
                  child: Row(
                    children: [
                      Text(t.Mysettings.go_bind, style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
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
    return Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(.4), height: .5.h);
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
        style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
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
