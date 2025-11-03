import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untitled1/util/arweave_gateway.dart';
import 'package:untitled1/util/image_cache_repo.dart';

class TokenIcon extends StatelessWidget {
  final String? image;
  final double size;
  final Widget? placeholder;

  const TokenIcon(this.image, {super.key, this.size = 40, this.placeholder});

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
      headers: const {'accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8', 'user-agent': 'Mozilla/5.0 (Flutter; like Chrome)'},
    ),
  );

  @override
  Widget build(BuildContext context) {
    final s = (image ?? '').trim();
    if (s.isEmpty) return _ph();

    // asset
    if (s.startsWith('assets/')) {
      return Image.asset(s, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _ph());
    }

    // data:base64
    if (s.startsWith('data:image/')) {
      final comma = s.indexOf(',');
      if (comma > 0) {
        try {
          final b64 = s.substring(comma + 1);
          final bytes = base64.decode(b64);
          return Image.memory(bytes, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _ph());
        } catch (_) {}
      }
      return _ph();
    }

    // 本地文件
    if (s.startsWith('file://') || s.startsWith('/')) {
      try {
        final file = s.startsWith('file://') ? File(Uri.parse(s).path) : File(s);
        if (file.existsSync()) {
          return Image.file(file, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _ph());
        }
      } catch (_) {}
      return _ph();
    }

    // 网络
    final raw = _normalizeIpfs(s);
    final uri = Uri.tryParse(raw);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) return _ph();
    final fixed = _fixJitoImageUri(uri);

    // arweave 走多网关回退，否则普通下载
    final Future<Response<Uint8List>> future = fixed.host.contains('arweave')
        ? fetchArweaveWithFallback(fixed.toString())
        : _dio.getUri<Uint8List>(
            fixed,
            options: Options(responseType: ResponseType.bytes, followRedirects: true, validateStatus: (s) => s != null && s < 400),
          );

    final url = s;

    return FutureBuilder<CachedImage?>(
      future: ImageCacheRepo.I.getOrFetch(url),
      builder: (context, snap) {
        final data = snap.data;
        if (data != null) {
          final ct = (data.contentType ?? '').toLowerCase();
          if (ct.contains('svg')) {
            return FutureBuilder<Uint8List>(
              future: data.file.readAsBytes(),
              builder: (c, s) {
                if (!s.hasData) return _ph();
                return SvgPicture.memory(s.data!, width: size, height: size, placeholderBuilder: (_) => _ph());
              },
            );
          }
          return Image.file(data.file, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _ph());
        }
        // 加载中/失败 → 占位（加载完成会自动重建显示本地文件）
        return _ph();
      },
    );
  }

  Widget _ph() => placeholder ?? Image.asset('assets/images/solana_logo.png', width: size, height: size);

  // ipfs:// → https://ipfs.io/ipfs/...
  String _normalizeIpfs(String url) {
    var v = url;
    if (v.startsWith('ipfs://')) {
      v = v.replaceFirst('ipfs://ipfs/', '');
      v = v.replaceFirst('ipfs://', '');
      v = 'https://ipfs.io/ipfs/$v';
    }
    return v;
  }

  // https://metadata.jito.network/token/{id} → /token/{id}/image
  Uri _fixJitoImageUri(Uri uri) {
    if (uri.host.contains('metadata.jito.network')) {
      final seg = uri.pathSegments;
      if (seg.length >= 2 && seg[0] == 'token') {
        final id = seg[1];
        if (!(seg.length >= 3 && seg[2] == 'image')) {
          return uri.replace(path: '/token/$id/image');
        }
      }
    }
    return uri;
  }

  bool _looksLikeSvg(Uint8List bytes) {
    final n = bytes.length > 2048 ? 2048 : bytes.length;
    if (n == 0) return false;
    final head = utf8.decode(bytes.sublist(0, n), allowMalformed: true).toLowerCase();
    return head.contains('<svg');
  }

  bool _looksLikeRaster(Uint8List b) {
    if (b.length < 12) return false;
    const png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    if (_eq(b, 0, png)) return true; // PNG
    if (b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) return true; // JPEG
    if (b.length >= 6 && b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x38 && (b[4] == 0x37 || b[4] == 0x39) && b[5] == 0x61)
      return true; // GIF
    if (b.length >= 12 &&
        b[0] == 0x52 &&
        b[1] == 0x49 &&
        b[2] == 0x46 &&
        b[3] == 0x46 &&
        b[8] == 0x57 &&
        b[9] == 0x45 &&
        b[10] == 0x42 &&
        b[11] == 0x50)
      return true; // WEBP
    return false;
  }

  bool _eq(Uint8List s, int off, List<int> sig) {
    if (s.length < off + sig.length) return false;
    for (var i = 0; i < sig.length; i++) {
      if (s[off + i] != sig[i]) return false;
    }
    return true;
  }
}
