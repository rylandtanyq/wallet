import "dart:convert";
import "package:flutter/services.dart" show rootBundle;

class AppConfig {
  static late final String appName;
  static late final String apiBaseUrl;
  static late final String solanaRpcUrl;
  static late final String jupiterSwapUrl;
  static late final String jupiterQuoteUrl;

  static Future<void> load() async {
    final content = await rootBundle.loadString('config/index.json');
    final jsonMap = jsonDecode(content) as Map<String, dynamic>;

    appName = jsonMap['APP_NAME'] as String;
    apiBaseUrl = jsonMap['API_BASE_URL'] as String;
    solanaRpcUrl = jsonMap['SOLANA_RPC_URL'] as String;
    jupiterSwapUrl = jsonMap["JUPITER_SWAP_URL"] as String;
    jupiterQuoteUrl = jsonMap["JUPITER_QUOTE_URL"] as String;
  }
}
