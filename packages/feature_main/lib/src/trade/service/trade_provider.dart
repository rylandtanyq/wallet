import 'package:feature_main/src/trade/model/trade_swap_quote_model.dart';
import 'package:feature_main/src/trade/model/trade_swap_tx_model.dart';
import 'package:feature_main/src/trade/service/trade_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tradeQuoteProvider = StateNotifierProvider<TradeQuoteNotifier, AsyncValue<TradeSwapQuoteModel>>((ref) {
  return TradeQuoteNotifier();
});

final tradeSwapProvider = StateNotifierProvider<TradeSwapNotifier, AsyncValue<TradeSwapTxModel>>((ref) {
  return TradeSwapNotifier();
});
