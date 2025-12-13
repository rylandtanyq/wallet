import 'package:dio/dio.dart';
import 'package:feature_main/src/home_page/models/token_price_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_utils/service/request.dart';

class WalletApi {
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
}
