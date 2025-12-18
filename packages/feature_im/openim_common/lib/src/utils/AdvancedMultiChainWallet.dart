import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:solana/solana.dart' as solana;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:web3dart/web3dart.dart';
import 'package:ed25519_hd_key/ed25519_hd_key.dart' as edkey;
import 'package:bs58/bs58.dart' as bs58;

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

/// 支持的区块链网络
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
    chainId: -1,
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

class AdvancedMultiChainWallet {
  final Map<String, dynamic> _clients = {};
  final Map<String, dynamic> _credentials = {};
  final Map<String, String?> _addresses = {};

  String? _mnemonic;
  String? _privateKey;
  BlockchainNetwork? _currentNetwork;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ✅ 关键改动：不要 late，避免未 initialize 就使用导致崩溃
  Box? _localStorage;

  // Solana：Base58 64-byte secretKey（seed32 + pub32）
  String? _solanaSecretKeyBase58;

  // ✅ 初始化状态控制（避免重复/并发 init）
  bool _initialized = false;
  Future<void>? _initTask;

  /// 根据 chainId 查找网络名称
  String? getNetworkNameByChainId(int targetChainId) {
    for (final network in supportedNetworks.values) {
      if (network.chainId == targetChainId) return network.name;
    }
    return null;
  }

  /// 对外初始化（可重复调用）
  Future<void> initialize({String? networkId}) async {
    await _ensureInitialized(networkId: networkId);
  }

  /// ✅ 确保初始化完成（外包忘记先 initialize，也不会炸）
  Future<void> _ensureInitialized({String? networkId}) async {
    if (_initialized) {
      if (networkId != null) {
        await switchNetwork(networkId);
      }
      return;
    }

    _initTask ??= () async {
      // 1) Hive init（重复调用可能抛异常，忽略即可）
      try {
        await Hive.initFlutter();
      } catch (_) {}

      // 2) Open box（重复打开也处理）
      if (Hive.isBoxOpen('wallet_data')) {
        _localStorage = Hive.box('wallet_data');
      } else {
        _localStorage = await Hive.openBox('wallet_data');
      }

      // 3) 默认网络
      _currentNetwork = supportedNetworks[networkId ?? 'ethereum'];

      // 4) 初始化所有网络客户端（只做一次）
      for (final network in supportedNetworks.values) {
        if (_clients.containsKey(network.id)) continue;

        switch (network.chainType) {
          case ChainType.EVM:
            _clients[network.id] = Web3Client(network.rpcUrl, Client());
            break;
          case ChainType.Solana:
            _clients[network.id] = solana.SolanaClient(
              rpcUrl: Uri.parse(network.rpcUrl),
              websocketUrl: Uri.parse(network.wssUrl ?? 'ws://localhost:8900'),
            );
            break;
          case ChainType.UTXO:
            break;
        }
      }

      // 5) 从安全存储加载
      await _loadFromSecureStorage();

      _initialized = true;
    }();

    await _initTask;
  }

  Box get _box {
    final b = _localStorage;
    if (b == null) {
      throw StateError('wallet_data box not initialized');
    }
    return b;
  }

  // 创建钱包
  Future<Map<String, String>> createNewWallet() async {
    await _ensureInitialized(networkId: 'solana');

    _mnemonic = bip39.generateMnemonic(strength: 128);

    // 用助记词派生所有链（包含 Solana）
    await _generateKeysFromMnemonic();

    // 保存
    await _saveToSecureStorage();

    // 当前网络设为 Solana
    _currentNetwork = supportedNetworks['solana'];

    final address = _addresses['solana'] ?? _addresses['Solana'] ?? '';
    final secret58 = _solanaSecretKeyBase58 ?? '';

    return {
      'mnemonic': _mnemonic ?? '',
      'currentAddress': address,
      'privateKey': secret58, // Solana: Base58 64B secretKey
      'currentNetwork': _currentNetwork?.name ?? '',
    };
  }

