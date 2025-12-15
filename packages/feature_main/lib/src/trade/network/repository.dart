import 'package:dio/dio.dart';
import 'package:feature_main/src/trade/model/trade_swap_quote_model.dart';
import 'package:feature_main/src/trade/model/trade_swap_tx_model.dart';
import 'package:shared_utils/service/request.dart';
import 'package:shared_utils/app_config.dart';

class TradeApi {
  static Future quickSwap({
    required String inputMint,
    required String outputMint,
    required int amount, // 最小单位整数，比如 lamports
    int slippageBps = 50,
  }) async {
    String path =
        "${AppConfig.jupiterQuoteUrl}?inputMint=$inputMint&outputMint=$outputMint&amount=$amount&slippageBps=50&swapMode=ExactIn&restrictIntermediateTokens=true";
    Response response = await RequestManager().handleRequest(path, "GET");
    dynamic ret = response.data;
    TradeSwapQuoteModel tradeSwapQuoteModel = TradeSwapQuoteModel.fromJson(ret);
    return tradeSwapQuoteModel;
  }

  static Future buildSwapTx({required TradeSwapQuoteModel quote, required String userPublicKey, String? destinationWallet}) async {
    final path = AppConfig.jupiterSwapUrl;
    final body = {
      "quoteResponse": quote.rawJson,
      "userPublicKey": userPublicKey,
      // if (destinationWallet != null) "destinationWallet": destinationWallet,
      "dynamicComputeUnitLimit": true,
      "prioritizationFeeLamports": {
        "priorityLevelWithMaxLamports": {"maxLamports": 1000000, "priorityLevel": "medium", "global": false},
      },
      // "wrapAndUnwrapSol": true,
    };

    Response response = await RequestManager().handleRequest(path, "POST", data: body);
    dynamic ret = response.data;
    TradeSwapTxModel tradeSwapTxModel = TradeSwapTxModel.fromJson(ret);
    return tradeSwapTxModel;
  }
}
