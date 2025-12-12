import 'package:dio/dio.dart';
import 'package:feature_main/src/trade/model/trade_swap_quote_model.dart';
import 'package:shared_utils/service/request.dart';

class TradeApi {
  static Future quickSwap({
    required String inputMint,
    required String outputMint,
    required int amount, // 最小单位整数，比如 lamports
    int slippageBps = 50,
  }) async {
    String path =
        "https://lite-api.jup.ag/swap/v1/quote?inputMint=$inputMint&outputMint=$outputMint&amount=$amount&slippageBps=50&swapMode=ExactIn&restrictIntermediateTokens=true";
    Response response = await RequestManager().handleRequest(path, "GET");
    dynamic ret = response.data;
    TradeSwapQuoteModel tradeSwapQuoteModel = TradeSwapQuoteModel.fromJson(ret);
    return tradeSwapQuoteModel;
  }
}
