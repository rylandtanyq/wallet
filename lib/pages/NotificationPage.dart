import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:badges/badges.dart' as badges;
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/theme/app_textStyle.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          focusColor: Colors.transparent,
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Theme(
          data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory, highlightColor: Colors.transparent),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).colorScheme.onBackground,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
            labelColor: Theme.of(context).colorScheme.onBackground,
            dividerColor: Colors.transparent,
            labelPadding: EdgeInsets.symmetric(horizontal: 12),
            labelStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            tabs: [
              Tab(
                child: Text(
                  t.common.system_notifications,
                  style: TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: Text(t.common.message_notifications, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false)),
                    SizedBox(width: 4.w),
                    badges.Badge(
                      badgeContent: Text(
                        '3',
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 10.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      badgeStyle: badges.BadgeStyle(
                        badgeColor: Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 13.w),
            padding: EdgeInsets.symmetric(horizontal: 4),
            width: 47.w,
            height: 20.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.r),
              border: Border.all(color: Theme.of(context).colorScheme.onSurface),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/read.png', width: 11.w, height: 8.h),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      t.common.mark_as_read,
                      style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: TabBarView(controller: _tabController, children: [_transactionNotification(context), _systemMessages(context)]),
    );
  }
}

/// 系统消息
Widget _systemMessages(BuildContext context) {
  return Padding(
    padding: EdgeInsetsGeometry.symmetric(horizontal: 12.w),
    child: ListView.separated(
      itemBuilder: (BuildContext buildContext, int index) {
        return SizedBox(
          width: 350.w,
          height: 135.h,
          child: Card(
            child: Padding(
              padding: EdgeInsetsGeometry.only(left: 12.w, right: 12.w, top: 16.h),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          "超值!热门游戏储值享高sssssssssssssssssssssssssssssssssssssssssssssssss达 30% 的折扣!",
                          style: AppTextStyles.size15.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, borderRadius: BorderRadius.circular(25)),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "PUBG、Free Fire、ML游戏储值4步搞定，轻松省下大把银子。马上点击，立享超值福利!",
                    style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 9.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("05-04 20:01", style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          fixedSize: Size(85.w, 30.h),
                          side: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
                        ),
                        child: Text(
                          t.common.view_details,
                          style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.primary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext buildContext, int index) {
        return SizedBox(height: 12.h);
      },
      itemCount: 10,
    ),
  );
}

/// 交易通知
Widget _transactionNotification(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(flex: 2),
        Image.asset("assets/images/bell.png", width: 97, height: 103.h),
        SizedBox(height: 10.h),
        Text(
          t.common.no_messages,
          // style: TextStyle(fontSize: 19.sp, color: Colors.black, fontWeight: FontWeight.bold),
          style: AppTextStyles.size19.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
          child: Text(
            t.common.join_telegram_prompt,
            style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 26.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/Twitter_1.png", width: 34.w, height: 34.h),
            Image.asset("assets/images/Telgram.png", width: 34.w, height: 34.h),
            Image.asset("assets/images/facebook.png", width: 34.w, height: 34.h),
            Image.asset("assets/images/discord.png", width: 34.w, height: 34.h),
          ],
        ),
        Spacer(flex: 3),
      ],
    ),
  );
}
