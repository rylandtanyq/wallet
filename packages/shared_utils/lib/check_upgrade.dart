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
  static bool _checking = false;
  static bool _checkedOnce = false; // 本次启动只检查一次（需要每次进入主页都检查就关掉它）
  static bool _dialogShowing = false;
  static bool _updating = false;

  static StreamSubscription<OtaEvent>? _otaSub;
  static Timer? _otaTimeout;

  /// 检查更新
  /// force=true：强制检查（比如“设置页-检查更新”按钮）
  static Future<void> checkUpdate(BuildContext context, {bool force = false}) async {
    if (!force) {
      if (_checkedOnce) return;
      if (_checking) return;
      if (_dialogShowing) return;
      if (_updating) return;
    }

    _checking = true;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionStr = packageInfo.version;

      final resp = await http.get(Uri.parse("${AppConfig.apiBaseUrl}/api/wallet/getWalletClientLatestUpdateRecord"));
      if (resp.statusCode != 200) return;

      final body = jsonDecode(resp.body);
      final data = body is Map ? body["result"] : null;
      if (data is! Map) return;

      debugPrint('$data, responseOat');

      final latestVersionStr = (data["version"] ?? "").toString().trim();
      final updateLog = (data["changeLog"] ?? "").toString();
      final downloadUrl = (data["downloadPath"] ?? "").toString().trim();
      final iosUrl = (data["iosAppStorePath"] ?? "").toString().trim();

      // 可选：后端提供 sha256 用于完整性校验（强烈建议加）
      final sha256 = (data["sha256"] ?? "").toString().trim();

      if (latestVersionStr.isEmpty || downloadUrl.isEmpty) return;

      Version currentVersion;
      Version latestVersion;
      try {
        currentVersion = Version.parse(currentVersionStr);
        latestVersion = Version.parse(latestVersionStr);
      } catch (_) {
        // 版本号不符合 semver，直接跳过
        return;
      }

      if (!force) _checkedOnce = true;

      if (latestVersion > currentVersion) {
        await _showUpdateDialog(context, latestVersion: latestVersion, log: updateLog, androidUrl: downloadUrl, iosUrl: iosUrl, sha256: sha256);
      }
    } catch (e) {
      debugPrint("检查更新失败: $e");
    } finally {
      _checking = false;
    }
  }

  /// 显示更新弹窗（防重复弹）
  static Future<void> _showUpdateDialog(
    BuildContext context, {
    required Version latestVersion,
    required String log,
    required String androidUrl,
    required String iosUrl,
    required String sha256,
  }) async {
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
              title: Text("发现新版本 $latestVersion"),
              content: Text(log.isEmpty ? "发现新版本，建议立即更新。" : log),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("稍后再说", style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: (clickedUpdate || _updating)
                      ? null
                      : () async {
                          setState(() => clickedUpdate = true);
                          Navigator.pop(ctx);
                          await _doUpdate(latestVersion: latestVersion, androidUrl: androidUrl, iosUrl: iosUrl, sha256: sha256);
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
  static Future<void> _doUpdate({required Version latestVersion, required String androidUrl, required String iosUrl, required String sha256}) async {
    if (_updating) return;

    if (Platform.isAndroid) {
      if (androidUrl.trim().isEmpty) return;

      _updating = true;

      // 兜底：避免某些 ROM 卡住不回调导致永远锁死
      _otaTimeout?.cancel();
      _otaTimeout = Timer(const Duration(minutes: 15), () async {
        debugPrint("OTA 超时兜底：释放锁，允许重新点击更新");
        _updating = false;
        await _otaSub?.cancel();
        _otaSub = null;
      });

      // 清理旧订阅
      await _otaSub?.cancel();
      _otaSub = null;

      // 关键：用“带版本号”的文件名，避免复用 update.apk 产生残留/续传导致进度错乱
      final safeVer = latestVersion.toString().replaceAll('.', '_');
      final filename = 'update_$safeVer.apk';

      try {
        _otaSub = OtaUpdate()
            .execute(
              androidUrl,
              destinationFilename: filename,
              // 强烈建议：后端提供 sha256，防止半包/篡改包进入安装
              // 插件会对下载文件计算 sha256 并对比，不一致会报错而不是安装
              sha256checksum: sha256.isEmpty ? null : sha256,
            )
            .listen(
              (event) async {
                debugPrint("OTA 状态: ${event.status}   进度: ${event.value}");

                // 注意：event.value 的百分比可能因为服务端 Content-Length 不准而不准确
                // INSTALLING 代表“已触发安装”，不要在这里 cancel/释放锁（让 onDone/onError 统一收尾）
                if (event.status == OtaStatus.DOWNLOAD_ERROR ||
                    event.status == OtaStatus.INTERNAL_ERROR ||
                    event.status == OtaStatus.PERMISSION_NOT_GRANTED_ERROR) {
                  _finishOta();
                  return;
                }

                // 防止重复触发（理论上有锁不会再来）
                if (event.status == OtaStatus.ALREADY_RUNNING_ERROR) {
                  _updating = true;
                }
              },
              onError: (e) {
                debugPrint("OTA listen error: $e");
                _finishOta();
              },
              onDone: () {
                _finishOta();
              },
            );
      } catch (e) {
        debugPrint("OTA 更新失败: $e");
        _finishOta();
      }
    } else if (Platform.isIOS) {
      if (iosUrl.trim().isEmpty) return;
      final uri = Uri.parse(iosUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  static void _finishOta() {
    _otaTimeout?.cancel();
    _otaTimeout = null;

    _updating = false;

    _otaSub?.cancel();
    _otaSub = null;
  }
}
