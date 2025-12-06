String formatSolanaAddress(String address, {int prefixLen = 4, int suffixLen = 4}) {
  if (address.isEmpty) return '';

  if (address.length <= prefixLen + suffixLen) {
    return address;
  }

  final prefix = address.substring(0, prefixLen);
  final suffix = address.substring(address.length - suffixLen);

  return '$prefix****$suffix';
}
