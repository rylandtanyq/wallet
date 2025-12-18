import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_common/src/utils/api_service.dart';
import 'package:path_provider/path_provider.dart';

class Config {
  //初始化全局信息
  static Future init(Function() runApp) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      final path = (await getApplicationDocumentsDirectory()).path;
      cachePath = '$path/';
      await DataSp.init();
      await Hive.initFlutter(path);
      MediaKit.ensureInitialized();
      HttpUtil.init();
      ApiService().setBaseUrl(serverIp);
    } catch (_) {}

    runApp();

    // 设置屏幕方向
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 状态栏透明（Android）
    var brightness = Platform.isAndroid ? Brightness.dark : Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: brightness,
      statusBarIconBrightness: brightness,
    ));
  }

  static late String cachePath;
  static const uiW = 375.0;
  static const uiH = 812.0;

  /// 全局字体size
  static const double textScaleFactor = 1.0;

  static const discoverPageURL = 'https://docs.openim.io/';
  static const financePageURL = 'https://wap.eastmoney.com/kuaixun/index.html';
  static const allowSendMsgNotFriend = '1';

  ///务必更换为自己aMap的key
  static const webKey = '75a0da9ec836d573102999e99abf4650';
  static const webServerKey = '835638634b8f9b4bba386eeec94aa7df';
  static const locationHost = 'http://location.rentsoft.cn';

  /// 离线消息默认类型
  static OfflinePushInfo offlinePushInfo = OfflinePushInfo(
    title: StrRes.offlineMessage,
    desc: "",
    iOSBadgeCount: true,
  );

  /// 二维码：scheme
  static const friendScheme = "io.openim.app/addFriend/";
  static const groupScheme = "io.openim.app/joinGroup/";

  /// ip
  /// web.rentsoft.cn
  // static const _host = "web.openim.io";
  static const _host = "chat.28911.top";

  static const _ipRegex =
      '((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)';

  static bool get _isIP => RegExp(_ipRegex).hasMatch(_host);

  /// 服务器IP
  static String get serverIp {
    String? ip;
    var server = DataSp.getServerConfig();
    if (null != server) {
      ip = server['serverIP'];
      Logger.print('缓存serverIP: $ip');
    }
    return ip ?? _host;
  }

  /// 商业版管理后台
  /// $apiScheme://$host/complete_admin/
  /// $apiScheme://$host:10009
  static String get chatTokenUrl {
    String? url;
    var server = DataSp.getServerConfig();
    if (null != server) {
      url = server['chatTokenUrl'];
      Logger.print('缓存chatTokenUrl: $url');
    }
    return url ?? (_isIP ? "http://$_host:10009" : "http://$_host/chat");
  }

  /// 登录注册手机验 证服务器地址
  /// $apiScheme://$host/chat/
  /// $apiScheme://$host:60008
  static String get appAuthUrl {
    String? url;
    var server = DataSp.getServerConfig();
    if (null != server) {
      url = server['authUrl'];
      Logger.print('缓存authUrl: $url');
    }
    return url ?? (_isIP ? "http://$_host:10008" : "http://$_host/chat");
  }

  /// IM sdk api地址
  /// $apiScheme://$host/api/
  /// $apiScheme://$host:50002
  static String get imApiUrl {
    String? url;
    var server = DataSp.getServerConfig();
    if (null != server) {
      url = server['apiUrl'];
      Logger.print('缓存apiUrl: $url');
    }
    return url ?? (_isIP ? 'http://$_host:10002' : "http://$_host/api");
  }

  /// IM ws 地址
  /// $socketScheme://$host/msg_gateway
  /// $socketScheme://$host:50001
  static String get imWsUrl {
    String? url;
    var server = DataSp.getServerConfig();
    if (null != server) {
      url = server['wsUrl'];
      Logger.print('缓存wsUrl: $url');
    }
    return url ?? (_isIP ? "ws://$_host:10001" : "ws://$_host/msg_gateway");
  }

  static int get logLevel {
    String? level;
    var server = DataSp.getServerConfig();
    if (null != server) {
      level = server['logLevel'];
      Logger.print('logLevel: $level');
    }
    return level == null ? 5 : int.parse(level);
  }
}
