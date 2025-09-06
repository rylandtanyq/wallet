import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ota_update/ota_update.dart';
import 'package:pub_semver/pub_semver.dart';

class AppUpdater {
  /// 检查更新
  static Future<void> checkUpdate(BuildContext context) async {
    try {
      // 获取当前版本
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersionStr = packageInfo.version;

      // 请求后端接口
      final response = await http.get(Uri.parse("http://10.0.2.2:3000/version.json"));
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      String latestVersionStr = data["latest_version"];
      String updateLog = data["update_log"];
      String downloadUrl = data["download_url"];
      String iosAppStoreUrl = data["ios_store_url"]; // iOS 跳转地址

      Version currentVersion = Version.parse(currentVersionStr);
      Version latestVersion = Version.parse(latestVersionStr);

      // 简单比较版本
      if (latestVersion.compareTo(currentVersion) > 0) {
        _showUpdateDialog(context, latestVersion, updateLog, downloadUrl, iosAppStoreUrl);
      }
    } catch (e) {
      debugPrint("检查更新失败: $e");
    }
  }

  /// 显示更新弹窗
  static void _showUpdateDialog(BuildContext context, Version version, String log, String androidUrl, String iosUrl) {
    showDialog(
      context: context,
      barrierDismissible: true, // 普通更新，允许取消
      builder: (ctx) => AlertDialog(
        title: Text("发现新版本 $version"),
        content: Text(log),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("稍后再说", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _doUpdate(androidUrl, iosUrl);
            },
            child: const Text("立即更新", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  /// 执行更新逻辑
  static void _doUpdate(String androidUrl, String iosUrl) async {
    if (Platform.isAndroid) {
      try {
        OtaUpdate().execute(androidUrl, destinationFilename: 'update.apk').listen((event) {
          debugPrint("OTA 状态: ${event.status}   进度: ${event.value}");
        });
      } catch (e) {
        debugPrint("OTA 更新失败: $e");
      }
    } else if (Platform.isIOS) {
      if (await canLaunchUrl(Uri.parse(iosUrl))) {
        await launchUrl(Uri.parse(iosUrl), mode: LaunchMode.externalApplication);
      }
    }
  }
}
