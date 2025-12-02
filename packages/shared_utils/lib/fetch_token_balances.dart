import 'package:shared_utils/solana_servise.dart';

/// 统一取余额：
/// - SOL：mintAddress 传 null 或空字符串
/// - SPL：传具体 mintAddress
/// 返回字符串（保持精度的字符串；UI 再格式化）
Future<String> fetchTokenBalance({required String ownerAddress, String? mintAddress}) async {
  try {
    if (mintAddress == null || mintAddress.trim().isEmpty || mintAddress == 'SOL') {
      final sol = await getSolBalance(
        rpcUrl: 'https://dry-hardworking-cherry.solana-mainnet.quiknode.pro/d4a233a290e8af774e8007d488aac62582345be5/',
        ownerAddress: ownerAddress,
      );
      return sol.toString();
    } else {
      final amt = await getSplTokenBalanceRpc(
        rpcUrl: 'https://dry-hardworking-cherry.solana-mainnet.quiknode.pro/d4a233a290e8af774e8007d488aac62582345be5/',
        ownerAddress: ownerAddress,
        mintAddress: mintAddress,
      );
      return amt.toString();
    }
  } catch (e) {
    return '0';
  }
}
