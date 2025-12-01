enum ChainType { EVM, Solana, UTXO }

class BlockchainNetwork {
  final String id;
  final String name;
  final String rpcUrl;
  final int chainId;
  final String symbol;
  final String explorerUrl;
  final ChainType chainType;
  final String? wssUrl;
  final bool testnet;

  BlockchainNetwork({
    required this.id,
    required this.name,
    required this.rpcUrl,
    required this.chainId,
    required this.symbol,
    required this.explorerUrl,
    required this.chainType,
    this.wssUrl,
    this.testnet = false,
  });
}

// 支持的区块链网络
final Map<String, BlockchainNetwork> supportedNetworks = {
  'ethereum': BlockchainNetwork(
    id: 'ethereum',
    name: 'Ethereum',
    rpcUrl: 'https://cloudflare-eth.com',
    chainId: 60,
    symbol: 'ETH',
    explorerUrl: 'https://etherscan.io',
    chainType: ChainType.EVM,
  ),
  'polygon': BlockchainNetwork(
    id: 'polygon',
    name: 'Polygon',
    rpcUrl: 'https://polygon-rpc.com',
    chainId: 137,
    symbol: 'MATIC',
    explorerUrl: 'https://polygonscan.com',
    chainType: ChainType.EVM,
  ),
  'solana': BlockchainNetwork(
    id: 'solana',
    name: 'Solana',
    rpcUrl: 'https://api.mainnet-beta.solana.com',
    chainId: -1, // Solana不使用chainId
    symbol: 'SOL',
    explorerUrl: 'https://explorer.solana.com',
    chainType: ChainType.Solana,
  ),
  'bsc': BlockchainNetwork(
    id: 'bsc',
    name: 'BNB Chain',
    rpcUrl: 'https://bsc-dataseed.binance.org',
    chainId: 56,
    symbol: 'BNB',
    explorerUrl: 'https://bscscan.com',
    chainType: ChainType.EVM,
  ),
};

/// 根据chainId查找网络名称
String? getNetworkNameByChainId(int targetChainId) {
  for (final network in supportedNetworks.values) {
    if (network.chainId == targetChainId) {
      return network.name;
    }
  }
  return null; // 没有找到匹配的网络
}
