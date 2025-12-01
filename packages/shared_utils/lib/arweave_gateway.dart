import 'dart:typed_data';
import 'package:dio/dio.dart';

String? extractArweaveId(String urlOrId) {
  try {
    // 纯 id（没有 scheme），直接用
    if (!urlOrId.contains('://') && urlOrId.length > 40) return urlOrId;
    final uri = Uri.parse(urlOrId);
    if (uri.host.contains('arweave') && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.firstWhere((s) => s.isNotEmpty, orElse: () => '');
    }
  } catch (_) {}
  return null;
}

/// 并发向多个网关请求，谁先成功用谁（其余取消）
Future<Response<Uint8List>> fetchArweaveWithFallback(String urlOrId) async {
  final id = extractArweaveId(urlOrId);
  if (id == null || id.isEmpty) {
    throw Exception('Invalid arweave url/id: $urlOrId');
  }

  final gateways = <String>['https://arweave.net/$id', 'https://ar-io.net/$id', 'https://gateway.irys.xyz/$id'];

  final opts = BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 12),
    responseType: ResponseType.bytes,
    followRedirects: true,
    headers: const {'accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8', 'user-agent': 'Mozilla/5.0 (Flutter; like Chrome)'},
    validateStatus: (s) => s != null && s < 400,
  );

  final cancelTokens = <CancelToken>[];
  Response<Uint8List>? winner;
  Object? lastErr;

  final futures = gateways.map((u) {
    final dio = Dio(opts);
    final token = CancelToken();
    cancelTokens.add(token);
    return dio
        .get<Uint8List>(u, cancelToken: token)
        .then((resp) {
          if (winner == null) {
            winner = resp;
            for (final t in cancelTokens) {
              if (!t.isCancelled) t.cancel('winner found');
            }
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
  } catch (_) {
    // 第一个完成可能是失败，继续看 winner
  }

  if (winner != null) return winner!;

  // 兜底顺序再尝试一遍
  for (final u in gateways) {
    try {
      final dio = Dio(opts);
      return await dio.get<Uint8List>(u);
    } catch (e) {
      lastErr = e;
    }
  }
  throw lastErr ?? Exception('All arweave gateways failed for $id');
}
