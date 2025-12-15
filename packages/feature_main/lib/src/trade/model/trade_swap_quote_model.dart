import 'package:freezed_annotation/freezed_annotation.dart';

part 'trade_swap_quote_model.freezed.dart';
part 'trade_swap_quote_model.g.dart';

double _toDouble(dynamic v) => v == null ? 0.0 : (v is num ? v.toDouble() : double.parse(v.toString()));

int _toInt(dynamic v) => v == null ? 0 : (v is int ? v : int.parse(v.toString()));

@freezed
class TradeSwapQuoteModel with _$TradeSwapQuoteModel {
  const factory TradeSwapQuoteModel({
    required String inputMint,
    required String inAmount,
    required String outputMint,
    required String outAmount,
    required String otherAmountThreshold,
    required String swapMode,
    required int contextSlot,
    required double timeTaken,
    required String swapUsdValue,
    required bool simplerRouteUsed,
    Map<String, dynamic>? platformFee,
    @JsonKey(fromJson: _toInt) required int slippageBps,
    @JsonKey(fromJson: _toDouble) required double priceImpactPct,
    @JsonKey(ignore: true) Map<String, dynamic>? rawJson,
    @Default([]) List<TradeSwapQuoteRoutePlanModel> routePlan,
  }) = _TradeSwapQuoteModel;

  factory TradeSwapQuoteModel.fromJson(Map<String, dynamic> json) => _$TradeSwapQuoteModelFromJson(json).copyWith(rawJson: json);
}

@freezed
class TradeSwapQuoteRoutePlanModel with _$TradeSwapQuoteRoutePlanModel {
  const factory TradeSwapQuoteRoutePlanModel({required int percent, required TradeSwapQuoteRoutePlanItemModel swapInfo}) =
      _TradeSwapQuoteRoutePlanModel;

  factory TradeSwapQuoteRoutePlanModel.fromJson(Map<String, dynamic> json) => _$TradeSwapQuoteRoutePlanModelFromJson(json);
}

@freezed
class TradeSwapQuoteRoutePlanItemModel with _$TradeSwapQuoteRoutePlanItemModel {
  const factory TradeSwapQuoteRoutePlanItemModel({
    required String ammKey,
    required String label,
    required String inputMint,
    required String outputMint,
    required String inAmount,
    required String outAmount,
    required String feeAmount,
    required String feeMint,
  }) = _TradeSwapQuoteRoutePlanItemModel;

  factory TradeSwapQuoteRoutePlanItemModel.fromJson(Map<String, dynamic> json) => _$TradeSwapQuoteRoutePlanItemModelFromJson(json);
}
