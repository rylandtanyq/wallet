import 'package:shared_utils/solana_servise.dart';

/// 统一取余额：
/// - SOL：mintAddress 传 null 或空字符串
/// - SPL：传具体 mintAddress
/// 返回字符串（保持精度的字符串；UI 再格式化）
Future<String> fetchTokenBalance({required String ownerAddress, String? mintAddress}) async {
  try {
    if (mintAddress == null || mintAddress.trim().isEmpty || mintAddress == 'SOL') {
      final sol = await getSolBalance(
        rpcUrl: 'https://purple-capable-crater.solana-mainnet.quiknode.pro/63bde1d4d678bfd3b06aced761d21c282568ef32/',
        ownerAddress: ownerAddress,
      );
      return sol.toString();
    } else {
      final amt = await getSplTokenBalanceRpc(
        rpcUrl: 'https://purple-capable-crater.solana-mainnet.quiknode.pro/63bde1d4d678bfd3b06aced761d21c282568ef32/',
        ownerAddress: ownerAddress,
        mintAddress: mintAddress,
      );
      return amt.toString();
    }
  } catch (e) {
    return '0';
  }
}
