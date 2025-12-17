import 'package:feature_main/src/trade/model/trade_swap_quote_model.dart';
import 'package:feature_main/src/trade/model/trade_swap_tx_model.dart';
import 'package:feature_main/src/trade/network/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TradeQuoteNotifier extends StateNotifier<AsyncValue<TradeSwapQuoteModel>> {
  TradeQuoteNotifier() : super(const AsyncLoading());

  Future fetchTradeQuoteData(String inputMint, String outputMint, int amount) async {
    try {
      final tradeSwapData = await TradeApi.quickSwap(inputMint: inputMint, outputMint: outputMint, amount: amount);
      state = AsyncValue.data(tradeSwapData);
    } catch (e) {
      debugPrint('$e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

class TradeSwapNotifier extends StateNotifier<AsyncValue<TradeSwapTxModel>> {
  TradeSwapNotifier() : super(const AsyncLoading());

  Future fetchTradeSwapTxData(TradeSwapQuoteModel quote, String userPublicKey) async {
    try {
      final tradeSwapData = await TradeApi.buildSwapTx(quote: quote, userPublicKey: userPublicKey);
      state = AsyncValue.data(tradeSwapData);
    } catch (e) {
      debugPrint('$e swap data error');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
