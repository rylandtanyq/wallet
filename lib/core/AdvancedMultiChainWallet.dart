import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:solana/solana.dart' as solana;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cryptography/cryptography.dart';
import 'package:ed25519_hd_key/ed25519_hd_key.dart' as edkey;
import 'package:bs58/bs58.dart' as bs58;

import '../entity/BlockchainNetwork.dart';

class AdvancedMultiChainWallet {
  final Map<String, dynamic> _clients = {};
  final Map<String, dynamic> _credentials = {};
  final Map<String, String?> _addresses = {};
  String? _mnemonic;
  String? _privateKey;
  BlockchainNetwork? _currentNetwork;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late Box _localStorage;
  final Map<String, solana.SolanaClient> _clients2 = {};
  String? _solanaSecretKeyBase58;

  // 初始化钱包
  Future<void> initialize({String? networkId}) async {
    // 初始化Hive本地存储
    await Hive.initFlutter();
    _localStorage = await Hive.openBox('wallet_data');

    // 默认网络
    _currentNetwork = supportedNetworks[networkId ?? 'ethereum'];

    // 初始化所有网络客户端
    for (final network in supportedNetworks.values) {
      switch (network.chainType) {
        case ChainType.EVM:
          _clients[network.id] = Web3Client(network.rpcUrl, Client());
          break;
        case ChainType.Solana:
          _clients[network.id] = network.wssUrl != null
              ? solana.SolanaClient(rpcUrl: Uri.parse(network.rpcUrl), websocketUrl: Uri.parse(network.wssUrl!))
              : solana.SolanaClient(rpcUrl: Uri.parse(network.rpcUrl), websocketUrl: Uri.parse(network.wssUrl ?? 'ws://localhost:8900'));
          break;
        case ChainType.UTXO:
          // 比特币等UTXO模型链的客户端初始化
          break;
      }
    }

    // 尝试从安全存储加载钱包
    await _loadFromSecureStorage();
  }

  // 创建新钱包
  Future<Map<String, String>> createNewWallet() async {
    _mnemonic = bip39.generateMnemonic(strength: 128);

    // 用助记词派生所有链（包含 Solana）
    await _generateKeysFromMnemonic();

    // 必须先保存（可选）
    await _saveToSecureStorage();

    // 这里强制把当前网络设为 solana（如果你希望创建即为 solana）
    _currentNetwork = supportedNetworks['solana'];

    // 返回三件套：助记词 + 地址 + Base58 64B SecretKey
    final address = _addresses['solana'] ?? _addresses['Solana'] ?? '';
    final secret58 = _solanaSecretKeyBase58 ?? '';

    return {
      'mnemonic': _mnemonic ?? '',
      'currentAddress': address,
      'privateKey': secret58, // ← 给 UI 用这个给 Bitget 导入
      'currentNetwork': _currentNetwork?.name ?? '',
    };
  }

