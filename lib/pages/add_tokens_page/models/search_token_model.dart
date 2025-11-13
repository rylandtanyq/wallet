import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_token_model.freezed.dart';
part 'search_token_model.g.dart';

@freezed
class SearchTokenModel with _$SearchTokenModel {
  const factory SearchTokenModel({@Default([]) List<SearchTokenItemModel> result}) = _SearchTokenModel;

  factory SearchTokenModel.fromJson(Map<String, dynamic> json) => _$SearchTokenModelFromJson(json);
}

@freezed
class SearchTokenItemModel with _$SearchTokenItemModel {
  const factory SearchTokenItemModel({
    required String token,
    required String chain,
    required String name,
    required String symbol,
    required String currentPriceUsd,
    required String holders,
    required String logoUrl,
  }) = _SearchTokenItemModel;

  factory SearchTokenItemModel.fromJson(Map<String, dynamic> json) => _$SearchTokenItemModelFromJson(json);
}