  // 从助记词恢复
  Future<Map<String, String>> restoreFromMnemonic(String mnemonic) async {
    await _ensureInitialized(networkId: 'solana');

    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception('Invalid mnemonic');
    }

    _mnemonic = mnemonic;
    await _generateKeysFromMnemonic();
    await _saveToSecureStorage();

    _currentNetwork = supportedNetworks['solana'];
    return _getWalletInfo();
  }

  // 私钥导入钱包（支持 EVM 与 Solana）
  Future<Map<String, String?>> importWalletFromPrivateKey(
    String input, {
    String rpcUrl = "https://cloudflare-eth.com",
  }) async {
    await _ensureInitialized(networkId: 'solana');

    final trimmed = input.trim();

    // 1) Solana: Base58 64 bytes secretKey 或 32 bytes seed
    try {
      final decoded = Uint8List.fromList(bs58.base58.decode(trimmed));
      if (decoded.length == 64 || decoded.length == 32) {
        final seed32 = decoded.length == 64 ? decoded.sublist(0, 32) : decoded;
        final kp = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: seed32);
        final address = kp.address;

        String balance = '0.00';
        try {
          final client = _clients['solana'] as solana.SolanaClient?;
          if (client != null) {
            final res = await client.rpcClient.getBalance(address);
            final lamports = res.value;
            balance = (lamports / solana.lamportsPerSol).toStringAsFixed(9);
          }
        } catch (_) {}

        return {
          'WalletType': decoded.length == 64 ? 'solanaSecretKeyImported' : 'solanaSeedImported',
          'currentNetwork': 'Solana',
          'currentAddress': address,
          'balance': balance,
          'mnemonic': '',
          'privateKey': input,
        };
      }
    } catch (_) {}

    // 2) EVM: 0x + 64 hex
    if (_looksLikeHex64With0x(trimmed)) {
      final client = Web3Client(rpcUrl, Client());
      try {
        final credentials = EthPrivateKey.fromHex(trimmed);
        final address = (await credentials.extractAddress()).hex;

        if (!isValidEthereumAddress(address)) {
          throw ArgumentError('Invalid Ethereum address derived from private key');
        }

        String balance = '0.00';
        try {
          final ethAmount = await _getBalanceWithRetry(client, address);
          balance = '${ethAmount.getValueInUnit(EtherUnit.ether)}';
        } catch (_) {}

        final chainId = await client.getNetworkId();
        final network = getNetworkNameByChainId(chainId);

        return {
          'WalletType': 'privateKeyImported',
          'currentNetwork': network,
          'currentAddress': address,
          'balance': balance,
          'mnemonic': '',
          'privateKey': trimmed,
        };
      } finally {
        client.dispose();
      }
    }

    // 3) Solana: Hex 64（32 bytes seed）
    if (_looksLikeHex64(trimmed)) {
      final seed32 = _hexToBytes(trimmed.replaceFirst(RegExp(r'^0x'), ''));
      if (seed32.length != 32) {
        throw ArgumentError('Expected 32-byte seed for Solana (got ${seed32.length}).');
      }

      final kp = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: seed32);
      final address = kp.address;

      String balance = '0.00';
      try {
        final client = _clients['solana'] as solana.SolanaClient?;
        if (client != null) {
          final res = await client.rpcClient.getBalance(address);
          final lamports = res.value;
          balance = (lamports / solana.lamportsPerSol).toStringAsFixed(9);
        }
      } catch (_) {}

      return {
        'WalletType': 'solanaSeedImported',
        'currentNetwork': 'Solana',
        'currentAddress': address,
        'balance': balance,
        'mnemonic': '',
        'privateKey': '',
      };
    }

    throw ArgumentError(
      'Unsupported key format. Provide:\n'
      '- Solana SecretKey (Base58, 64 bytes) or Base58 32-byte seed;\n'
      '- EVM 32-byte hex (0x...);\n'
      '- Solana 32-byte seed (Hex 64).',
    );
  }

  // 切换网络
  Future<void> switchNetwork(String networkId) async {
    await _ensureInitialized();
    if (!supportedNetworks.containsKey(networkId)) {
      throw Exception('Unsupported network');
    }
    _currentNetwork = supportedNetworks[networkId];
  }

  // 获取钱包信息
  Future<Map<String, String>> _getWalletInfo() async {
    final blockchain = _currentNetwork?.name ?? '';
    var address = _addresses[_currentNetwork?.id] ?? _addresses[_currentNetwork?.name] ?? '';

    if (_currentNetwork?.id == 'solana' && _addresses['solana'] != null) {
      address = _addresses['solana']!;
    }

    final isSolana = _currentNetwork?.id == 'solana';

    return {
      'mnemonic': _mnemonic ?? '',
      'balance': '0.00',
      'privateKey': isSolana ? (_solanaSecretKeyBase58 ?? '') : (_privateKey ?? ''),
      'currentNetwork': blockchain,
      'currentAddress': address,
    };
  }

  // 获取所有地址
  Map<String, String?> getAllAddresses() {
    return _addresses.map((key, value) {
      final net = supportedNetworks[key];
      return MapEntry(net?.name ?? key, value);
    });
  }

  // ========= 助记词 / 密钥派生 =========

  Future<void> _generateKeysFromMnemonic() async {
    if (_mnemonic == null) return;

    final seed = bip39.mnemonicToSeed(_mnemonic!);

    for (final network in supportedNetworks.values) {
      switch (network.chainType) {
        case ChainType.EVM:
          final path = "m/44'/60'/0'/0/0";
          final privateKeyBytes = await _derivePrivateKey(seed, path);
          final privateKeyHex = HEX.encode(privateKeyBytes);
          final credentials = EthPrivateKey.fromHex(privateKeyHex);

          _credentials[network.id] = credentials;
          final evmAddress = (await credentials.extractAddress()).hex;
          _addresses[network.id] = evmAddress;
          _addresses[network.name] = evmAddress;
          break;

        case ChainType.Solana:
          try {
            final seed32 = await _deriveSolanaSeed32Aligned(
              mnemonic: _mnemonic!,
              account: 0,
              change: 0,
            );

            final keyPair = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: seed32);
            final solAddress = keyPair.publicKey.toBase58();

            _credentials[network.id] = keyPair;
            _addresses[network.id] = solAddress;
            _addresses[network.name] = solAddress;

            final pub32 = keyPair.publicKey.bytes;
            final secret64 = Uint8List(64)
              ..setRange(0, 32, seed32)
              ..setRange(32, 64, pub32);

            _solanaSecretKeyBase58 = bs58.base58.encode(secret64);

            // 兼容：仍保留 seed32 hex（你原逻辑）
            _privateKey = HEX.encode(seed32);
          } catch (e) {
            debugPrint('Solana derive failed: $e');
          }
          break;

        case ChainType.UTXO:
          break;
      }
    }
  }

  Future<Uint8List> _derivePrivateKey(Uint8List seed, String path) async {
    final node = bip32.BIP32.fromSeed(seed).derivePath(path);
    return node.privateKey!;
  }

  Future<Uint8List> _deriveSolanaSeed32Aligned({
    required String mnemonic,
    int account = 0,
    int change = 0,
  }) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw ArgumentError('Invalid mnemonic');
    }

    final refKp = await solana.Ed25519HDKeyPair.fromMnemonic(mnemonic, account: account, change: change);
    final refAddress = refKp.address;

    final masterSeed = bip39.mnemonicToSeed(mnemonic);

    final pathA = "m/44'/501'/$account'/$change'";
    final keyA = Uint8List.fromList((await edkey.ED25519_HD_KEY.derivePath(pathA, masterSeed)).key);
    final addrA = (await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: keyA)).address;
    if (addrA == refAddress) return keyA;

    final pathB = "m/44'/501'/$account'/$change'/0'";
    final keyB = Uint8List.fromList((await edkey.ED25519_HD_KEY.derivePath(pathB, masterSeed)).key);
    final addrB = (await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: keyB)).address;
    if (addrB == refAddress) return keyB;

    return keyA;
  }

  // ========= 存储 =========

  Future<void> _saveToSecureStorage() async {
    await _secureStorage.write(
      key: 'mnemonic',
      value: _mnemonic!,
      iOptions: const IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );

    // ✅ 使用 _box（保证已初始化）
    await _box.put('addresses', _addresses);
  }

  Future<void> _loadFromSecureStorage() async {
    _mnemonic = await _secureStorage.read(key: 'mnemonic');
    if (_mnemonic != null && bip39.validateMnemonic(_mnemonic!)) {
      await _generateKeysFromMnemonic();
    } else {
      final savedAddresses = _box.get('addresses');
      if (savedAddresses != null) {
        _addresses.addAll(Map<String, String?>.from(savedAddresses as Map));
      }
    }
  }

  // ========= 工具函数 =========

  bool _looksLikeHex64With0x(String s) => RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(s.trim());
  bool _looksLikeHex64(String s) => RegExp(r'^(0x)?[0-9a-fA-F]{64}$').hasMatch(s.trim());

  Uint8List _hexToBytes(String hex) {
    final clean = hex.trim().toLowerCase().replaceAll(RegExp(r'[^0-9a-f]'), '');
    return Uint8List.fromList([
      for (int i = 0; i < clean.length; i += 2) int.parse(clean.substring(i, i + 2), radix: 16),
    ]);
  }

  Future<EtherAmount> _getBalanceWithRetry(Web3Client client, String address, {int retries = 2}) async {
    for (int i = 0; i < retries; i++) {
      try {
        return await client.getBalance(EthereumAddress.fromHex(address)).timeout(const Duration(seconds: 10));
      } on TimeoutException {
        if (i == retries - 1) rethrow;
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    throw Exception('Failed after $retries retries');
  }

  bool isValidEthereumAddress(String address) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ========= 助记词校验 =========

  Future<bool> verifyMnemonicInOrder(String mnemonic) async {
    final storedMnemonic = await _secureStorage.read(key: 'mnemonic');
    return mnemonic.trim() == storedMnemonic?.trim();
  }

  Future<bool> verifyMnemonicByRandomPositions(List<int> positions, String mnemonic) async {
    try {
      final inputWords = mnemonic.trim().split(RegExp(r'\s+'));
      if (inputWords.length != 3 || positions.length != 3) {
        _log('输入参数必须为3个单词和3个位置');
        return false;
      }

      final storedMnemonic = await _secureStorage.read(key: 'mnemonic');
      if (storedMnemonic == null) {
        _log('未找到存储的助记词');
        return false;
      }

      final storedWords = storedMnemonic.trim().split(RegExp(r'\s+'));

      for (int i = 0; i < positions.length; i++) {
        final position = positions[i] - 1;
        final inputWord = inputWords[i];

        if (position < 0 || position >= storedWords.length) {
          _log('无效的位置索引: $position (助记词长度: ${storedWords.length})');
          return false;
        }

        if (storedWords[position] != inputWord) {
          _log('位置 $position 不匹配: 存储="${storedWords[position]}"，输入="$inputWord"');
          return false;
        }
      }

      _log('3个位置验证全部通过');
      return true;
    } catch (e) {
      _log('验证过程中发生异常: $e');
      return false;
    }
  }

  void _log(String message) {
    // ignore: avoid_print
    print('[MnemonicVerifier] $message');
  }

  // 清理资源
  void dispose() {
    for (final client in _clients.values) {
      if (client is Web3Client) {
        client.dispose();
      }
    }
    if (_localStorage?.isOpen == true) {
      _localStorage?.close();
    }
  }
}
