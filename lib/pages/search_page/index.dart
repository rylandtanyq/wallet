import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/pages/dapp_page/index.dart';
import 'package:untitled1/theme/app_textStyle.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late TabController _tabController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _debounce?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            GestureDetector(onTap: () => Navigator.of(context).pop(), child: Icon(Icons.arrow_back_ios)),
            SizedBox(width: 10.w),
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: t.search.placeholder,
                  hintStyle: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: EdgeInsets.only(right: 14),
                  border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(25.r)),
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onBackground),
                ),
                onChanged: (e) => _onSearchChange(e),
              ),
            ),
            SizedBox(width: 13.w),
            Text(t.search.search, style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
          ],
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: EdgeInsetsGeometry.only(right: 12.w, left: 12.w, top: 8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.search.hotSearch,
                  style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 12.w),
                Theme(
                  data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory, highlightColor: Colors.transparent),
                  child: IntrinsicWidth(
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: Theme.of(context).colorScheme.onBackground,
                      indicatorPadding: EdgeInsets.only(bottom: -6),
                      indicatorSize: TabBarIndicatorSize.label,
                      unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                      labelColor: Theme.of(context).colorScheme.onBackground,
                      padding: EdgeInsets.zero,
                      labelPadding: EdgeInsets.only(right: 22.w),
                      labelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
                      unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
                      dividerColor: Colors.transparent,
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                      tabs: [Text(t.search.token), Text(t.search.contract), Text(t.search.dapp)],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildCurrencyWidget(), _buildContractWidget(context), _buildDAppWidget()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSearchChange(e) {
    if (_debounce?.isActive ?? false) return _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () {
      debugPrint(e);
    });
  }
}

Color _handleColor(BuildContext context, int index) {
  switch (index) {
    case 1:
      return Color(0xFFF3607B);
    case 2:
      return Color(0xFFFE8300);
    case 3:
      return Color(0xFFFEB101);
    default:
      return Theme.of(context).colorScheme.onSurface.withOpacity(.5);
  }
}

Widget? _handleAssetImage(int index) {
  switch (index) {
    case 1:
      return Image.asset("assets/images/fiery_first.png");
    case 2:
      return Image.asset("assets/images/fiery_second.png");
    case 3:
      return Image.asset("assets/images/fiery_third.png");
    default:
      return null;
  }
}

/// 币种
Widget _buildCurrencyWidget() {
  return ListView.separated(
    itemBuilder: (BuildContext context, int index) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(top: 7),
            width: 20,
            height: 50,
            child: Column(
              mainAxisAlignment: _handleAssetImage(index + 1) != null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
              children: [
                ?_handleAssetImage(index + 1),
                Text(
                  "${index + 1}",
                  style: AppTextStyles.labelMedium.copyWith(color: _handleColor(context, index + 1), fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Image.asset("assets/images/ETH.png", width: 50, height: 50),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("VIRTUAL", style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                Text('Virtual Protocol', style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("\$1.7000000000", style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
              Text(
                "+3.62%",
                style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(width: 20),
          Icon(Icons.star, color: Theme.of(context).colorScheme.onSurface.withOpacity(.4)),
        ],
      );
    },
    separatorBuilder: (BuildContext context, int index) {
      return SizedBox(height: 20.h);
    },
    itemCount: 30,
  );
}

/// 合约
Widget _buildContractWidget(BuildContext context) {
  return GestureDetector(
    onTap: () async {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true, // 👈 必须加这个，允许内容超出默认高度
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SafeArea(
                child: Material(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
                          child: Stack(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [Text("签名信息", style: AppTextStyles.headline3.copyWith(color: Theme.of(context).colorScheme.onBackground))],
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Icon(Icons.close, size: 28, color: Theme.of(context).colorScheme.onBackground),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: const Color(0xFFE7E7E7), height: .5.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('请求签名', style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                              SizedBox(height: 8.w),

                              Text.rich(
                                TextSpan(
                                  text: "来自 ",
                                  style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                                  children: [
                                    TextSpan(
                                      text: "wpos.pro",
                                      style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onBackground),
                                    ),
                                    TextSpan(
                                      text: " 的请求",
                                      style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.w),
                              Container(
                                width: double.infinity,
                                height: 200,
                                padding: EdgeInsetsDirectional.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "Verify address authority",
                                  style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                                ),
                              ),
                              SizedBox(height: 16.w),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Wallet", style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                                  Row(
                                    children: [
                                      Image.asset('assets/images/ic_clip_photo.png', width: 20, height: 20),
                                      SizedBox(width: 8.w),
                                      Text("我的钱包", style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.w),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Network", style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                                  Row(
                                    children: [
                                      Image.asset('assets/images/solana_logo.png', width: 20, height: 20),
                                      SizedBox(width: 8.w),
                                      Text("Solana", style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.w),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: Container(
                                        width: double.infinity,
                                        height: 60,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 1, color: Theme.of(context).colorScheme.onBackground),
                                          borderRadius: BorderRadius.circular(50.r),
                                        ),
                                        child: Text("取消", style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 30.w),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 60,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary,
                                          // border: Border.all(width: 1, color: Theme.of(context).colorScheme.onBackground),
                                          borderRadius: BorderRadius.circular(50.r),
                                        ),
                                        child: Text("签名", style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
    },
    child: Text("aasds"),
  );
}

/// DApp
Widget _buildDAppWidget() {
  return ListView.separated(
    itemBuilder: (BuildContext context, int index) {
      return GestureDetector(
        onTap: () {
          Get.to(DAppPage(), transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(top: 7),
              width: 20,
              height: 50,
              child: Column(
                mainAxisAlignment: _handleAssetImage(index + 1) != null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                children: [
                  ?_handleAssetImage(index + 1),
                  Text(
                    "${index + 1}",
                    style: AppTextStyles.labelMedium.copyWith(color: _handleColor(context, index + 1), fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Image.asset("assets/images/ETH.png", width: 50, height: 50),
            SizedBox(width: 10),
            Expanded(
              child: Text("VIRTUAL", style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
            ),
          ],
        ),
      );
    },
    separatorBuilder: (BuildContext context, int index) {
      return SizedBox(height: 20.h);
    },
    itemCount: 10,
  );
}
