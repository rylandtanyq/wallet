String toFixedTrunc(String s, {int digits = 2}) {
  if (!s.contains('.')) return '$s.${'0' * digits}';
  final parts = s.split('.');
  final frac = parts[1];
  final cut = frac.length >= digits ? frac.substring(0, digits) : frac.padRight(digits, '0');
  return '${parts[0]}.$cut';
}
