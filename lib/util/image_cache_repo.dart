import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:untitled1/constants/hive_boxes.dart';
import 'package:untitled1/util/HiveStorage.dart';

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
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
      responseType: ResponseType.bytes,
      followRedirects: true,
      headers: const {'accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8', 'user-agent': 'Mozilla/5.0 (Flutter; like Chrome)'},
      validateStatus: (s) => s != null && s < 400,
    ),
  );

  /// 初始化：放在 main() 里 hive.init 之后调用
  Future<void> init() async {
    // 目录
    final app = await getApplicationDocumentsDirectory();
    _dir = Directory('${app.path}/image_cache');
    if (!await _dir.exists()) {
      await _dir.create(recursive: true);
    }
    // 确保 appData 箱已开
    await _hive.ensureOpen(boxApp);
  }

  // ============ 对外 API ============

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

  /// 下载并落盘（成功才写 meta）
  Future<CachedImage> fetchAndCache(String url) async {
    final fixedUrl = _fixUrl(url);
    final uri = Uri.parse(fixedUrl);

    Response<Uint8List> resp;
    if (_isArweave(uri)) {
      resp = await _fetchArweaveWithFallback(uri.toString());
    } else {
      resp = await _dio.getUri<Uint8List>(uri);
    }

    final bytes = resp.data;
    final ct = (resp.headers.value('content-type') ?? '').toLowerCase();
    final ext = _extFromCt(ct);

    final k = _key(url);
    final rel = '$k.$ext';
    final file = File('${_dir.path}/$rel');
    await file.writeAsBytes(bytes!, flush: true);

    await _hive.putMap<String, dynamic>(_metaKey(k), {'relPath': rel, 'ct': ct, 'ts': DateTime.now().millisecondsSinceEpoch}, boxName: boxApp);

    return CachedImage(file, ct);
  }

  /// 先读缓存，没有就下载（失败返回 null，不写入失败结果）
  Future<CachedImage?> getOrFetch(String url) async {
    final c = await getCached(url);
    if (c != null) return c;
    try {
      return await fetchAndCache(url);
    } catch (_) {
      return null;
    }
  }

  Future<void> invalidateUrl(String url) async {
    try {
      final k = _key(url);
      final meta = await _hive.getMap<String, dynamic>(_metaKey(k), boxName: boxApp);
      if (meta == null) return;

      // 删磁盘文件
      final rel = meta['relPath'] as String?;
      if (rel != null) {
        final f = File('${_dir.path}/$rel');
        if (await f.exists()) {
          await f.delete();
        }
      }

      // 删 meta
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

  /// 简单清理：仅保留最近 N 条（按 ts 排序）
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

  // ============ URL 修正/回退 ============

  String _fixUrl(String raw) {
    var v = raw.trim();
    // ipfs:// → https 网关
    if (v.startsWith('ipfs://')) {
      v = v.replaceFirst('ipfs://ipfs/', '');
      v = v.replaceFirst('ipfs://', '');
      v = 'https://ipfs.io/ipfs/$v';
    }
    // jito 元数据补 /image
    final u = Uri.tryParse(v);
    if (u != null && u.host.contains('metadata.jito.network')) {
      final seg = u.pathSegments;
      if (seg.length >= 2 && seg[0] == 'token') {
        final id = seg[1];
        if (!(seg.length >= 3 && seg[2] == 'image')) {
          v = u.replace(path: '/token/$id/image').toString();
        }
      }
    }
    return v;
  }

  bool _isArweave(Uri u) => u.host.contains('arweave');

  Future<Response<Uint8List>> _fetchArweaveWithFallback(String urlOrId) async {
    // 提取 id
    String id;
    if (!urlOrId.contains('://') && urlOrId.length > 40) {
      id = urlOrId;
    } else {
      final u = Uri.parse(urlOrId);
      id = (u.pathSegments.isNotEmpty) ? u.pathSegments.first : '';
    }
    if (id.isEmpty) throw Exception('bad arweave: $urlOrId');

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

  // ============ 工具 ============

  static const _META_PREFIX = 'col_image_meta_'; // 统一存 boxApp 里

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
