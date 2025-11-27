class CryptoInputValidator {

  // 检查是否为助记词
  static bool isMnemonic(String input) {
    final words = input.trim().split(RegExp(r'\s+'));
    if (words.length != 12 && words.length != 24) return false;

    return true;
  }

  // 检查是否为私钥（比特币WIF格式示例）
  static bool isPrivateKey(String key) {
    if (key.length == 51 && ['5', 'K', 'L'].contains(key[0])) {
      return true;
    }

    // 检查是否是64位16进制
    if (RegExp(r'^[0-9A-Fa-f]{64}$').hasMatch(key)) {
      return true;
    }

    return false;
  }
}