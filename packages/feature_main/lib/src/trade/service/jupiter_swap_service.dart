import 'dart:convert';
import 'package:http/http.dart' as http;

/// Jupiter 返回的单条路由（我们先只用最优那一条）
class JupiterQuote {
  final String inputMint;
  final String outputMint;
  final String inAmount; // 字符串整型
  final String outAmount; // 字符串整型
  final String otherAmountThreshold; // 最少接收
  final int slippageBps;
  final double priceImpactPct;
  final Map<String, dynamic> raw; // 原始 JSON，后面 /swap 要用

  JupiterQuote({
    required this.inputMint,
    required this.outputMint,
    required this.inAmount,
    required this.outAmount,
    required this.otherAmountThreshold,
    required this.slippageBps,
    required this.priceImpactPct,
    required this.raw,
  });

  factory JupiterQuote.fromJson(Map<String, dynamic> json) {
    return JupiterQuote(
      inputMint: json['inputMint'] as String,
      outputMint: json['outputMint'] as String,
      inAmount: json['inAmount'] as String,
      outAmount: json['outAmount'] as String,
      otherAmountThreshold: json['otherAmountThreshold'] as String,
      slippageBps: json['slippageBps'] as int,
      priceImpactPct: double.tryParse(json['priceImpactPct'].toString()) ?? 0.0,
      raw: json,
    );
  }
}

class JupiterSwapService {
  // 先用 lite-api 就行，免费
  static const String _host = 'lite-api.jup.ag';

  /// 获取 Jupiter 报价：ExactIn（输入固定，输出预估）
  Future<JupiterQuote> getQuote({
    required String inputMint,
    required String outputMint,
    required int amount, // 最小单位整数，比如 lamports
    int slippageBps = 50, // 0.5%
  }) async {
    final uri = Uri.https(_host, '/swap/v1/quote', {
      'inputMint': inputMint,
      'outputMint': outputMint,
      'amount': amount.toString(),
      'slippageBps': slippageBps.toString(),
      'swapMode': 'ExactIn',
      'restrictIntermediateTokens': 'true',
    });

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Jupiter quote error: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body);
    final List routes = data['data'] ?? [];
    if (routes.isEmpty) {
      throw Exception('No routes found from Jupiter');
    }

    // 先取最优路由（第一个）
    return JupiterQuote.fromJson(routes.first as Map<String, dynamic>);
  }
}
