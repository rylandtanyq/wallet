typedef AsyncVoid = Future<void> Function();
typedef AsyncString = Future<void> Function(String);

class WalletActions {
  final AsyncVoid reloadTokens;
  final AsyncVoid reloadTokensPrice;
  final AsyncVoid reloadTokensAmount;
  final AsyncVoid reloadCurrentSelectWalletfn;
  final AsyncString onSearchChange;
  const WalletActions({
    required this.reloadTokens,
    required this.reloadTokensPrice,
    required this.reloadTokensAmount,
    required this.onSearchChange,
    required this.reloadCurrentSelectWalletfn,
  });
}
