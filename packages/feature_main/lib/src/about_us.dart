import 'package:feature_main/i18n/strings.g.dart';
import 'package:feature_main/src/service_privacy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_ui/widget/wallet_icon.dart';

class MenuItem {
  final String name;
  final IconData icon;
  final VoidCallback? onTap;

  const MenuItem({required this.name, required this.icon, this.onTap});
}

class AboutUs extends ConsumerStatefulWidget {
  final Version version;
  const AboutUs({super.key, required this.version});

  @override
  ConsumerState<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends ConsumerState<AboutUs> {
  final List<MenuItem> items = [
    MenuItem(name: t.Mysettings.officialWebsite, icon: WalletIcon.official),
    MenuItem(name: 'Twitter', icon: WalletIcon.twitter),
    MenuItem(name: 'Telegram', icon: WalletIcon.telegram),
    MenuItem(name: 'Discord', icon: WalletIcon.discord),
    MenuItem(name: t.Mysettings.forum, icon: WalletIcon.forum),
    MenuItem(name: 'Github', icon: WalletIcon.github),
    MenuItem(name: 'Email', icon: WalletIcon.email),
    MenuItem(name: t.Mysettings.rewards, icon: WalletIcon.feedback),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Feedback.forTap(context);
            Navigator.of(context).pop();
          },
          child: Icon(Icons.arrow_back_ios_new, size: 20.w, color: colorScheme.onBackground),
        ),
        title: Text(
          t.Mysettings.about_us,
          style: AppTextStyles.headline4.copyWith(color: colorScheme.onBackground, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: 20.h, right: 16.w, left: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30.h),

                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset("assets/icon/TT_icon.png", fit: BoxFit.cover),
                    ),

                    SizedBox(height: 8.h),
                    Text("TT", style: AppTextStyles.headline2.copyWith(color: colorScheme.onSurface)),
                    Text("${t.Mysettings.currentVersion}: ${widget.version}", style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface)),
                    SizedBox(height: 16.h),

                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      color: colorScheme.surface,
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          ListTile(
                            minVerticalPadding: 0,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                            title: Text(t.Mysettings.appUpdate, style: AppTextStyles.labelLarge.copyWith(color: colorScheme.onBackground)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 15, color: Color(0xFFA3ADAD)),
                            onTap: () {},
                          ),
                          Divider(color: colorScheme.onSurface.withOpacity(.2), height: .5.h, indent: 16.w, endIndent: 16.w),
                          ListTile(
                            minVerticalPadding: 0,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                            title: Text(t.Mysettings.termsAndPrivacy, style: AppTextStyles.labelLarge.copyWith(color: colorScheme.onBackground)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 15, color: Color(0xFFA3ADAD)),
                            onTap: () {
                              Get.to(ServicePrivacy(), transition: Transition.rightToLeft, duration: Duration(milliseconds: 300));
                            },
                          ),
                          Divider(color: colorScheme.onSurface.withOpacity(.2), height: .5.h, indent: 16.w, endIndent: 16.w),
                          ListTile(
                            minVerticalPadding: 0,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                            title: Text(t.Mysettings.rateApp, style: AppTextStyles.labelLarge.copyWith(color: colorScheme.onBackground)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 15, color: Color(0xFFA3ADAD)),
                            onTap: () {},
                          ),
                          Divider(color: colorScheme.onSurface.withOpacity(.2), height: .5.h, indent: 16.w, endIndent: 16.w),
                          ListTile(
                            minVerticalPadding: 0,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                            title: Text(t.Mysettings.changelog, style: AppTextStyles.labelLarge.copyWith(color: colorScheme.onBackground)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 15, color: Color(0xFFA3ADAD)),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 30, bottom: 20),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        t.Mysettings.officialChannels,
                        style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      color: colorScheme.surface,
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: .75,
                        padding: const EdgeInsets.all(12),
                        children: List.generate(items.length, (i) {
                          final item = items[i];
                          return Column(
                            children: [
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(.1),
                                  ),
                                  child: Icon(item.icon, size: 28),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(item.name),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
