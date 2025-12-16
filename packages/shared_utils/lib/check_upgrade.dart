import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_utils/app_config.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdater {
  // ===== 全局锁：防重复检查/弹窗/OTA =====
  static bool _checking = false; // 防止并发 checkUpdate
  static bool _checkedOnce = false; // 本次启动只检查一次（你想每次都检查可改为 false 不设置）
  static bool _dialogShowing = false; // 防止重复弹窗
  static bool _updating = false; // OTA 正在执行中（防止重复 execute）

  static StreamSubscription<OtaEvent>? _otaSub;

  /// 检查更新
  /// force=true：强制检查（比如设置页“检查更新”按钮）
  static Future<void> checkUpdate(BuildContext context, {bool force = false}) async {
    if (!force) {
      if (_checkedOnce) return;
      if (_checking) return;
      if (_dialogShowing) return;
      if (_updating) return;
    }

    _checking = true;
    try {
      // 获取当前版本
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionStr = packageInfo.version;

      // 请求后端接口
      final resp = await http.get(Uri.parse("${AppConfig.apiBaseUrl}/api/wallet/getWalletClientLatestUpdateRecord"));
      if (resp.statusCode != 200) return;

      final body = jsonDecode(resp.body);
      final data = body is Map ? body["result"] : null;
      if (data == null || data is! Map) return;

      debugPrint('$data, responseOat');

      final latestVersionStr = (data["version"] ?? "").toString();
      final updateLog = (data["changeLog"] ?? "").toString();
      final downloadUrl = (data["downloadPath"] ?? "").toString();
      final iosUrl = (data["iosAppStorePath"] ?? "").toString();

      if (latestVersionStr.trim().isEmpty) return;

      Version currentVersion;
      Version latestVersion;
      try {
        currentVersion = Version.parse(currentVersionStr);
        latestVersion = Version.parse(latestVersionStr);
      } catch (_) {
        // 后端或本地版本号不符合 semver 时直接不处理
        return;
      }

      // 标记：本次启动已经检查过（避免每次进入主页都弹）
      if (!force) _checkedOnce = true;

      // 比较版本
      if (latestVersion.compareTo(currentVersion) > 0) {
        if (!context.mounted) return;
        await _showUpdateDialog(context, latestVersion, updateLog, downloadUrl, iosUrl);
      }
    } catch (e) {
      debugPrint("检查更新失败: $e");
    } finally {
      _checking = false;
    }
  }

  /// 显示更新弹窗（防重复弹）
  static Future<void> _showUpdateDialog(BuildContext context, Version version, String log, String androidUrl, String iosUrl) async {
    if (_dialogShowing) return;
    _dialogShowing = true;

    try {
      bool clickedUpdate = false;

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setState) => AlertDialog(
              title: Text("发现新版本 $version"),
              content: Text(log),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("稍后再说", style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: (clickedUpdate || _updating)
                      ? null
                      : () {
                          setState(() => clickedUpdate = true);
                          Navigator.pop(ctx);
                          _doUpdate(androidUrl, iosUrl);
                        },
                  child: const Text("立即更新", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          );
        },
      );
    } finally {
      _dialogShowing = false;
    }
  }

  /// 执行更新逻辑（重点：全局防重复 execute）
  static Future<void> _doUpdate(String androidUrl, String iosUrl) async {
    if (_updating) return;

    if (Platform.isAndroid) {
      if (androidUrl.trim().isEmpty) return;

      _updating = true;

      // 清理旧订阅，避免残留导致状态混乱
      await _otaSub?.cancel();
      _otaSub = null;

      try {
        _otaSub = OtaUpdate()
            .execute(androidUrl, destinationFilename: 'update.apk')
            .listen(
              (event) async {
                debugPrint("OTA 状态: ${event.status}   进度: ${event.value}");

                // 进入 INSTALLING 就说明下载完成并进入安装阶段：
                // 这时候再次 execute 没意义，释放锁即可（避免永远锁住）
                if (event.status == OtaStatus.INSTALLING) {
                  _updating = false;
                  await _otaSub?.cancel();
                  _otaSub = null;
                  return;
                }

                // 错误状态：释放锁
                if (event.status == OtaStatus.DOWNLOAD_ERROR ||
                    event.status == OtaStatus.INTERNAL_ERROR ||
                    event.status == OtaStatus.PERMISSION_NOT_GRANTED_ERROR) {
                  _updating = false;
                  await _otaSub?.cancel();
                  _otaSub = null;
                  return;
                }

                // 理论上不会再出现（因为有 _updating 锁）
                if (event.status == OtaStatus.ALREADY_RUNNING_ERROR) {
                  // 保持锁住，防止你重复点触发
                  _updating = true;
                }
              },
              onError: (e) async {
                debugPrint("OTA listen error: $e");
                _updating = false;
                await _otaSub?.cancel();
                _otaSub = null;
              },
              onDone: () async {
                _updating = false;
                await _otaSub?.cancel();
                _otaSub = null;
              },
            );
      } catch (e) {
        _updating = false;
        debugPrint("OTA 更新失败: $e");
      }
    } else if (Platform.isIOS) {
      if (iosUrl.trim().isEmpty) return;

      final uri = Uri.parse(iosUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}
