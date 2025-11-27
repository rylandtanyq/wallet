import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_setting/state/app_provider.dart';
import 'package:shared_utils/hive_storage.dart';
import 'dart:collection';

import 'package:solana/solana.dart' as sol;
import 'package:solana_web3/solana_web3.dart' as bs58;
import 'package:solana_web3/solana_web3.dart' as convert;
import 'package:shared_utils/hive_boxes.dart';
import 'package:feature_wallet/hive/Wallet.dart';
import 'package:feature_browser/dapp_browser/fragments/loading_fragments.dart';
import 'package:feature_browser/dapp_browser/fragments/solana_contract_interaction_fragments.dart';
import 'package:feature_browser/dapp_browser/fragments/solana_provide_js_fragments.dart';
import 'package:feature_browser/dapp_browser/fragments/solana_sign_bottom_sheet_fragments.dart';
import 'package:cryptography/cryptography.dart' show Signature; // 为了识别类型

class DappBrowser extends ConsumerStatefulWidget {
  final String dappUrl;
  const DappBrowser({super.key, required this.dappUrl});

  @override
  ConsumerState<DappBrowser> createState() => _DAppPageState();
}

class _DAppPageState extends ConsumerState<DappBrowser> {
  InAppWebViewController? _inAppWebViewController;
  bool _isLoading = true;
  double _progress = 0.0;
  bool _firstLoadCompleted = false;

  String? _currentPubkey;
  Wallet? _wallet;
  Map<dynamic, dynamic>? _currentNetwork;

  // 缓存派生出来的密钥对
  sol.Ed25519HDKeyPair? _hdKeypair;
  String? _derivedAddress; // base58

  @override
  void initState() {
    super.initState();
    _ensureWalletReady();
  }

  Future<void> _ensureWalletReady() async {
    final rawNet = await HiveStorage().getObject<Map>('currentNetwork');
    final wallet = await HiveStorage().getObject<Wallet>('currentSelectWallet', boxName: boxWallet);
    _wallet = wallet;
    _currentNetwork = (rawNet == null) ? {'id': 'Solana', 'path': 'assets/images/solana.png'} : Map<String, dynamic>.from(rawNet);

    _hdKeypair = null;
    _derivedAddress = null;

    if (wallet != null) {
      if (wallet.mnemonic != null && wallet.mnemonic!.isNotEmpty) {
        final mnemonic = wallet.mnemonic!.join(' ');
        _hdKeypair = await sol.Ed25519HDKeyPair.fromMnemonic(
          mnemonic,
          account: 0,
          change: 0, // m/44'/501'/0'/0'
        );
        _derivedAddress = _hdKeypair!.address; // base58
      } else if (wallet.privateKey.isNotEmpty) {
        try {
          final pkStr = wallet.privateKey.trim();

          Uint8List seed32;

          // 判断是不是纯 hex（0-9a-fA-F），且长度是偶数
          final isHex = RegExp(r'^[0-9a-fA-F]+$').hasMatch(pkStr) && pkStr.length % 2 == 0;

          if (isHex) {
            // hex 私钥
            final bytes = Uint8List.fromList(convert.hex.decode(pkStr));
            if (bytes.length == 32) {
              seed32 = bytes;
            } else if (bytes.length == 64) {
              seed32 = bytes.sublist(0, 32);
            } else {
              throw Exception('hex private key must be 32 or 64 bytes, got ${bytes.length}');
            }
          } else {
            // base58 私钥: 跟 Phantom 一样
            final bytes = Uint8List.fromList(bs58.base58Decode(pkStr));
            if (bytes.length == 32) {
              seed32 = bytes;
            } else if (bytes.length == 64) {
              // Solana 常见：64 字节 secretKey = 32 seed + 32 publicKey
              seed32 = bytes.sublist(0, 32);
            } else {
              throw Exception('base58 private key must be 32 or 64 bytes, got ${bytes.length}');
            }
          }

          _hdKeypair = await sol.Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: seed32);
          _derivedAddress = _hdKeypair!.address;
        } catch (e, st) {
          debugPrint('init from privateKey failed: $e\n$st');
        }
      }
    }

    // 最终对外暴露的公钥
    _currentPubkey = _derivedAddress ?? wallet?.address;

