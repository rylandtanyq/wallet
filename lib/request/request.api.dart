import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/request/request.dart';

class WalletApi {
  static Future walletTokensDataFetch(String address) async {
    String path = '/api/solana/getCoinMetadata?address=$address';
    Response response = await RequestManager().handleRequest(path, "GET");
    debugPrint('request result: $response');
    dynamic ret = response.data['result'];
    return ret;
  }

  static Future listWalletTokenDataFetch(dynamic datas) async {
    String path = '/api/solana/listTokenMetadataExtras';
    Response response = await RequestManager().handleRequest(
      path,
      "POST",
      data: jsonEncode(datas),
      options: Options(contentType: Headers.jsonContentType),
    );
    debugPrint('request result: $response');
    return response;
  }
}
