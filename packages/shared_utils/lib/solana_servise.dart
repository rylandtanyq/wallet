import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_utils/app_config.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:http/http.dart' as http;
import 'package:solana/base58.dart';

/// 通过助记词生成 Keypair
Future<Ed25519HDKeyPair> loadWalletFromMnemonic(String mnemonic) async {
  // final seed = bip39.mnemonicToSeed(mnemonic);
  return await Ed25519HDKeyPair.fromMnemonic(mnemonic);
}

String _norm(String? s) {
  final t = (s ?? '').trim();
  if (t.isEmpty) return '';
  if (t.toLowerCase() == 'null') return '';
  return t;
}

List<int> _hexToBytes(String hex) {
  var s = hex.trim();
  if (s.startsWith('0x') || s.startsWith('0X')) s = s.substring(2);
  if (s.length.isOdd) {
    throw const FormatException('hex length must be even');
  }
  final out = <int>[];
  for (var i = 0; i < s.length; i += 2) {
    out.add(int.parse(s.substring(i, i + 2), radix: 16));
  }
  return out;
}

List<int> _parsePrivateKeyBytes(String privateKey) {
  final s = _norm(privateKey);
  if (s.isEmpty) throw const FormatException('privateKey empty');

  // JSON array: [1,2,3,...]
  if (s.startsWith('[') && s.endsWith(']')) {
    final decoded = jsonDecode(s);
    if (decoded is! List) throw const FormatException('invalid json array');
    final bytes = decoded.map((e) => (e as num).toInt()).toList(growable: false);
    return bytes;
  }

  // Comma separated ints: 1,2,3
  if (RegExp(r'^\s*\d+(\s*,\s*\d+)*\s*$').hasMatch(s)) {
    return s.split(',').map((e) => int.parse(e.trim())).toList(growable: false);
  }

  // hex
  if (RegExp(r'^(0x)?[0-9a-fA-F]+$').hasMatch(s)) {
    return _hexToBytes(s);
  }

  // base58 solana sdk 常见
  return base58decode(s);
}

// solana 的私钥常见有两种长度：
/// - 32 bytes seed
/// - 64 bytes secretKey(32 seed + 32 pub)
List<int> _normalizeSolanaPrivateKey(List<int> bytes) {
  if (bytes.length == 32) return bytes;
  if (bytes.length == 64) return bytes.sublist(0, 32);
  throw FormatException('unsupported privateKey length=${bytes.length} (need 32 or 64 bytes)');
}

/// 统一构建签名
Future<Ed25519HDKeyPair> buildSolanaSigner({String? mnemonic, String? privateKey, String? expectedAddress}) async {
  final m = _norm(mnemonic);
  if (m.isNotEmpty) {
    final kp = await Ed25519HDKeyPair.fromMnemonic(m, account: 0, change: 0);
    _assertSignerAddress(kp, expectedAddress);
    return kp;
  }

  final pk = _norm(privateKey);
  if (pk.isEmpty) {
    throw Exception('missing mnemonic and privateKey');
  }

  final bytes = _normalizeSolanaPrivateKey(_parsePrivateKeyBytes(pk));
  final kp = await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: bytes);
  _assertSignerAddress(kp, expectedAddress);
  return kp;
}

void _assertSignerAddress(Ed25519HDKeyPair kp, String? expected) {
  final exp = (expected ?? '').trim();
  if (exp.isEmpty) return;

  // solana 包里有 kp.address 这个字段
  if (kp.address != exp) {
    throw Exception('signer mismatch: expected=$exp, got=${kp.address}');
  }
}

/// 通过 RPC getTokenSupply 获取 mint 的 decimals
Future<int> fetchSplTokenDecimals({required String rpcUrl, required String mintAddress}) async {
  final res = await http.post(
    Uri.parse(rpcUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "jsonrpc": "2.0",
      "id": 1,
      "method": "getTokenSupply",
      "params": [mintAddress],
    }),
  );

  final data = jsonDecode(res.body);
  final decimals = data['result']?['value']?['decimals'];
  if (decimals is int) return decimals;

  throw Exception('fetchSplTokenDecimals failed: ${res.body}');
}

