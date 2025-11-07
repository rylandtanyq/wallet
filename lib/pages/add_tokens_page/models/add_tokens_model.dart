import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_tokens_model.freezed.dart';
part 'add_tokens_model.g.dart';

/// 顶层函数：给 @JsonKey(readValue:) 用
Object? _readImageFromMetadata(Map json, String key) {
  final metaRaw = json['metadata'];

  if (metaRaw is String && metaRaw.trim().isNotEmpty) {
    try {
      final meta = jsonDecode(metaRaw);
      if (meta is Map && meta['image'] is String && (meta['image'] as String).isNotEmpty) {
        return meta['image'];
      }
    } catch (_) {}
  }

  if (metaRaw is Map && metaRaw['image'] is String && (metaRaw['image'] as String).isNotEmpty) {
    return metaRaw['image'];
  }

  final logo = json['logoURI'];
  if (logo is String && logo.isNotEmpty) return logo;

  final uri = json['uri'];
  if (uri is String && uri.isNotEmpty) return uri;

  return null;
}

@freezed
class AddTokensModel with _$AddTokensModel {
  const factory AddTokensModel({@Default([]) List<AddTokensItemModel> result}) = _AddTokensModel;

  factory AddTokensModel.fromJson(Map<String, dynamic> json) => _$AddTokensModelFromJson(json);
}

@freezed
class AddTokensItemModel with _$AddTokensItemModel {
  const factory AddTokensItemModel({
    required String mint,
    required String name,
    required String symbol,

    /// 直接把 image 清洗好，UI 侧不用再 decode
    @JsonKey(readValue: _readImageFromMetadata) String? image,
  }) = _AddTokensItemModel;

  factory AddTokensItemModel.fromJson(Map<String, dynamic> json) => _$AddTokensItemModelFromJson(json);
}
