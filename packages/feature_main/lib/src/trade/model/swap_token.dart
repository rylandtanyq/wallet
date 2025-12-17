class SwapToken {
  final String name;
  final String symbol;
  final String mint;
  final int decimals;
  final double balance;
  final String logo;

  const SwapToken({required this.name, required this.symbol, required this.mint, required this.decimals, required this.balance, required this.logo});
}

const SwapToken solToken = SwapToken(
  name: "Solana",
  symbol: "SOL",
  mint: "So11111111111111111111111111111111111111112", // wSOL 主网 mint
  decimals: 9, // SOL 精度 9 位
  balance: 0,
  logo: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/solana/info/logo.png",
);
const SwapToken usdtToken = SwapToken(
  name: "Tether USD",
  symbol: "USDT",
  mint: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB", // USDT 主网 mint
  decimals: 6, // USDT 精度 6 位
  balance: 0,
  logo:
      "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xdAC17F958D2ee523a2206206994597C13D831ec7/logo.png", // 先用你这个占位，之后换成 USDT 图标
);