/// 输入的 UI金额字符串 精确转成最小单位整数 base units
/// example：decimals=6, 1.23 --> 1230000
BigInt parseUiAmountToBaseUnits(String input, int decimals) {
  final s = input.trim();

  // 允许: 123  或 123.45
  if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(s)) {
    throw const FormatException('invalid amount');
  }

  final parts = s.split('.');
  final whole = BigInt.parse(parts[0]);

  var frac = parts.length == 2 ? parts[1] : '';
  if (frac.length > decimals) {
    throw FormatException('too many decimals (max $decimals)');
  }

  frac = frac.padRight(decimals, '0');
  final fracPart = frac.isEmpty ? BigInt.zero : BigInt.parse(frac);

  return whole * BigInt.from(10).pow(decimals) + fracPart;
}

/// 生成最小单位提示：decimals=6 -> "0.000001"
String minUnitText(int decimals) {
  if (decimals <= 0) return "1";
  return "0.${"0" * (decimals - 1)}1";
}

/// 发送 SOL
Future<String> sendSol({
  String? mnemonic,
  String? privateKey,
  required String receiverAddress,
  required double amount, // 单位 SOL
  String? rpcUrl,
}) async {
  final effectiveRpcUrl = rpcUrl ?? AppConfig.solanaRpcUrl;

  final client = SolanaClient(rpcUrl: Uri.parse(effectiveRpcUrl), websocketUrl: Uri.parse(effectiveRpcUrl.replaceFirst('http', 'ws')));

  final sender = await buildSolanaSigner(mnemonic: mnemonic, privateKey: privateKey);

  final receiver = Ed25519HDPublicKey.fromBase58(receiverAddress);

  const lamportsPerSol = 1000000000;

  final lamports = (amount * lamportsPerSol).round();
  if (lamports <= 0) {
    throw Exception('amount too small, min is 0.000000001 SOL');
  }

  final instruction = SystemInstruction.transfer(fundingAccount: sender.publicKey, recipientAccount: receiver, lamports: lamports);

  final signature = await client.sendAndConfirmTransaction(
    message: Message(instructions: [instruction]),
    signers: [sender],
    commitment: Commitment.confirmed,
  );

  return signature;
}

/// 发送派生币
Future<String> sendSPLToken({
  String? mnemonic,
  String? privateKey,
  required String receiverAddress,
  required String tokenMintAddress,
  required String amountText,
  String? rpcUrl,
}) async {
  final effectiveRpcUrl = rpcUrl ?? AppConfig.solanaRpcUrl;

  final client = SolanaClient(rpcUrl: Uri.parse(effectiveRpcUrl), websocketUrl: Uri.parse(effectiveRpcUrl.replaceFirst('http', 'ws')));

  final sender = await buildSolanaSigner(mnemonic: mnemonic, privateKey: privateKey);

  final mint = Ed25519HDPublicKey.fromBase58(tokenMintAddress);
  final receiverPubKey = Ed25519HDPublicKey.fromBase58(receiverAddress);

  // 按 mint decimals 换算 base units
  final decimals = await fetchSplTokenDecimals(rpcUrl: effectiveRpcUrl, mintAddress: tokenMintAddress);
  final baseUnits = parseUiAmountToBaseUnits(amountText, decimals);
  if (baseUnits <= BigInt.zero) {
    throw Exception('amount too small, min is ${minUnitText(decimals)}');
  }

  final maxI64 = BigInt.from(9223372036854775807);
  if (baseUnits > maxI64) {
    throw Exception('amount too large');
  }

  final receiverAta = await client.getAssociatedTokenAccount(owner: receiverPubKey, mint: mint);
  if (receiverAta == null) {
    try {
      await client.createAssociatedTokenAccount(owner: receiverPubKey, mint: mint, funder: sender);
    } catch (_) {
      final check = await client.getAssociatedTokenAccount(owner: receiverPubKey, mint: mint);
      if (check == null) rethrow;
    }
  }

  return client.transferSplToken(mint: mint, destination: receiverPubKey, amount: baseUnits.toInt(), owner: sender);
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
