import 'package:freezed_annotation/freezed_annotation.dart';

part 'trade_swap_tx_model.freezed.dart';
part 'trade_swap_tx_model.g.dart';

@freezed
class TradeSwapTxModel with _$TradeSwapTxModel {
  const factory TradeSwapTxModel({
    required String swapTransaction,
    required int lastValidBlockHeight,
    required int prioritizationFeeLamports,
    required int computeUnitLimit,
    int? simulationSlot,
    Map<String, dynamic>? dynamicSlippageReport,
    Map<String, dynamic>? simulationError,
    Map<String, dynamic>? addressesByLookupTableAddress,
    TradePrioritizationTypeModel? prioritizationType,
  }) = _TradeSwapTxModel;

  factory TradeSwapTxModel.fromJson(Map<String, dynamic> json) => _$TradeSwapTxModelFromJson(json);
}

@freezed
class TradePrioritizationTypeModel with _$TradePrioritizationTypeModel {
  const factory TradePrioritizationTypeModel({TradeComputeBudgetModel? computeBudget}) = _TradePrioritizationTypeModel;

  factory TradePrioritizationTypeModel.fromJson(Map<String, dynamic> json) => _$TradePrioritizationTypeModelFromJson(json);
}

@freezed
class TradeComputeBudgetModel with _$TradeComputeBudgetModel {
  const factory TradeComputeBudgetModel({required int microLamports, int? estimatedMicroLamports}) = _TradeComputeBudgetModel;

  factory TradeComputeBudgetModel.fromJson(Map<String, dynamic> json) => _$TradeComputeBudgetModelFromJson(json);
}
