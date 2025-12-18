import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../widgets/upgrade_view.dart';
import '../widgets/upgrade_server_view.dart';

mixin UpgradeManger {
  PackageInfo? packageInfo;
  UpgradeInfoV2? upgradeInfoV2;
  UpgradeInfoByServer? upgradeInfoByServer;
  var isShowUpgradeDialog = false;
  var isNowIgnoreUpdate = false;
  final subject = PublishSubject<double>();
  final notificationService = NotificationService();

  void closeSubject() {
    subject.close();
  }

  void ignoreUpdate() {
    DataSp.putIgnoreVersion(
        upgradeInfoV2!.buildVersion! + upgradeInfoV2!.buildVersionNo!);
    Get.back();
  }

  void ignoreUpdateNew() {
    DataSp.putIgnoreVersion(upgradeInfoByServer!.version!);
    Get.back();
  }

  void laterUpdate() {
    isNowIgnoreUpdate = true;
    Get.back();
  }

  void laterUpdateNew() {
    isNowIgnoreUpdate = true;
    Get.back();
  }

  getAppInfo() async {
    packageInfo ??= await PackageInfo.fromPlatform();
  }

  void nowUpdate() async {
    final appUrl = upgradeInfoV2?.appURl;

    if (appUrl != null && await canLaunchUrlString(appUrl)) {
      launchUrlString(appUrl);
      return;
    }
  }

  void nowUpdateNew() async {
    print("获取更新地址");
    final appUrl = upgradeInfoByServer?.url;

    if (appUrl != null && await canLaunchUrlString(appUrl)) {
      launchUrlString(appUrl);
      return;
    }
  }

  void checkUpdate() async {
    LoadingView.singleton.wrap(asyncFunction: () async {
      await getAppInfo();
      return Apis.checkUpgradeV2();
    }).then((value) {
      upgradeInfoV2 = value;
      if (!canUpdate) {
        IMViews.showToast('已是最新版本');
        return;
      }
      Get.dialog(
        UpgradeViewV2(
          upgradeInfo: upgradeInfoV2!,
          packageInfo: packageInfo!,
          onNow: nowUpdate,
          subject: subject,
        ),
        routeSettings: const RouteSettings(name: 'upgrade_dialog'),
      );
    });
  }

  void checkUpdateNew() async {
    LoadingView.singleton.wrap(asyncFunction: () async {
      await getAppInfo();
      String platform = "";
      if (Platform.isAndroid) {
        platform = "flutter_android";
      }
      if (Platform.isIOS) {
        platform = "flutter_ios";
      }
      return Apis.checkUpgradeByServer(
          platform: platform, version: packageInfo!.version!);
    }).then((value) {
      upgradeInfoByServer = value;
      if (!canUpdateNew) {
        IMViews.showToast('已是最新版本');
        return;
      }
      Get.dialog(
        UpgradeServerView(
          upgradeInfoByServer: upgradeInfoByServer!,
          packageInfo: packageInfo!,
          onNow: nowUpdateNew,
          subject: subject,
        ),
        routeSettings: const RouteSettings(name: 'upgrade_dialog'),
      );
    });
  }

  /// 自动检测更新
  autoCheckVersionUpgrade() async {
    if (isShowUpgradeDialog || isNowIgnoreUpdate) return;
    await getAppInfo();
    upgradeInfoV2 = await Apis.checkUpgradeV2();
    // String? ignore = DataSp.getIgnoreVersion();
    // if (ignore == upgradeInfoV2!.buildVersion! + upgradeInfoV2!.buildVersionNo!) {
    //   isNowIgnoreUpdate = true;
    //   return;
    // }
    if (!canUpdate) return;
    isShowUpgradeDialog = true;
    Get.dialog(
      UpgradeViewV2(
        upgradeInfo: upgradeInfoV2!,
        packageInfo: packageInfo!,
        onLater: laterUpdate,
        onIgnore: ignoreUpdate,
        onNow: nowUpdate,
        subject: subject,
      ),
      routeSettings: const RouteSettings(name: 'upgrade_dialog'),
    ).whenComplete(() => isShowUpgradeDialog = false);
  }

  /// 自动检测更新
  autoCheckVersionUpgradeByServer() async {
    if (isShowUpgradeDialog || isNowIgnoreUpdate) return;
    await getAppInfo();
    String platform = "";
    if (Platform.isAndroid) {
      platform = "flutter_android";
    }
    if (Platform.isIOS) {
      platform = "flutter_ios";
    }
    upgradeInfoByServer = await Apis.checkUpgradeByServer(
        platform: platform, version: packageInfo!.version);
    if (!canUpdateNew) return;
    isShowUpgradeDialog = true;
    Get.dialog(
      UpgradeServerView(
        upgradeInfoByServer: upgradeInfoByServer!,
        packageInfo: packageInfo!,
        onLater: laterUpdateNew,
        onIgnore: ignoreUpdateNew,
        onNow: nowUpdateNew,
        subject: subject,
      ),
      routeSettings: const RouteSettings(name: 'upgrade_dialog'),
    ).whenComplete(() => isShowUpgradeDialog = false);
  }

  bool get canUpdateNew =>
      packageInfo!.version != upgradeInfoByServer!.version!;
  bool get canUpdate =>
      packageInfo!.version + packageInfo!.buildNumber !=
      upgradeInfoV2!.buildVersion! + upgradeInfoV2!.buildVersionNo!;
}

class NotificationService {
  // Handle displaying of notifications.
  static final NotificationService _notificationService =
      NotificationService._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings _androidInitializationSettings =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal() {
    if (Platform.isAndroid) {
      init();
    }
  }

  void init() async {
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: _androidInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future createNotification(int count, int i, int id, String status) async {
    //show the notifications.
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'progress channel', 'progress channel',
        channelDescription: 'progress channel description',
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
        showProgress: true,
        maxProgress: count,
        progress: i);
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin
        .show(id, status, '$i%', platformChannelSpecifics, payload: 'item x');

    return;
  }
}
