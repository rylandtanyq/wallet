import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'dart:convert';
import 'package:http/http.dart' as http;

/// 通过助记词生成 Keypair
Future<Ed25519HDKeyPair> loadWalletFromMnemonic(String mnemonic) async {
  final seed = bip39.mnemonicToSeed(mnemonic);
  return await Ed25519HDKeyPair.fromMnemonic(mnemonic);
}

/// 发送 SOL
Future<String> sendSol({
  required String mnemonic,
  required String receiverAddress,
  required double amount, // 单位 SOL
  String rpcUrl = 'https://purple-capable-crater.solana-mainnet.quiknode.pro/63bde1d4d678bfd3b06aced761d21c282568ef32/',
}) async {
  // 1. SolanaClient，需要 Uri 类型
  final client = SolanaClient(rpcUrl: Uri.parse(rpcUrl), websocketUrl: Uri.parse(rpcUrl.replaceFirst('http', 'ws')));

  // 2. 生成发送方 Keypair，指定派生路径
  final sender = await Ed25519HDKeyPair.fromMnemonic(
    mnemonic,
    account: 0, // m/44'/501'/0'
    change: 0, // m/44'/501'/0'/0
  );

  debugPrint('发送方地址: ${sender.publicKey.toBase58()}'); // 确认和钱包地址一致

  // 3. 构造转账指令
  final instruction = SystemInstruction.transfer(
    fundingAccount: sender.publicKey,
    recipientAccount: Ed25519HDPublicKey.fromBase58(receiverAddress),
    lamports: (amount * lamportsPerSol).toInt(),
  );

  // 4. 发送交易并确认
  final signature = await client.sendAndConfirmTransaction(
    message: Message(instructions: [instruction]),
    signers: [sender],
    commitment: Commitment.confirmed,
  );

  return signature;
}

/// 发送派生币
Future<String> sendSPLToken({
  required String mnemonic,
  required String receiverAddress,
  required String tokenMintAddress,
  required double amount,
  // 测试网 https://api.testnet.solana.com
  // 主网 https://api.mainnet-beta.solana.com
  // 开发网 https://api.devnet.solana.com
  String rpcUrl = 'https://purple-capable-crater.solana-mainnet.quiknode.pro/63bde1d4d678bfd3b06aced761d21c282568ef32/',
}) async {
  final client = SolanaClient(rpcUrl: Uri.parse(rpcUrl), websocketUrl: Uri.parse(rpcUrl.replaceFirst('http', 'ws')));

  final sender = await Ed25519HDKeyPair.fromMnemonic(
    mnemonic,
    account: 0, // m/44'/501'/0'
    change: 0, // m/44'/501'/0'/0
  );
  final mint = Ed25519HDPublicKey.fromBase58(tokenMintAddress);
  final receiverPubKey = Ed25519HDPublicKey.fromBase58(receiverAddress);

  debugPrint('发送方地址: ${sender.publicKey.toBase58()}'); // 确认和钱包地址一致

  // 获取或创建收款方的关联Token账户（ATA）
  final receiverAta = await client.getAssociatedTokenAccount(owner: receiverPubKey, mint: mint);

  // 如果收款方没有关联Token账户，则创建一个
  if (receiverAta == null) {
    await client.createAssociatedTokenAccount(owner: receiverPubKey, mint: mint, funder: sender);
  }

  // 转账 SPL Token
  final signature = await client.transferSplToken(
    mint: mint,
    destination: receiverPubKey,
    amount: (amount * 1e9).toInt(), // 转账金额，单位为 lamports
    owner: sender,
  );

  return signature;
}

// 获取SOL余额
Future<double> getSolBalance({
  required String rpcUrl,
  required String ownerAddress, // 地址字符串
}) async {
  final client = SolanaClient(rpcUrl: Uri.parse(rpcUrl), websocketUrl: Uri.parse(rpcUrl.replaceFirst('http', 'ws')));

  // 获取余额
  final balance = await client.rpcClient.getBalance(ownerAddress);

  // 转换为 SOL 单位
  return balance.value / lamportsPerSol;
}

// 获取派生币余额
Future<double> getSplTokenBalanceRpc({required String rpcUrl, required String ownerAddress, required String mintAddress}) async {
  // 1. 查找用户的 token accounts
  final res1 = await http.post(
    Uri.parse(rpcUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "jsonrpc": "2.0",
      "id": 1,
      "method": "getTokenAccountsByOwner",
      "params": [
        ownerAddress,
        {"mint": mintAddress},
        {"encoding": "jsonParsed"},
      ],
    }),
  );

  final data1 = jsonDecode(res1.body);
  final accounts = (data1['result']?['value'] ?? []) as List;

  if (accounts.isEmpty) {
    // 用户没有创建 ATA 或没接收过该 Token
    return 0.0;
  }

  final tokenAccount = accounts[0]['pubkey'];

  // 2. 查余额
  final res2 = await http.post(
    Uri.parse(rpcUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "jsonrpc": "2.0",
      "id": 2,
      "method": "getTokenAccountBalance",
      "params": [tokenAccount],
    }),
  );

  final data2 = jsonDecode(res2.body);
  final value = data2['result']?['value'];

  if (value == null) {
    return 0.0; // 没有余额或账户未初始化
  }

  final amountStr = value['amount'] as String;
  final decimals = value['decimals'] as int;

  return double.parse(amountStr) / pow(10, decimals);
}

// 钱包地址校验
bool isValidSolanaAddress(String address) {
  try {
    final pubKey = Ed25519HDPublicKey.fromBase58(address);
    // 校验长度必须是 32 字节
    return pubKey.bytes.length == 32;
  } catch (e) {
    return false;
  }
}
