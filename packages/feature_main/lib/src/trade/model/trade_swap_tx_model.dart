import 'package:freezed_annotation/freezed_annotation.dart';

part 'trade_swap_tx_model.freezed.dart';
part 'trade_swap_tx_model.g.dart';

@freezed
class TradeSwapTxModel with _$TradeSwapTxModel {
  const factory TradeSwapTxModel({required String swapTransaction}) = _TradeSwapTxModel;

  factory TradeSwapTxModel.fromJson(Map<String, dynamic> json) => _$TradeSwapTxModelFromJson(json);
}
