// lib/util/image_cache_repo.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_utils/hive_storage.dart';
import 'package:shared_utils/hive_boxes.dart';

class CachedImage {
  final File file;
  final String? contentType;
  CachedImage(this.file, this.contentType);
}

class ImageCacheRepo {
  ImageCacheRepo._();
  static final ImageCacheRepo I = ImageCacheRepo._();

  late Directory _dir; // /.../Documents/image_cache
  final _hive = HiveStorage();

  // 默认就拉长超时 + 带浏览器 UA
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.bytes,
      followRedirects: true,
      headers: const {'accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8', 'user-agent': 'Mozilla/5.0 (Flutter; like Chrome)'},
      validateStatus: (s) => s != null && s < 400,
    ),
  );

  /// 初始化：放在 main() 里 hive.init 之后调用
  Future<void> init() async {
    final app = await getApplicationDocumentsDirectory();
    _dir = Directory('${app.path}/image_cache');
    if (!await _dir.exists()) {
      await _dir.create(recursive: true);
    }
    await _hive.ensureOpen(boxApp);
  }

  // ================= 对外 API =================

  /// 命中缓存（文件存在 + 元信息存在）
  Future<CachedImage?> getCached(String url) async {
    final k = _key(url);
    final meta = await _hive.getMap<String, dynamic>(_metaKey(k), boxName: boxApp);
    if (meta == null) return null;

    final relPath = meta['relPath'] as String?;
    if (relPath == null) return null;

    final f = File('${_dir.path}/$relPath');
    if (!await f.exists()) return null;

    final ct = meta['ct'] as String?;
    return CachedImage(f, ct);
  }

  /// 下载并落盘（成功才写 meta）——“除 Arweave 外全部走代理”
  Future<CachedImage> fetchAndCache(String url) async {
    final fixedUrl = _fixUrl(url);
    final uri = Uri.parse(fixedUrl);
    debugPrint('[Repo] ENTER fetchAndCache fixed=$fixedUrl');

    Response<Uint8List> resp;

    if (_isArweave(uri)) {
      // Arweave 保留多网关回退（最快最稳）
      resp = await _fetchArweaveWithFallback(uri.toString());
    } else {
      // 其它域名：一律代理（避免直连慢/被拦）
      final target1 = _toProxy(uri, primary: true);
      final target2 = _toProxy(uri, primary: false);

      try {
        debugPrint('[Repo] via proxy1: $target1');
        resp = await _dio.getUri<Uint8List>(target1, options: Options(followRedirects: true)).timeout(const Duration(seconds: 25));
        debugPrint('[Repo] proxy1 ok: status=${resp.statusCode}, ct=${resp.headers.value('content-type')}');
      } on TimeoutException catch (e) {
        debugPrint('[Repo] proxy1 timeout: $e');
        // 尝试备用域名
        resp = await _dio.getUri<Uint8List>(target2, options: Options(followRedirects: true)).timeout(const Duration(seconds: 25));
        debugPrint('[Repo] proxy2 ok: status=${resp.statusCode}, ct=${resp.headers.value('content-type')}');
      } on DioException catch (e) {
        debugPrint('[Repo] proxy1 dio fail: type=${e.type} code=${e.response?.statusCode}');
        // 仍尝试备用域名
        resp = await _dio.getUri<Uint8List>(target2, options: Options(followRedirects: true)).timeout(const Duration(seconds: 25));
        debugPrint('[Repo] proxy2 ok: status=${resp.statusCode}, ct=${resp.headers.value('content-type')}');
      }
    }

    // ==== 落盘 ====
    final bytes = resp.data;
    final ct = (resp.headers.value('content-type') ?? '').toLowerCase();
    final ext = _extFromCt(ct);

    if (!await _dir.exists()) {
      debugPrint('[Repo] cache dir not exist -> ${_dir.path}, creating...');
      await _dir.create(recursive: true);
    }

    final k = _key(url);
    final rel = '$k.$ext';
    final file = File('${_dir.path}/$rel');

    debugPrint('[Repo] will save: path=${file.path}, bytes=${bytes?.length}, ct=$ct');
    try {
      if (bytes == null || bytes.isEmpty) throw Exception('empty-bytes');
      await file.writeAsBytes(bytes, flush: true);
      debugPrint('[Repo] saved OK: ${file.path}');
    } catch (e, st) {
      debugPrint('[Repo] save FAIL: path=${file.path}, err=$e');
      debugPrint('[Repo] stack: $st');
      rethrow;
    }

    await _hive.putMap<String, dynamic>(_metaKey(k), {'relPath': rel, 'ct': ct, 'ts': DateTime.now().millisecondsSinceEpoch}, boxName: boxApp);

    return CachedImage(file, ct);
  }

  /// 先读缓存，没有就下载（失败返回 null，不写入失败结果）
  Future<CachedImage?> getOrFetch(String url) async {
    final c = await getCached(url);
    if (c != null) return c;
    try {
      return await fetchAndCache(url);
    } catch (e) {
      debugPrint('[Repo] getOrFetch FAIL: $url, err=$e');
      return null;
    }
  }

  Future<void> invalidateUrl(String url) async {
    try {
      final k = _key(url);
      final meta = await _hive.getMap<String, dynamic>(_metaKey(k), boxName: boxApp);
      if (meta == null) return;

      final rel = meta['relPath'] as String?;
      if (rel != null) {
        final f = File('${_dir.path}/$rel');
        if (await f.exists()) {
          await f.delete();
        }
      }

      final box = await _hive.getBox(boxName: boxApp);
      if (box is Box) {
        await box.delete(_metaKey(k));
      } else if (box is LazyBox) {
        await (box as LazyBox).delete(_metaKey(k));
      }
    } catch (e) {
      debugPrint('[ImageCacheRepo] invalidateUrl fail: $e');
    }
  }

  /// 仅保留最近 N 条（按 ts 排序）
  Future<void> trim({int keep = 500}) async {
    final box = await _hive.getBox(boxName: boxApp); // Box<dynamic>
    final keys = (box as Box).keys.where((k) => k is String && (k as String).startsWith(_META_PREFIX)).cast<String>().toList();
    if (keys.length <= keep) return;

    final entries = <_MetaEntry>[];
    for (final k in keys) {
      final m = await _hive.getMap<String, dynamic>(k, boxName: boxApp);
      if (m == null) continue;
      entries.add(_MetaEntry(k, m['relPath'] as String?, (m['ts'] as num?)?.toInt() ?? 0));
    }
    entries.sort((a, b) => b.ts.compareTo(a.ts)); // 新在前
    for (final e in entries.skip(keep)) {
      if (e.relPath != null) {
        final f = File('${_dir.path}/${e.relPath}');
        if (await f.exists()) await f.delete();
      }
      await (box as Box).delete(e.key);
    }
  }

  // ================= URL 处理/回退 =================

  String _fixUrl(String raw) {
    var v = raw.trim();
    // ipfs:// → 网关
    if (v.startsWith('ipfs://')) {
      v = v.replaceFirst('ipfs://ipfs/', 'ipfs://');
      final rest = v.substring('ipfs://'.length);
      v = 'https://ipfs.io/ipfs/$rest';
    }
    // jito metadata → /image
    final u2 = Uri.tryParse(v);
    if (u2 != null && u2.host.contains('metadata.jito.network')) {
      final seg = u2.pathSegments;
      if (seg.length >= 2 && seg[0] == 'token') {
        final id = seg[1];
        if (!(seg.length >= 3 && seg[2] == 'image')) {
          v = u2.replace(path: '/token/$id/image').toString();
        }
      }
    }
    return v;
  }

  bool _isArweave(Uri u) => u.host.contains('arweave');

  // 直连 arweave 的多网关并发回退
  Future<Response<Uint8List>> _fetchArweaveWithFallback(String urlOrId) async {
    String id;
    if (!urlOrId.contains('://') && urlOrId.length > 40) {
      id = urlOrId;
    } else {
      final u = Uri.parse(urlOrId);
      id = (u.pathSegments.isNotEmpty) ? u.pathSegments.first : '';
    }
    if (id.isEmpty) {
      throw Exception('bad arweave: $urlOrId');
    }

    final endpoints = ['https://arweave.net/$id', 'https://ar-io.net/$id', 'https://gateway.irys.xyz/$id'];

    Object? lastErr;
    final tokens = <CancelToken>[];
    Response<Uint8List>? win;

    final futures = endpoints.map((e) {
      final t = CancelToken();
      tokens.add(t);
      return _dio
          .get<Uint8List>(e, cancelToken: t)
          .then((resp) {
            win ??= resp;
            for (final c in tokens) {
              if (!c.isCancelled) c.cancel('win');
            }
            return resp;
          })
          .catchError((e) {
            lastErr = e;
            throw e;
          });
    }).toList();

    try {
      await Future.any(futures);
    } catch (_) {}
    if (win != null) return win!;
    for (final e in endpoints) {
      try {
        return await _dio.get<Uint8List>(e);
      } catch (err) {
        lastErr = err;
      }
    }
    throw lastErr ?? Exception('all arweave failed');
  }

  /// 把任意 http/https 目标转成代理 URL
  Uri _toProxy(Uri origin, {required bool primary}) {
    final base = primary ? 'https://images.weserv.nl/' : 'https://wsrv.nl/';
    return Uri.parse(base).replace(
      queryParameters: {
        'url': origin.toString(),
        'n': '-1', // 不做额外优化（可按需调整）
      },
    );
  }

  // ================= 工具 =================

  static const _META_PREFIX = 'col_image_meta_';

  String _metaKey(String k) => '$_META_PREFIX$k';
  String _key(String url) => sha1.convert(utf8.encode(url)).toString();

  String _extFromCt(String? ct) {
    if (ct == null) return 'bin';
    if (ct.contains('svg')) return 'svg';
    if (ct.contains('png')) return 'png';
    if (ct.contains('jpeg') || ct.contains('jpg')) return 'jpg';
    if (ct.contains('gif')) return 'gif';
    if (ct.contains('webp')) return 'webp';
    return 'bin';
  }
}

class _MetaEntry {
  final String key;
  final String? relPath;
  final int ts;
  _MetaEntry(this.key, this.relPath, this.ts);
}