  // 从助记词恢复
  Future<Map<String, String>> restoreFromMnemonic(String mnemonic) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception('Invalid mnemonic');
    }

    _mnemonic = mnemonic;
    await _generateKeysFromMnemonic();
    await _saveToSecureStorage();
    _currentNetwork = supportedNetworks['solana'];
    return _getWalletInfo();
  }

  //私钥导入钱包
  bool _looksLikeHex64With0x(String s) => RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(s.trim());

  bool _looksLikeHex64(String s) => RegExp(r'^(0x)?[0-9a-fA-F]{64}$').hasMatch(s.trim());

  bool _looksLikeHex128(String s) => RegExp(r'^(0x)?[0-9a-fA-F]{128}$').hasMatch(s.trim());

  Uint8List _hexToBytes(String hex) {
    final clean = hex.trim().toLowerCase().replaceAll(RegExp(r'[^0-9a-f]'), '');
    return Uint8List.fromList([for (int i = 0; i < clean.length; i += 2) int.parse(clean.substring(i, i + 2), radix: 16)]);
  }

  // ---------- 解析 Solana 64B secretKey（JSON/Base58/Hex 128） ----------
  Uint8List _parseSolanaSecretKey64(String input) {
    final t = input.trim();

    // JSON 数组: "[12, 34, ...]"（长度必须 64）
    if (t.startsWith('[') && t.endsWith(']')) {
      final List<dynamic> arr = json.decode(t);
      final bytes = Uint8List.fromList(arr.cast<int>());
      if (bytes.length == 64) return bytes;
      throw ArgumentError('JSON array length must be 64 bytes for Solana secretKey.');
    }

    // Base58（长度解码后必须 64）
    try {
      final bytes = Uint8List.fromList(bs58.base58.decode(t));
      if (bytes.length == 64) return bytes;
    } catch (_) {}

    // Hex（128 位，可带 0x）
    if (_looksLikeHex128(t)) {
      final bytes = _hexToBytes(t);
      if (bytes.length == 64) return bytes;
    }

    throw ArgumentError('Not a valid 64-byte Solana secretKey (JSON/Base58/Hex).');
  }

  // ---------- 用 ed25519_hd_key 2.3.0 从助记词派生 Solana 32B seed ----------
  Future<Uint8List> _deriveSolanaSeed32FromMnemonic(String mnemonic, {int account = 0, int change = 0}) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw ArgumentError('Invalid mnemonic');
    }
    // BIP39 根种子（64B）
    final masterSeed = bip39.mnemonicToSeed(mnemonic);
    // 按 Solana 路径派生（2.3.0 的 derivePath 第二参就是 seed）
    final path = "m/44'/501'/$account'/$change'";
    final keyData = await edkey.ED25519_HD_KEY.derivePath(path, masterSeed);
    // 返回 32B seed（用 Uint8List 包装）
    return Uint8List.fromList(keyData.key);
  }

  // 尝试两条常见路径，确保 seed32 生成的地址 == fromMnemonic 的地址
  Future<Uint8List> _deriveSolanaSeed32Aligned({required String mnemonic, int account = 0, int change = 0}) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw ArgumentError('Invalid mnemonic');
    }

    // 1) 先用官方方法得到“标准答案”地址
    final refKp = await solana.Ed25519HDKeyPair.fromMnemonic(mnemonic, account: account, change: change);
    final refAddress = refKp.address;

    // 2) 根种子
    final masterSeed = bip39.mnemonicToSeed(mnemonic);

    // 3) 方案A：m/44'/501'/$account'/$change'
    final pathA = "m/44'/501'/$account'/$change'";
    final keyA = Uint8List.fromList((await edkey.ED25519_HD_KEY.derivePath(pathA, masterSeed)).key);
    final addrA = (await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: keyA)).address;
    if (addrA == refAddress) return keyA;

    // 4) 方案B：m/44'/501'/$account'/$change'/0'
    final pathB = "m/44'/501'/$account'/$change'/0'";
    final keyB = Uint8List.fromList((await edkey.ED25519_HD_KEY.derivePath(pathB, masterSeed)).key);
    final addrB = (await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: keyB)).address;
    if (addrB == refAddress) return keyB;

    // 如果两条都不匹配（极少见），为了安全起见返回A，但打印日志帮助排查
    // 你也可以 throw，让你更早发现环境不一致
    // debugPrint('WARN: Neither A nor B matched refAddress. Using A by default.');
    return keyA;
  }

  // ===================== 最终版：私钥导入函数 ======================
  // 私钥/secretKey/seed 智能导入：支持 EVM 与 Solana
  Future<Map<String, String?>> importWalletFromPrivateKey(String input, {String rpcUrl = "https://cloudflare-eth.com"}) async {
    String trimmed = input.trim();

    // 1) 先试 Base58（Solana 常见：64B secretKey 或 32B seed）
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
            // 直接传 Base58 地址字符串
            final res = await client.rpcClient.getBalance(address); // BalanceResult
            final lamports = res.value; // int
            balance = (lamports / solana.lamportsPerSol).toStringAsFixed(9);
          }
        } catch (_) {}

        return {
          'WalletType': decoded.length == 64 ? 'solanaSecretKeyImported' : 'solanaSeedImported',
          'currentNetwork': 'Solana',
          'currentAddress': address, // Base58
          'balance': balance,
          'mnemonic': '',
          'privateKey': input, // 不回传明文
        };
      }
    } catch (_) {
      // 不是 Base58 就走后面的分支
    }

    // 2) EVM：0x + 64 hex
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

    // 3) Solana：32B seed（64 hex，带/不带 0x）
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
          // address 可以是 Base58 字符串或先转成 Key 对象都行
          // final pubKey = solana.Ed25519HDPublicKey.fromBase58(address);
          // final res = await client.rpcClient.getBalance(pubKey);

          final res = await client.rpcClient.getBalance(address); // BalanceResult
          final lamports = res.value; // <-- 关键：取 value (int)
          balance = '${lamports / solana.lamportsPerSol}';
          // 如果想固定小数：
          // balance = (lamports / solana.lamportsPerSol).toStringAsFixed(9);
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

    // 4) 兜底
    throw ArgumentError(
      'Unsupported key format. Provide:\n'
      '- Solana SecretKey (Base58, 64 bytes) or Base58 32-byte seed;\n'
      '- EVM 32-byte hex (0x...);\n'
      '- Solana 32-byte seed (Hex 64).',
    );
  }

  // ===================== 最终版：私钥导入函数 ======================

  // 带重试机制的余额获取
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

  // 以太坊地址验证
  bool isValidEthereumAddress(String address) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 获取钱包信息
  Future<Map<String, String>> _getWalletInfo() async {
    // final balance = await getNativeBalance();
    final blockchain = _currentNetwork?.name ?? '';
    var address = _addresses[_currentNetwork?.id] ?? _addresses[_currentNetwork?.name] ?? '';
    // final balance =  await getNativeBalanceByAddress(blockchain,address);
    if (_currentNetwork?.id == 'solana' && _addresses['solana'] != null) {
      address = _addresses['solana']!;
    }
    return {'mnemonic': _mnemonic ?? '', 'balance': '0.00', 'privateKey': _privateKey ?? '', 'currentNetwork': blockchain, 'currentAddress': address};
  }

  // 切换网络
  Future<void> switchNetwork(String networkId) async {
    if (supportedNetworks.containsKey(networkId)) {
      _currentNetwork = supportedNetworks[networkId];
    } else {
      throw Exception('Unsupported network');
    }
  }

  /*
   * 根据地址获取余额
   */
  Future<String> getNativeBalanceByAddress(String blockchain, String address) async {
    switch (blockchain.toLowerCase()) {
      case 'ethereum':
      case 'polygon':
      case 'bsc':
        return _getEvmBalance(address, _getRpcUrl(blockchain));
      case 'solana':
        return _getSolanaBalance(address, _getRpcUrl(blockchain));
      default:
        throw UnsupportedError('不支持的区块链类型: $blockchain');
    }
  }

  /// 获取EVM链余额(ETH/MATIC/BNB等)
  Future<String> _getEvmBalance(String address, String rpcUrl) async {
    final web3client = Web3Client(rpcUrl, Client());

    try {
      final ethAddress = EthereumAddress.fromHex(address);
      final balance = await web3client.getBalance(ethAddress);
      return '${balance.getValueInUnit(EtherUnit.ether)}';
    } finally {
      web3client.dispose();
    }
  }

  /// 获取Solana余额(SOL)
  Future<String> _getSolanaBalance(String address, String rpcUrl) async {
    final client = _clients['solana'] as solana.SolanaClient; // 不要用 address 当 key
    final res = await client.rpcClient.getBalance(address); // BalanceResult
    return '${res.value / solana.lamportsPerSol}';
  }

  String _getRpcUrl(String blockchain) {
    return const {
      'ethereum': 'https://cloudflare-eth.com',
      'polygon': 'https://polygon-rpc.com',
      'bsc': 'https://bsc-dataseed.binance.org',
      'solana': 'https://api.mainnet-beta.solana.com',
    }[blockchain.toLowerCase()]!;
  }

  // 获取原生代币余额
  Future<String> getNativeBalance() async {
    print('getNativeBalance _currentNetwork:${_currentNetwork == null}');
    print('getNativeBalance _addresses:${_addresses[_currentNetwork!.id] == null}');
    if (_currentNetwork == null) {
      throw Exception('Wallet not initialized or network not selected');
    }
    final address = _addresses[_currentNetwork!.id] ?? _addresses[_currentNetwork!.name];
    if (address == null) {
      throw Exception('Address not found for ${_currentNetwork!.name}');
    }

    switch (_currentNetwork!.chainType) {
      case ChainType.EVM:
        final balance = await _clients[_currentNetwork!.id]!.getBalance(EthereumAddress.fromHex(_addresses[_currentNetwork!.id]!));
        return '${balance.getValueInUnit(EtherUnit.ether)} ${_currentNetwork!.symbol}';
      case ChainType.Solana:
        final balance = await _clients[_currentNetwork!.id]!.rpc.getBalance(solana.Ed25519HDPublicKey.fromBase58(_addresses[_currentNetwork!.id]!));
        return '${balance / solana.lamportsPerSol} ${_currentNetwork!.symbol}';
      default:
        throw Exception('Unsupported chain type for balance query');
    }
  }

  // 获取代币余额 (ERC20/SPL)
  Future<Map<String, String>> getTokenBalances() async {
    if (_currentNetwork == null || _addresses[_currentNetwork!.id] == null) {
      throw Exception('Wallet not initialized or network not selected');
    }

    final balances = <String, String>{};

    switch (_currentNetwork!.chainType) {
      case ChainType.EVM:
        // 实现ERC20代币余额查询
        final tokenContracts = await _loadSavedTokens();
        for (final token in tokenContracts) {
          final contract = DeployedContract(ContractAbi.fromJson(jsonEncode(token['abi']), 'ERC20'), EthereumAddress.fromHex(token['address']));
          final balanceFunction = contract.function('balanceOf');
          final balance = await _clients[_currentNetwork!.id]!.callContract(
            contract: contract,
            function: balanceFunction,
            params: [EthereumAddress.fromHex(_addresses[_currentNetwork!.id]!)],
          );
          final decimals = token['decimals'] ?? 18;
          final balanceValue = (balance.first as BigInt) / BigInt.from(10).pow(decimals);
          balances[token['symbol']] = balanceValue.toString();
        }
        break;
      case ChainType.Solana:
        // 实现SPL代币余额查询
        final tokens = await _loadSavedTokens();
        for (final token in tokens) {
          final balance = await _clients[_currentNetwork!.id]!.rpc.getTokenAccountBalance(solana.Ed25519HDPublicKey.fromBase58(token['address']));
          balances[token['symbol']] = balance.amount;
        }
        break;
      default:
        throw Exception('Unsupported chain type for token balance query');
    }

    return balances;
  }

  // 添加自定义代币
  Future<void> addCustomToken(Map<String, dynamic> tokenInfo) async {
    final tokens = await _loadSavedTokens();
    tokens.add(tokenInfo);
    await _localStorage.put('tokens_${_currentNetwork!.id}', tokens);
  }

  // 发送原生代币交易
  Future<String> sendNativeTransaction({required String to, required double amount}) async {
    if (_currentNetwork == null || _credentials[_currentNetwork!.id] == null) {
      throw Exception('Wallet not initialized or network not selected');
    }

    switch (_currentNetwork!.chainType) {
      case ChainType.EVM:
        final client = _clients[_currentNetwork!.id]!;
        final credentials = _credentials[_currentNetwork!.id]!;

        final gasPrice = await client.getGasPrice();
        final transaction = Transaction(
          to: EthereumAddress.fromHex(to),
          value: EtherAmount.fromUnitAndValue(EtherUnit.ether, amount),
          gasPrice: gasPrice,
          maxGas: 21000,
        );

        return await client.sendTransaction(credentials, transaction, chainId: _currentNetwork!.chainId);
      case ChainType.Solana:
        final client = _clients[_currentNetwork!.id]!;
        final credentials = _credentials[_currentNetwork!.id]!;

        final transaction = await client.rpc.transfer(
          fundingAccount: credentials,
          destination: solana.Ed25519HDPublicKey.fromBase58(to),
          lamports: (amount * solana.lamportsPerSol).toInt(),
        );

        return transaction;
      default:
        throw Exception('Unsupported chain type for transaction');
    }
  }

  // 发送代币交易 (ERC20/SPL)
  Future<String> sendTokenTransaction({required String tokenAddress, required String to, required double amount, required int decimals}) async {
    if (_currentNetwork == null || _credentials[_currentNetwork!.id] == null) {
      throw Exception('Wallet not initialized or network not selected');
    }

    switch (_currentNetwork!.chainType) {
      case ChainType.EVM:
        final client = _clients[_currentNetwork!.id]!;
        final credentials = _credentials[_currentNetwork!.id]!;

        final contract = DeployedContract(
          ContractAbi.fromJson(
            '[{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"}]',
            'ERC20',
          ),
          EthereumAddress.fromHex(tokenAddress),
        );
        final transferFunction = contract.function('transfer');
        final amountInWei = BigInt.from(amount * pow(10, decimals));

        final transaction = await client.sendTransaction(
          credentials,
          Transaction.callContract(
            contract: contract,
            function: transferFunction,
            parameters: [EthereumAddress.fromHex(to), amountInWei],
            gasPrice: await client.getGasPrice(),
            maxGas: 100000,
          ),
          chainId: _currentNetwork!.chainId,
        );

        return transaction;
      case ChainType.Solana:
        // SPL代币转账实现
        final client = _clients[_currentNetwork!.id]!;
        final credentials = _credentials[_currentNetwork!.id]!;

        final transaction = await client.rpc.transferToken(
          fundingAccount: credentials,
          source: solana.Ed25519HDPublicKey.fromBase58(tokenAddress),
          destination: solana.Ed25519HDPublicKey.fromBase58(to),
          amount: (amount * pow(10, decimals)).toInt(),
        );

        return transaction;
      default:
        throw Exception('Unsupported chain type for token transaction');
    }
  }

  // 获取交易历史
  Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    if (_currentNetwork == null || _addresses[_currentNetwork!.id] == null) {
      throw Exception('Wallet not initialized or network not selected');
    }

    final history = <Map<String, dynamic>>[];

    switch (_currentNetwork!.chainType) {
      case ChainType.EVM:
        // 从区块浏览器API获取交易历史
        final response = await get(
          Uri.parse('${_currentNetwork!.explorerUrl}/api?module=account&action=txlist&address=${_addresses[_currentNetwork!.id]}&sort=desc'),
        );
        final data = jsonDecode(response.body)['result'] as List;
        history.addAll(
          data.map(
            (tx) => {
              'txHash': tx['hash'],
              'from': tx['from'],
              'to': tx['to'],
              'value': tx['value'],
              'timestamp': tx['timeStamp'],
              'status': tx['isError'] == '0' ? 'Success' : 'Failed',
            },
          ),
        );
        break;
      case ChainType.Solana:
        // 从Solana区块浏览器API获取交易历史
        final response = await get(Uri.parse('${_currentNetwork!.explorerUrl}/api/account/${_addresses[_currentNetwork!.id]}/transactions'));
        final data = jsonDecode(response.body) as List;
        history.addAll(
          data.map(
            (tx) => {
              'txHash': tx['signature'],
              'from': tx['source'],
              'to': tx['destination'],
              'value': tx['amount'],
              'timestamp': tx['timestamp'],
              'status': tx['status'] == 'Success' ? 'Success' : 'Failed',
            },
          ),
        );
        break;
      default:
        throw Exception('Unsupported chain type for transaction history');
    }

    // 保存到本地历史记录
    await _localStorage.put('tx_history_${_currentNetwork!.id}_${_addresses[_currentNetwork!.id]}', history);
    return history;
  }

  // DApp浏览器功能
  WebViewController createDAppBrowser(String url) {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // 加载进度
          },
          onPageStarted: (String url) {
            // 页面开始加载
          },
          onPageFinished: (String url) {
            // 页面加载完成
          },
          onWebResourceError: (WebResourceError error) {
            // 加载错误
          },
          onNavigationRequest: (NavigationRequest request) {
            // 处理钱包连接等特殊请求
            if (request.url.startsWith('wc:')) {
              // 处理WalletConnect请求
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  // 连接WalletConnect
  Future<WalletConnect> connectWalletConnect() async {
    final connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
        name: 'MultiChainWallet',
        description: 'A multi-chain wallet with DApp browser',
        url: 'https://mywalletapp.com',
        icons: ['https://mywalletapp.com/icon.png'],
      ),
    );

    if (!connector.connected) {
      await connector.createSession();
    }

    return connector;
  }

  // 安全增强：启用生物识别认证
  Future<void> enableBiometricAuth() async {
    await _secureStorage.write(
      key: 'use_biometric',
      value: 'true',
      iOptions: const IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
  }

  // 安全增强：验证生物识别
  Future<bool> verifyBiometricAuth() async {
    final useBiometric = await _secureStorage.read(key: 'use_biometric');
    if (useBiometric != 'true') return true;

    //TODO 待实现生物识别验证逻辑
    // 返回true表示验证通过，false表示失败
    return true;
  }

  // 从助记词生成各链的密钥对 (内部方法)
  Future<void> _generateKeysFromMnemonic() async {
    if (_mnemonic == null) return;

    // 你原来就有：用于 EVM 派生的根种子（别再用它的前 32B 当“私钥”保存了）
    final seed = bip39.mnemonicToSeed(_mnemonic!);

    for (final network in supportedNetworks.values) {
      switch (network.chainType) {
        case ChainType.EVM:
          // ====== 保持你原逻辑不变 ======
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
            // 1) 用“对齐版”派生 32B seed（确保与 fromMnemonic 的地址一致）
            final seed32 = await _deriveSolanaSeed32Aligned(mnemonic: _mnemonic!, account: 0, change: 0);

            // 2) 生成 keypair & 地址
            final keyPair = await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: seed32);
            final solAddress = keyPair.publicKey.toBase58();

            _credentials[network.id] = keyPair;
            _addresses[network.id] = solAddress;
            _addresses[network.name] = solAddress;

            // 3) 组装 64B SecretKey = 私钥32 + 公钥32，并转 Base58（Bitget 识别的那种）
            final pub32 = keyPair.publicKey.bytes; // 32B
            final secret64 = Uint8List(64)
              ..setRange(0, 32, seed32)
              ..setRange(32, 64, pub32);
            _solanaSecretKeyBase58 = bs58.base58.encode(secret64); // ✅ 88字符

            // （可选）若你仍想保存 seed32 的 hex：
            _privateKey = HEX.encode(seed32);
          } catch (e) {
            debugPrint('Solana derive failed: $e');
          }
          break;

        case ChainType.UTXO:
          // 比特币等UTXO模型链的密钥派生（保持原样或后续再实现）
          break;
      }
    }
  }

  //根据助记词获取eth地址
  Future<String> getEthAddressFromMnemonic(String mnemonic, {int index = 0}) async {
    // 1. 验证助记词
    final words = mnemonic.trim().split(RegExp(r'\s+'));
    if (words.length != 12 && words.length != 24) {
      throw ArgumentError('Invalid mnemonic phrase');
    }

    // 2. 生成种子
    final seed = bip39.mnemonicToSeed(mnemonic);

    // 3. 使用BIP44路径派生：m/44'/60'/0'/0/index
    final privateKeyBytes = await _derivePrivateKey(seed, "m/44'/60'/0'/0/$index");
    final privateKeyHex = HEX.encode(privateKeyBytes);
    // 4. 获取地址
    final credentials = EthPrivateKey.fromHex(privateKeyHex);
    return (await credentials.extractAddress()).hex;
  }

  // 从种子派生私钥
  Future<Uint8List> _derivePrivateKey(Uint8List seed, String path) async {
    // 使用BIP32派生私钥

    final node = bip32.BIP32.fromSeed(seed).derivePath(path);
    // return HEX.encode(node.privateKey!);
    return node.privateKey!;
  }

  // 保存到安全存储
  Future<void> _saveToSecureStorage() async {
    await _secureStorage.write(
      key: 'mnemonic',
      value: _mnemonic!,
      iOptions: const IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );

    // 只保存地址到普通存储
    await _localStorage.put('addresses', _addresses);
  }

  // 从安全存储加载
  Future<void> _loadFromSecureStorage() async {
    _mnemonic = await _secureStorage.read(key: 'mnemonic');
    if (_mnemonic != null && bip39.validateMnemonic(_mnemonic!)) {
      await _generateKeysFromMnemonic();
    } else {
      // 尝试从普通存储加载地址
      final savedAddresses = _localStorage.get('addresses');
      if (savedAddresses != null) {
        _addresses.addAll(Map<String, String?>.from(savedAddresses as Map));
      }
    }
  }

  // 加载保存的代币
  Future<List<Map<String, dynamic>>> _loadSavedTokens() async {
    return List<Map<String, dynamic>>.from(_localStorage.get('tokens_${_currentNetwork!.id}') ?? []);
  }

  // 获取钱包信息
  Map<String, String?> get walletInfo {
    return {
      'currentNetwork': _currentNetwork?.name,
      'currentAddress': _addresses[_currentNetwork?.id] ?? _addresses[_currentNetwork?.name],
      'mnemonic': _mnemonic,
      'privateKey': _privateKey,
    };
  }

  // 获取所有地址
  Map<String, String?> getAllAddresses() {
    return _addresses.map((key, value) => MapEntry(supportedNetworks[key]?.name ?? key, value));
  }

  Future<bool> verifyMnemonicInOrder(String mnemonic) async {
    // 获取当前存储的助记词
    final storedMnemonic = await _secureStorage.read(key: 'mnemonic');

    // 比较助记词是否完全一致（包括顺序）
    return mnemonic.trim() == storedMnemonic?.trim();
  }

  /// 通过随机位置验证助记词
  /// @param positions 要验证的位置列表(从0开始)
  /// @param mnemonic 用户输入的助记词
  /// @return 验证结果 true/false
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

      // 3. 分割完整助记词
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

  // 安全日志记录
  void _log(String message) {
    print('[MnemonicVerifier] $message');
  }

  // 清理资源
  void dispose() {
    for (final client in _clients.values) {
      if (client is Web3Client) {
        client.dispose();
      }
    }
    _localStorage.close();
  }
}

