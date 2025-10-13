import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/state/app_provider.dart';
import 'package:untitled1/theme/app_textStyle.dart';

/// 使用指南
class Usageguidelines extends ConsumerStatefulWidget {
  const Usageguidelines({super.key});

  @override
  ConsumerState<Usageguidelines> createState() => _UsageguidelinesState();
}

class _UsageguidelinesState extends ConsumerState<Usageguidelines> {
  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final List<Map<String, dynamic>> sections = [
      {
        "title": t.Mysettings.getting_started,
        "items": [t.Mysettings.create_first_wallet, t.Mysettings.get_first_crypto_asset, t.Mysettings.complete_first_transaction],
      },
      {
        "title": t.Mysettings.basic_concepts,
        "items": [t.Mysettings.about_wallet, t.Mysettings.blockchain_and_token, t.Mysettings.transfer_and_receive, t.Mysettings.swap_transaction],
      },
    ];
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leadingWidth: 40,
        leading: GestureDetector(
          onTap: () => {Feedback.forTap(context), Navigator.of(context).pop()},
          child: Icon(Icons.arrow_back_ios_new, size: 20.w, color: Theme.of(context).colorScheme.onBackground),
        ),
        centerTitle: true,
        title: Text(t.Mysettings.user_guide, style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 12.w),
                child: _buildSearchField(),
              ),
              SizedBox(height: 20.h),
              ...sections.map((section) => _buildSection(section)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  /// 搜索框
  Widget _buildSearchField() {
    return TextField(
      cursorColor: Theme.of(context).colorScheme.onBackground,
      decoration: InputDecoration(
        hintText: t.Mysettings.support_search_hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: EdgeInsets.only(right: 14),
        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(25.r)),
        prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onBackground),
      ),
    );
  }

  /// 一个章节
  Widget _buildSection(Map<String, dynamic> section) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 12.w),
            child: Text(
              section["title"],
              // style: TextStyle(fontSize: 18.sp, color: Colors.black, fontWeight: FontWeight.bold),
              style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground),
            ),
          ),
          SizedBox(height: 12.h),
          ...List.generate(section["items"].length, (index) {
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
              leading: Text(
                section["items"][index],
                // style: TextStyle(fontSize: 16.sp, color: Colors.black),
                style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.normal),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 18.w, color: Theme.of(context).colorScheme.onSurface),
              onTap: () {},
            );
          }),
        ],
      ),
    );
  }
}
