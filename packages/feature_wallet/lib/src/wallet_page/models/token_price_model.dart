import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_price_model.freezed.dart';
part 'token_price_model.g.dart';

@freezed
class TokenPriceModel with _$TokenPriceModel {
  const factory TokenPriceModel({@Default([]) List<TokenPriceItemModel> result}) = _TokenPriceModel;

  factory TokenPriceModel.fromJson(Map<String, dynamic> json) => _$TokenPriceModelFromJson(json);
}

@freezed
class TokenPriceItemModel with _$TokenPriceItemModel {
  const factory TokenPriceItemModel({required String address, required String unitPrice}) = _TokenPriceItemModel;

  factory TokenPriceItemModel.fromJson(Map<String, dynamic> json) => _$TokenPriceItemModelFromJson(json);
}