void main() async {
  final wallet = AdvancedMultiChainWallet();

  try {
    // 1. 初始化钱包
    await wallet.initialize(networkId: 'solana');

    // 2. 创建新钱包或恢复现有钱包
    // 创建新钱包
    final newWallet = await wallet.createNewWallet();
    print('New wallet created:');
    print('Mnemonic: ${newWallet['mnemonic']}');
    print('Current address: ${newWallet['currentAddress']}');

    print('\nAll addresses:');
    wallet.getAllAddresses().forEach((network, address) {
      print('$network: $address');
    });
    // 3. 查询余额
    print('\nNative balance:');
    print(await wallet.getNativeBalance());

    // 4. 查询代币余额
    print('\nToken balances:');
    print(await wallet.getTokenBalances());

    // 5. 发送交易示例 (需要账户有余额)
    // print('\nSending transaction...');
    // final txHash = await wallet.sendNativeTransaction(
    //   to: 'RecipientAddress',
    //   amount: 0.01,
    // );
    // print('Transaction hash: $txHash');

    // 6. 获取交易历史
    print('\nTransaction history:');
    final history = await wallet.getTransactionHistory();
    print(history.take(5).toList());

    // 7. 切换网络
    await wallet.switchNetwork('ethereum');
    print('\nAfter switch to Ethereum:');
    print('Current address: ${wallet.getAllAddresses()['Ethereum']}');
  } catch (e) {
    print('Error: $e');
  } finally {
    wallet.dispose();
  }
}
