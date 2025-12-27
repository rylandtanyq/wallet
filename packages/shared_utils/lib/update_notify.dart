import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class UpdateNotify {
  static final FlutterLocalNotificationsPlugin _noti = FlutterLocalNotificationsPlugin();
  static bool _inited = false;

  static const int _id = 99001;
  static const String _channelId = 'app_update';
  static const String _channelName = 'App Update';
  static const String _channelDesc = 'Download update progress';

  static int _lastProgress = -1;

  static Future<void> init() async {
    if (_inited) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _noti.initialize(initSettings);

    // Android 13+ 运行时通知权限(不给权限=通知栏可能不显示)
    if (Platform.isAndroid) {
      await _noti
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission(); // 官方推荐写法 :contentReference[oaicite:2]{index=2}
    }

    _inited = true;
  }

  static Future<void> showProgress(int progress) async {
    await init();

    final p = progress.clamp(0, 100);
    if (p == _lastProgress) return;
    _lastProgress = p;

    final android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.low,
      priority: Priority.low,

      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,

      // 进度条相关, 直接在构造函数里传
      showProgress: true,
      maxProgress: 100,
      progress: p,
      indeterminate: false,
    );

    await _noti.show(_id, '正在下载更新', '$p%', NotificationDetails(android: android));
  }

  static Future<void> showInstalling() async {
    await init();
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showProgress: true,
      indeterminate: true, // 不确定进度条 :contentReference[oaicite:3]{index=3}
    );
    await _noti.show(_id, '正在安装更新', '请稍候…', const NotificationDetails(android: android));
  }

  static Future<void> showDone() async {
    await init();
    _lastProgress = -1;
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: false,
      autoCancel: true,
    );
    await _noti.show(_id, '更新包已准备好', '点击继续安装/打开安装界面', const NotificationDetails(android: android));
  }

  static Future<void> showError(String msg) async {
    await init();
    _lastProgress = -1;
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: false,
      autoCancel: true,
    );
    await _noti.show(_id, '更新失败', msg, const NotificationDetails(android: android));
  }

  static Future<void> cancel() async {
    _lastProgress = -1;
    await _noti.cancel(_id);
  }
}
