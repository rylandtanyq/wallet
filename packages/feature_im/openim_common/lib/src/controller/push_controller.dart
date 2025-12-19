import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:openim_common/openim_common.dart';

import 'firebase_options.dart';

enum PushType { fcm, getui, none }

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
  // 这里仅记录，真正展示通知需要 flutter_local_notifications
  Logger.print('[FCM][BG] messageId=${message.messageId}', onlyConsole: true);
}

class PushController extends GetxService {
  PushType pushType = Platform.isAndroid ? PushType.fcm : PushType.fcm;

  static void setBadge(int count) {
    Logger.print('[Push] setBadge($count) (noop)', onlyConsole: true);
  }

  static void resetBadge() {
    setBadge(0);
  }

  static PushController get I {
    if (Get.isRegistered<PushController>()) return Get.find<PushController>();
    return Get.put(PushController(), permanent: true);
  }

  /// 登录后绑定推送 token
  static Future<void> login(
    String userId, {
    required void Function(String token) onTokenRefresh,
  }) async {
    final c = PushController.I;

    if (c.pushType == PushType.none) {
      Logger.print('[Push] pushType=none, skip', onlyConsole: true);
      return;
    }

    if (c.pushType == PushType.getui) {
      Logger.print('[Push] getui not implemented', onlyConsole: true);
      return;
    }

    await FCMPushController.I.login(
      userId,
      onTokenRefresh: onTokenRefresh,
    );
  }

  static Future<void> logout() async {
    final c = PushController.I;
    if (c.pushType == PushType.fcm) {
      await FCMPushController.I.logout();
    }
  }
}

class FCMPushController {
  FCMPushController._();
  static final FCMPushController I = FCMPushController._();

  bool _ready = false;
  Future<bool>? _initTask;

  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenSub;

  void Function(RemoteMessage msg)? onForegroundMessage;
  void Function(RemoteMessage msg)? onNotificationOpened;

  Future<void> login(
    String userId, {
    required void Function(String token) onTokenRefresh,
  }) async {
    final ok = await ensureInitialized();
    if (!ok) {
      Logger.print('[FCM] init not available, skip', onlyConsole: true);
      return;
    }

    final token = await _getTokenWithRetry(retries: 3);
    if (token != null && token.isNotEmpty) {
      onTokenRefresh(token);
    } else {
      Logger.print('[FCM] token null/empty', onlyConsole: true);
    }

    await _tokenSub?.cancel();
    _tokenSub = FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      if (t.isNotEmpty) onTokenRefresh(t);
    });
  }

  Future<void> logout() async {
    await _tokenSub?.cancel();
    await _onMessageSub?.cancel();
    await _onOpenSub?.cancel();
    _tokenSub = null;
    _onMessageSub = null;
    _onOpenSub = null;
  }

  Future<bool> ensureInitialized() async {
    if (_ready) return true;

    _initTask ??= () async {
      if (Platform.isAndroid) {
        final availability = await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
        if (availability != GooglePlayServicesAvailability.success) {
          Logger.print('[FCM] Google Play Services not available: $availability', onlyConsole: true);
          return false;
        }
      }

      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e) {
        Logger.print('[FCM] Firebase.initializeApp: $e', onlyConsole: true);
      }

      try {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        Logger.print('[FCM] permission: ${settings.authorizationStatus}', onlyConsole: true);
      } catch (e) {
        Logger.print('[FCM] requestPermission: $e', onlyConsole: true);
      }

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await _onMessageSub?.cancel();
      _onMessageSub = FirebaseMessaging.onMessage.listen((msg) {
        Logger.print('[FCM][FG] messageId=${msg.messageId}', onlyConsole: true);
        onForegroundMessage?.call(msg);
      });

      await _onOpenSub?.cancel();
      _onOpenSub = FirebaseMessaging.onMessageOpenedApp.listen((msg) {
        Logger.print('[FCM][OPEN] messageId=${msg.messageId}', onlyConsole: true);
        onNotificationOpened?.call(msg);
      });

      _ready = true;
      return true;
    }();

    return _initTask!;
  }

  Future<String?> _getTokenWithRetry({int retries = 3}) async {
    int delayMs = 600;

    for (int i = 0; i < retries; i++) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) return token;
      } on FirebaseException catch (e) {
        final msg = (e.message ?? '').toUpperCase();
        Logger.print('[FCM] getToken FirebaseException: ${e.code} ${e.message}', onlyConsole: true);

        final retryable = msg.contains('SERVICE_NOT_AVAILABLE') || msg.contains('EXECUTIONEXCEPTION') || msg.contains('IOEXCEPTION');

        if (!retryable) return null;
      } catch (e) {
        Logger.print('[FCM] getToken error: $e', onlyConsole: true);
        return null;
      }

      await Future.delayed(Duration(milliseconds: delayMs));
      delayMs *= 2;
    }

    return null;
  }
}
