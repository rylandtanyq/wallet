import 'package:dio/dio.dart';
import 'package:shared_utils/service/request.dart';
import 'package:feature_wallet/src/add_tokens_page/models/add_tokens_model.dart';
import 'package:feature_wallet/src/add_tokens_page/models/search_token_model.dart';
//

class WalletApi {
  static Future walletTokensDataFetch(String address) async {
    String path = '/api/solana/getCoinMetadata?address=$address';
    Response response = await RequestManager().handleRequest(path, "GET");
    dynamic ret = response.data;
    AddTokensModel addTokensModel = AddTokensModel.fromJson(ret);
    return addTokensModel;
  }

  // /api/solana/searchToken
  static Future searchTokenFetch(String name) async {
    String path = '/api/solana/searchToken?keyword=$name';
    Response response = await RequestManager().handleRequest(path, "GET");
    dynamic ret = response.data;
    SearchTokenModel searchTokenModel = SearchTokenModel.fromJson(ret);
    return searchTokenModel;
  }
}
