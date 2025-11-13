import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/pages/add_tokens_page/models/add_tokens_model.dart';
import 'package:untitled1/pages/add_tokens_page/models/search_token_model.dart';
import 'package:untitled1/pages/wallet_page/models/token_price_model.dart';
import 'package:untitled1/request/request.dart';

class WalletApi {
  static Future walletTokensDataFetch(String address) async {
    String path = '/api/solana/getCoinMetadata?address=$address';
    Response response = await RequestManager().handleRequest(path, "GET");
    dynamic ret = response.data;
    AddTokensModel addTokensModel = AddTokensModel.fromJson(ret);
    return addTokensModel;
  }

  static Future listWalletTokenDataFetch(List<String> datas) async {
    String path = '/api/solana/listTokenMetadataExtras';
    dynamic data = {"addresses": datas};
    Response response = await RequestManager().handleRequest(
      path,
      "POST",
      data: data,
      options: Options(contentType: Headers.jsonContentType),
    );
    dynamic ret = response.data;
    TokenPriceModel tokenPriceModel = TokenPriceModel.fromJson(ret);
    return tokenPriceModel;
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
