import 'package:feature_main/src/trade/model/trade_swap_quote_model.dart';
import 'package:feature_main/src/trade/network/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TradeSwapNotofier extends StateNotifier<AsyncValue<TradeSwapQuoteModel>> {
  TradeSwapNotofier() : super(const AsyncLoading());

  Future fetchTradeSwapData(String inputMint, String outputMint, int amount) async {
    try {
      final tradeSwapData = await TradeApi.quickSwap(inputMint: inputMint, outputMint: outputMint, amount: amount);
      state = AsyncValue.data(tradeSwapData);
    } catch (e) {
      debugPrint('$e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