    if (mounted) setState(() {});
  }

  List<int> _signatureToBytes(dynamic sigAny) {
    if (sigAny is Signature) return sigAny.bytes; // cryptography.Ed25519().sign()
    if (sigAny is Uint8List) return sigAny; // solana.Ed25519HDKeyPair.sign()
    if (sigAny is List<int>) return sigAny;
    try {
      final bytes = (sigAny as dynamic).bytes as List<int>;
      return bytes;
    } catch (_) {
      throw ArgumentError('unsupported_signature_type: ${sigAny.runtimeType}');
    }
  }

  String normalizeUrl(String input) {
    final s = input.trim();
    if (s.isEmpty) return '';

    if (s.startsWith('http://') || s.startsWith('https://')) return s;

    if (s.startsWith('//')) return 'https:$s';

    final domainLike = RegExp(r'^[\w-]+(\.[\w-]+)+([/\?#].*)?$').hasMatch(s);
    if (domainLike) return 'https://$s';

    return 'https://www.google.com/search?q=${Uri.encodeComponent(s)}';
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);

    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(title: const Text("dapp")),
            body: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(normalizeUrl('http://172.20.157.158:3301/'))),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                javaScriptCanOpenWindowsAutomatically: true,
                useShouldOverrideUrlLoading: true,
                allowsInlineMediaPlayback: true,
                mediaPlaybackRequiresUserGesture: false,
                allowFileAccessFromFileURLs: true,
                allowUniversalAccessFromFileURLs: true,
                clearCache: false,
                transparentBackground: false,
                supportZoom: false,
                useWideViewPort: true,
              ),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  // 其他跨平台选项按需添加
                  useOnDownloadStart: false,
                ),
                android: AndroidInAppWebViewOptions(
                  // 根据需要设置
                  useHybridComposition: true,
                ),
                ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true),
              ),

              initialUserScripts: UnmodifiableListView<UserScript>([
                UserScript(source: kSolanaProviderJs, injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START, forMainFrameOnly: false),
              ]),
              onWebViewCreated: (controller) async {
                if (_inAppWebViewController != null) return;
                InAppWebViewController.setWebContentsDebuggingEnabled(true);
                _inAppWebViewController = controller;

                await controller.setSettings(
                  settings: InAppWebViewSettings(
                    userAgent:
                        "Mozilla/5.0 (Linux; Android 14; Samsung S24+) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Mobile Safari/537.36",
                  ),
                );

                // connect
                controller.addJavaScriptHandler(
                  handlerName: 'solana_connect',
                  callback: (args) async {
                    // 如果 initState 的异步还没完成，这里再确保一次
                    if (_wallet == null || _currentPubkey == null) await _ensureWalletReady();
                    final pk = _currentPubkey ?? '';
                    if (pk.isEmpty) return {'code': 4100, 'message': 'no_wallet_connected'};
                    return pk; // 只返回字符串，JS 会包成 { publicKey }
                  },
                );

                // signMessage
                controller.addJavaScriptHandler(
                  handlerName: 'solana_signMessage',
                  callback: (args) async {
                    try {
                      if (_wallet == null || _currentPubkey == null) await _ensureWalletReady();
                      if (_hdKeypair == null || _currentPubkey == null) {
                        return {'code': 4100, 'message': 'no_wallet_connected_or_no_mnemonic'};
                      }

                      final payload = (args.isNotEmpty ? args[0] : null) as Map?;
                      final msgList = (payload?['message'] as List?)?.cast<int>() ?? const <int>[];
                      final messageBytes = Uint8List.fromList(msgList);

                      final approved = await _solanaConnectShowModalBottomSheetWidget(_wallet!, _currentNetwork ?? {}, 'DApp 请求签名消息');
                      if (approved != true) {
                        return {'code': 4001, 'message': 'User rejected the request.'};
                      }

                      // 一致性校验
                      if (_hdKeypair!.address != _currentPubkey) {
                        return {'code': 4000, 'message': 'public_key_mismatch_with_mnemonic'};
                      }

                      // 把签名结果转成 List<int> 再返回
                      final sigAny = await _hdKeypair!.sign(messageBytes);
                      late final List<int> sigBytes;

                      if (sigAny is Uint8List) {
                        sigBytes = _signatureToBytes(sigAny); // Uint8List 本质也能当 List<int>，但为保险可 toList()
                      } else if (sigAny is List<int>) {
                        sigBytes = _signatureToBytes(sigAny);
                      } else if (sigAny is Signature) {
                        // cryptography.Ed25519().sign() 的返回类型
                        sigBytes = sigAny.bytes;
                      } else {
                        // 尽可能转 List<int>
                        try {
                          final u8 = (sigAny as dynamic).bytes as List<int>;
                          sigBytes = u8;
                        } catch (e) {
                          return {'code': 4000, 'message': 'unsupported_signature_type'};
                        }
                      }
                      // 返回给 DApp：必须是 "字节数组"
                      return {'signature': sigBytes};
                    } catch (e, st) {
                      debugPrint('signMessage error: $e\n$st');
                      return {'code': 4000, 'message': 'internal_error'};
                    }
                  },
                );

                // signTransaction
                controller.addJavaScriptHandler(
                  handlerName: 'solana_signTransaction',
                  callback: (args) async {
                    debugPrint('===> solana_signTransaction called, args: $args');

                    try {
                      // 确保钱包 & keypair 准备好
                      if (_wallet == null || _currentPubkey == null || _hdKeypair == null) {
                        await _ensureWalletReady();
                      }
                      debugPrint('after _ensureWalletReady: pubkey=$_currentPubkey, hdKeypair null? ${_hdKeypair == null}');

                      if (_hdKeypair == null || _currentPubkey == null) {
                        return {'code': 4100, 'message': 'no_wallet_connected_or_no_keypair'};
                      }

                      // 解析 message & preview
                      final body = (args.isNotEmpty ? args[0] : {}) as Map;
                      final messageBase64 = body['messageBase64'] as String?;
                      final txPreview = (body['preview'] as Map?) ?? const {};

                      if (messageBase64 == null || messageBase64.isEmpty) {
                        return {'code': 4000, 'message': 'missing_message_base64'};
                      }
                      final msg = base64Decode(messageBase64);

                      // 拉起「合约交互」弹窗
                      if (!mounted) {
                        return {'code': 4000, 'message': 'page_not_mounted'};
                      }

                      final ok = await _solanaContractInteractionBottomSheetWidget(txPreview, _wallet!, widget.dappUrl);
                      if (ok != true) {
                        return {'code': 4001, 'message': 'User rejected the request.'};
                      }

                      // 安全检查：当前 address 必须和 keypair 一致
                      if (_hdKeypair!.address != _currentPubkey) {
                        return {'code': 4000, 'message': 'public_key_mismatch'};
                      }

                      // 真正签名
                      final sig = await _hdKeypair!.sign(msg); // Uint8List(64)

                      // 返回给 JS
                      return {
                        'publicKey': _currentPubkey,
                        'signature': sig, // 会自动变 List<int>
                      };
                    } catch (e, st) {
                      debugPrint('signTransaction error: $e\n$st');
                      return {'code': 4000, 'message': 'internal_error'};
                    }
                  },
                );

                // sendTransaction
                controller.addJavaScriptHandler(
                  handlerName: 'solana_sendTransaction',
                  callback: (args) async {
                    debugPrint('solana_sendTransaction');
                    try {
                      final body = (args.isNotEmpty ? args[0] : {}) as Map;
                      final signedTxBase64 = body['signedTxBase64'] as String?;
                      final opts = (body['opts'] as Map?) ?? {};
                      if (signedTxBase64 == null || signedTxBase64.isEmpty) {
                        return {'code': 4000, 'message': 'missing_signed_tx_base64'};
                      }

                      final rpcUrl = 'https://purple-capable-crater.solana-mainnet.quiknode.pro/63bde1d4d678bfd3b06aced761d21c282568ef32/';
                      final payload = {
                        'jsonrpc': '2.0',
                        'id': 1,
                        'method': 'sendTransaction',
                        'params': [
                          signedTxBase64,
                          {
                            'encoding': 'base64',
                            'preflightCommitment': opts['preflightCommitment'] ?? 'processed',
                            'skipPreflight': opts['skipPreflight'] ?? false,
                            'maxRetries': opts['maxRetries'] ?? 5,
                          },
                        ],
                      };

                      final resp = await http.post(Uri.parse(rpcUrl), headers: {'content-type': 'application/json'}, body: jsonEncode(payload));
                      final data = jsonDecode(resp.body);
                      if (data['error'] != null) {
                        return {'code': 4000, 'message': 'rpc_error', 'details': data['error']};
                      }
                      return {'signature': data['result'] as String};
                    } catch (e) {
                      return {'code': 4000, 'message': 'internal_error'};
                    }
                  },
                );

                // disconnect
                controller.addJavaScriptHandler(
                  handlerName: 'solana_disconnect',
                  callback: (args) async {
                    debugPrint('solana_disconnect args: $args');
                    _currentPubkey = null;
                    return true;
                  },
                );

                // generic request
                controller.addJavaScriptHandler(
                  handlerName: 'solana_request',
                  callback: (args) async {
                    debugPrint('solana_request args: $args');
                    final payload = args.isNotEmpty ? args[0] : null;

                    if (payload is Map && payload['method'] == 'connect') {
                      _currentPubkey ??= '6bPZLzFBnYNdZbAkCgkB47j5XyZmgfQaVkNECNZNCRL2';
                      return {'publicKey': _currentPubkey};
                    }

                    return {'error': 'method_not_implemented', 'payload': payload};
                  },
                );

                // signAndSendAllTransactions
                controller.addJavaScriptHandler(
                  handlerName: 'solana_signAndSendAllTransactions',
                  callback: (args) async {
                    debugPrint('solana_signAndSendAllTransactions args: $args');
                    if (_currentPubkey == null) throw 'no_wallet_connected';

                    final body = args.isNotEmpty ? args[0] : null;
                    // 批量签名并广播
                    return {'signatures': []};
                  },
                );

                // signIn
                controller.addJavaScriptHandler(
                  handlerName: 'solana_signIn',
                  callback: (args) async {
                    debugPrint('solana_signIn args: $args');
                    // 实现 SIW 流程
                    return {'status': 'signed_in'};
                  },
                );

                // removeAllListeners
                controller.addJavaScriptHandler(
                  handlerName: 'solana_removeAllListeners',
                  callback: (args) async {
                    debugPrint('solana_removeAllListeners args: $args');
                    return true;
                  },
                );

                // handleNotification
                controller.addJavaScriptHandler(
                  handlerName: 'solana_handleNotification',
                  callback: (args) async {
                    debugPrint('solana_handleNotification args: $args');
                    return true;
                  },
                );
              },

              onLoadStart: (controller, url) {
                // 仅第一次加载显示 loading
                if (!_firstLoadCompleted) {
                  setState(() {
                    _isLoading = true;
                    _progress = 0.0;
                  });
                }
              },

              onProgressChanged: (controller, progress) {
                // progress 是 0 - 100
                debugPrint('加载进度: $progress');
                setState(() {
                  _progress = progress / 100.0;
                });
              },

              onLoadStop: (controller, url) async {
                if (!_firstLoadCompleted) {
                  setState(() {
                    _isLoading = false;
                    _progress = 1.0;
                    _firstLoadCompleted = true;
                  });
                } else {
                  setState(() => _progress = 1.0);
                }
              },

              onConsoleMessage: (controller, consoleMessage) {
                debugPrint('DAPP console [${consoleMessage.messageLevel}] ${consoleMessage.message}');
              },

              onReceivedError: (controller, request, error) {
                debugPrint('加载错误: $error');
                setState(() {
                  _isLoading = false;
                  _progress = 0.0;
                });
              },
            ),
          ),
          if (_isLoading) LoadingFragments(progress: _progress),
        ],
      ),
    );
  }

  Future<bool?> _solanaConnectShowModalBottomSheetWidget(Wallet wallet, Map<dynamic, dynamic> network, String message) {
    return SolanaSignBottomSheetFragments.show(context, wallet: wallet, network: network, message: message, dappName: 'wpos.pro');
  }

  Future<bool?> _solanaContractInteractionBottomSheetWidget(Map<dynamic, dynamic> txPreview, Wallet wallet, String dappUrl) {
    return SolanaContractInteractionFragments.show(context, txPreview: txPreview, wallet: wallet, dappUrl: dappUrl);
  }
}
