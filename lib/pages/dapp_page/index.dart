import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:collection';

import 'package:solana/dto.dart';
import 'package:solana/solana.dart' as sol;
import 'package:solana_web3/solana_web3.dart' as bs58;
import 'package:untitled1/constants/hive_boxes.dart';
import 'package:untitled1/hive/Wallet.dart';
import 'package:untitled1/theme/app_textStyle.dart';

// import 'package:cryptography/cryptography.dart';
import 'package:bs58/bs58.dart';
import 'package:convert/convert.dart';
import 'package:untitled1/util/HiveStorage.dart';
import 'package:cryptography/cryptography.dart' show Signature, SimpleKeyPair, Ed25519; // 为了识别类型

class DAppPage extends StatefulWidget {
  final String dappUrl;
  const DAppPage({super.key, required this.dappUrl});

  @override
  State<DAppPage> createState() => _DAppPageState();
}

class _DAppPageState extends State<DAppPage> {
  InAppWebViewController? _inAppWebViewController;
  bool _isLoading = true;
  double _progress = 0.0;
  bool _firstLoadCompleted = false;

  final String _solanaProviderJs = r'''
    (function() {
      if (window._flutter_solana_provider_injected) return;
      window._flutter_solana_provider_injected = true;

      const _events = {};
      let _publicKey = null;
      let _isConnected = false;
      const _injectionStartMs = performance.now();

      function _callFlutter(handlerName, arg) {
        if (!window.flutter_inappwebview || !window.flutter_inappwebview.callHandler) {
          console.error("flutter_inappwebview not available for handler:", handlerName);
          return Promise.reject('flutter_inappwebview not available');
        }
        try {
          const res = window.flutter_inappwebview.callHandler(handlerName, arg);
          // callHandler already returns a Promise-like on the webview bridge
          return Promise.resolve(res);
        } catch (e) {
          return Promise.reject(e);
        }
      }

      function _emit(event, ...args) {
        const handlers = _events[event];
        if (handlers && handlers.length) {
          handlers.slice().forEach(fn => {
            try { fn(...args); } catch (e) { console.error(e); }
          });
        }
        try {
          window.dispatchEvent(new CustomEvent('solana:' + event, { detail: args }));
        } catch (e) { /* ignore */ }
      }

      function _makePubkeyObj(pubkey) {
        if (!pubkey) return null;
        return {
          toString: function() { return pubkey; },
          toBase58: function() { return pubkey; },
          toBytes: function() {
            try {
              return new TextEncoder().encode(pubkey);
            } catch (e) { return null; }
          }
        };
      }

      const provider = {
        isPhantom: true,

        get isConnected() { return _isConnected; },
        get publicKey() { return _publicKey; },

        _events: _events,
        _injectionStartMs: _injectionStartMs,
        _injectionEndMs: performance.now(),

        // connect: keep your current behavior (Flutter returns a base58 string)
        connect: function(opts) {
          return _callFlutter('solana_connect', opts).then((pubkeyBase58) => {
            if (pubkeyBase58) {
              _publicKey = _makePubkeyObj(pubkeyBase58);
              _isConnected = true;
              _emit('connect', _publicKey);
              return { publicKey: _publicKey };
            } else {
              return Promise.reject('no_pubkey_returned');
            }
          });
        },

        // convenience alias for phantom-style usage
        async phantomConnect() {
          return this.connect();
        },

        disconnect: function() {
          return _callFlutter('solana_disconnect').then((res) => {
            // Flutter handler returns true in your code; ignore exact value
            _isConnected = false;
            _publicKey = null;
            _emit('disconnect');
            return true;
          });
        },

        // provider.request compatibility: pass through payload to Flutter
        request: function(payload) {
          // If dapp use provider.request({method: 'connect'}) -> mimic connect
          try {
            if (payload && typeof payload === 'object' && payload.method === 'connect') {
              return this.connect(payload.params || {});
            }
          } catch (e) { /* ignore */ }
          return _callFlutter('solana_request', payload);
        },

        // Signing APIs - permissive about returned formats
        signTransaction: function(tx) {
          // tx can be base64, object, etc - pass as-is
          return _callFlutter('solana_signTransaction', tx).then((res) => {
            // If Flutter returns signed tx directly, pass through
            return res;
          });
        },

        signAllTransactions: function(txs) {
          return _callFlutter('solana_signAllTransactions', txs).then((res) => res);
        },

        signAndSendTransaction: function(tx, opts) {
          return _callFlutter('solana_signAndSendTransaction', { tx: tx, opts: opts }).then((res) => {
            // expect { signature: '...' } per your Flutter handler
            return res;
          });
        },

        signAndSendAllTransactions: function(txs, opts) {
          return _callFlutter('solana_signAndSendAllTransactions', { txs: txs, opts: opts }).then((res) => res);
        },

        sendTransaction: function(tx, opts) {
          return _callFlutter('solana_sendTransaction', { tx: tx, opts: opts }).then((res) => {
            // your Flutter returns { txSignature: '...' } — return as-is
            return res;
          });
        },

        // signMessage: accept string | Uint8Array | array | object. Flutter returns { signature: '...' } in your demo.
        signMessage: function(message, encoding) {
          try {
            let payload;
            if (message instanceof Uint8Array) {
              payload = Array.from(message);
            } else if (Array.isArray(message)) {
              payload = message;
            } else if (typeof message === 'string') {
              payload = Array.from(new TextEncoder().encode(message));
            } else {
              payload = Array.from(new TextEncoder().encode(JSON.stringify(message)));
            }
            return _callFlutter('solana_signMessage', { message: payload, encoding: encoding || 'utf8' }).then((res) => {
              // normalize many possible Flutter responses:
              // - { signature: 'base58' }
              // - 'base58' or Uint8Array-like array
              if (!res) return Promise.reject('no_signature_returned');
              if (typeof res === 'string') return { signature: res };
              if (Array.isArray(res)) return { signature: Uint8Array.from(res) };
              if (res.signature) {
                // if signature is array -> convert to Uint8Array
                if (Array.isArray(res.signature)) return { signature: Uint8Array.from(res.signature) };
                return { signature: res.signature };
              }
              return { signature: res };
            });
          } catch (e) {
            return Promise.reject(e);
          }
        },

        signIn: function(payload) {
          return _callFlutter('solana_signIn', payload).then((res) => res);
        },

        on: function(event, handler) {
          _events[event] = _events[event] || [];
          _events[event].push(handler);
        },

        removeListener: function(event, handler) {
          if (!_events[event]) return;
          _events[event] = _events[event].filter(h => h !== handler);
        },

        removeAllListeners: function(event) {
          if (event) {
            _events[event] = [];
          } else {
            for (const k in _events) { _events[k] = []; }
          }
          return _callFlutter('solana_removeAllListeners', event);
        },

        handleNotification: function(notification) {
          return _callFlutter('solana_handleNotification', notification);
        }
      };

      // expose provider as window.solana
      try {
        Object.defineProperty(window, 'solana', {
          value: provider,
          writable: false,
          configurable: false,
          enumerable: true
        });
      } catch (e) {
        window.solana = provider;
      }

      // expose phantom compatibility at window.phantom.solana
      try {
        if (!window.phantom) {
          Object.defineProperty(window, 'phantom', {
            value: { solana: provider },
            writable: false,
            configurable: false,
            enumerable: true
          });
        } else if (!window.phantom.solana) {
          try {
            Object.defineProperty(window.phantom, 'solana', {
              value: provider,
              writable: false,
              configurable: false,
              enumerable: true
            });
          } catch (e) {
            window.phantom.solana = provider;
          }
        } else {
          window.phantom.solana = provider;
        }
      } catch (e) {
        window.phantom = window.phantom || {};
        window.phantom.solana = provider;
      }

      // allow Flutter to inject events into the page (connect/disconnect/other)
      window._flutter_injectEvent = function(event, data) {
        if (event === 'connect') {
          _publicKey = _makePubkeyObj(data);
          _isConnected = true;
        } else if (event === 'disconnect') {
          _publicKey = null;
          _isConnected = false;
        }
        _emit(event, data);
      };
    })();
  ''';

  // 模拟当前公钥，真实项目从你的 WalletService/状态管理取
  String? _currentPubkey;
  Wallet? _wallet;
  Map<dynamic, dynamic>? _currentNetwork;

  // 缓存派生出来的密钥对（避免每次都算）
  sol.Ed25519HDKeyPair? _hdKeypair;
  String? _derivedAddress; // base58

  @override
  void initState() {
    super.initState();
    _ensureWalletReady();
  }

  // 获取当前选中的钱包信息

  Future<void> _ensureWalletReady() async {
    final rawNet = await HiveStorage().getObject<Map>('currentNetwork');
    final wallet = await HiveStorage().getObject<Wallet>('currentSelectWallet', boxName: boxWallet);

    _wallet = wallet;
    _currentNetwork = (rawNet == null) ? {'id': 'Solana', 'path': 'assets/images/solana.png'} : Map<String, dynamic>.from(rawNet);

    // **关键：用助记词派生密钥对与地址**
    if (wallet?.mnemonic != null && wallet!.mnemonic!.isNotEmpty) {
      final mnemonic = wallet.mnemonic!.join(' ');
      _hdKeypair = await sol.Ed25519HDKeyPair.fromMnemonic(
        mnemonic,
        account: 0,
        change: 0, // m/44'/501'/0'/0'
      );
      _derivedAddress = _hdKeypair!.address; // base58
    }

    // 连接时用哪把地址？
    // 以“助记词派生地址”为准，避免‘地址和私钥不匹配’的问题
    _currentPubkey = _derivedAddress ?? wallet?.address;

    if (mounted) setState(() {});
  }

  List<int> _signatureToBytes(dynamic sigAny) {
    if (sigAny is Signature) return sigAny.bytes; // cryptography.Ed25519().sign(...)
    if (sigAny is Uint8List) return sigAny; // solana.Ed25519HDKeyPair.sign(...) 通常是这个
    if (sigAny is List<int>) return sigAny;
    try {
      // 兜底：某些类型可能也有 bytes 字段
      final bytes = (sigAny as dynamic).bytes as List<int>;
      return bytes;
    } catch (_) {
      throw ArgumentError('unsupported_signature_type: ${sigAny.runtimeType}');
    }
  }

  String normalizeUrl(String input) {
    final s = input.trim();
    if (s.isEmpty) return '';

    // 已经是完整 URL
    if (s.startsWith('http://') || s.startsWith('https://')) return s;

    // 以 // 开头的协议相对地址
    if (s.startsWith('//')) return 'https:$s';

    // 看起来像域名或路径（不含空格且包含点）
    final domainLike = RegExp(r'^[\w-]+(\.[\w-]+)+([/\?#].*)?$').hasMatch(s);
    if (domainLike) return 'https://$s';

    // 其他当作搜索词
    return 'https://www.google.com/search?q=${Uri.encodeComponent(s)}';
  }

  // 尝试把钱包转成 Ed25519 密钥对，并返回 (keyPair, publicKeyBase58)
  // Future<(SimpleKeyPair, String)> _resolveEd25519Keypair(Wallet w) async {
  //   final algo = Ed25519();

  //   // 1) 若你存的是 32 字节 HEX（seed），长度一般是 64 个 hex 字符
  //   if (w.privateKey.isNotEmpty && w.privateKey.length == 64 && RegExp(r'^[0-9a-fA-F]+$').hasMatch(w.privateKey)) {
  //     final seed = Uint8List.fromList(hex.decode(w.privateKey));
  //     final keyPair = await algo.newKeyPairFromSeed(seed); // 32-byte seed
  //     final pub = await keyPair.extractPublicKey();
  //     final pub58 = bs58.base58Encode(Uint8List.fromList(pub.bytes));
  //     return (keyPair, pub58);
  //   }

  //   // 2) 若你存的是 base58 的 64 字节 secretKey（很多 SDK 这么存）
  //   //    base58 解出来应为 64 字节: [32-byte secret(seed) || 32-byte publicKey]
  //   try {
  //     final sec = bs58.base58Decode(w.privateKey);
  //     if (sec.length == 64) {
  //       final seed32 = sec.sublist(0, 32);
  //       final keyPair = await algo.newKeyPairFromSeed(seed32);
  //       final pub = await keyPair.extractPublicKey();
  //       final pub58 = bs58.base58Encode(Uint8List.fromList(pub.bytes));
  //       return (keyPair, pub58);
  //     }
  //   } catch (_) {
  //     // ignore
  //   }

  //   // 3) 若你存的是 128 hex（64 字节 secretKey 的 hex）
  //   if (w.privateKey.length == 128 && RegExp(r'^[0-9a-fA-F]+$').hasMatch(w.privateKey)) {
  //     final sec = Uint8List.fromList(hex.decode(w.privateKey));
  //     if (sec.length == 64) {
  //       final seed32 = sec.sublist(0, 32);
  //       final keyPair = await algo.newKeyPairFromSeed(seed32);
  //       final pub = await keyPair.extractPublicKey();
  //       final pub58 = bs58.base58Encode(Uint8List.fromList(pub.bytes));
  //       return (keyPair, pub58);
  //     }
  //   }

  //   // 4) 若你有助记词，建议**优先**从助记词按 Solana 路径派生 (m/44'/501'/0'/0')
  //   //    需要你项目里接入 ed25519 slip-0010 派生库；示例略（可按你现有方案实现）
  //   //    —— 如果你用 solana 库，可以用 Ed25519HDKeyPair.fromMnemonic 派生，然后取 secret/public。
  //   throw StateError('Unsupported privateKey format for Ed25519/ Solana.');
  // }

  @override
  Widget build(BuildContext context) {
    debugPrint(widget.dappUrl);
    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(title: const Text("dapp")),
            body: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(normalizeUrl(widget.dappUrl))),
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
                UserScript(source: _solanaProviderJs, injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START, forMainFrameOnly: false),
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
                    // 兜底：如果 initState 的异步还没完成，这里再确保一次
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

                      // （可选）一致性校验
                      if (_hdKeypair!.address != _currentPubkey) {
                        return {'code': 4000, 'message': 'public_key_mismatch_with_mnemonic'};
                      }

                      // === 关键：把签名结果转成 List<int> 再返回 ===
                      final sigAny = await _hdKeypair!.sign(messageBytes);
                      late final List<int> sigBytes;

                      if (sigAny is Uint8List) {
                        sigBytes = _signatureToBytes(sigAny); // Uint8List 本质也能当 List<int>，但为保险可 toList()
                      } else if (sigAny is List<int>) {
                        sigBytes = _signatureToBytes(sigAny);
                      } else if (sigAny is Signature) {
                        // cryptography.Ed25519().sign(...) 的返回类型
                        sigBytes = sigAny.bytes;
                      } else {
                        // 兜底：尽可能转 List<int>
                        try {
                          final u8 = (sigAny as dynamic).bytes as List<int>;
                          sigBytes = u8;
                        } catch (_) {
                          return {'code': 4000, 'message': 'unsupported_signature_type'};
                        }
                      }

                      // 返回给 DApp：必须是 “字节数组”
                      return {'signature': sigBytes};
                    } catch (e, st) {
                      debugPrint('signMessage error: $e\n$st');
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

                // signTransaction
                controller.addJavaScriptHandler(
                  handlerName: 'solana_signTransaction',
                  callback: (args) async {
                    debugPrint('solana_signTransaction args: $args');
                    if (_currentPubkey == null) throw 'no_wallet_connected';

                    final tx = args.isNotEmpty ? args[0] : null;
                    if (tx == null) throw 'invalid_tx';

                    // TODO: 弹出确认并签名 tx
                    return tx; // demo 返回原 tx
                  },
                );

                // signAllTransactions
                controller.addJavaScriptHandler(
                  handlerName: 'solana_signAllTransactions',
                  callback: (args) async {
                    debugPrint('solana_signAllTransactions args: $args');
                    if (_currentPubkey == null) throw 'no_wallet_connected';

                    final txs = args.isNotEmpty ? args[0] : null;
                    if (txs == null) throw 'invalid_txs';

                    // TODO: 批量签名 txs
                    return txs; // demo 返回原 txs
                  },
                );

                // signAndSendTransaction
                controller.addJavaScriptHandler(
                  handlerName: 'solana_signAndSendTransaction',
                  callback: (args) async {
                    debugPrint('solana_signAndSendTransaction args: $args');
                    if (_currentPubkey == null) throw 'no_wallet_connected';

                    final body = args.isNotEmpty ? args[0] : null;
                    // TODO: 签名并发送 tx
                    return {'signature': 'demo_signature_123'};
                  },
                );

                // signAndSendAllTransactions
                controller.addJavaScriptHandler(
                  handlerName: 'solana_signAndSendAllTransactions',
                  callback: (args) async {
                    debugPrint('solana_signAndSendAllTransactions args: $args');
                    if (_currentPubkey == null) throw 'no_wallet_connected';

                    final body = args.isNotEmpty ? args[0] : null;
                    // TODO: 批量签名并广播
                    return {'signatures': []};
                  },
                );

                // sendTransaction
                controller.addJavaScriptHandler(
                  handlerName: 'solana_sendTransaction',
                  callback: (args) async {
                    debugPrint('solana_sendTransaction args: $args');
                    final body = args.isNotEmpty ? args[0] : null;

                    // TODO: 签名并发送 tx 到 RPC
                    return {'txSignature': '5YcExampleTxSignatureMocked12345'};
                  },
                );

                // signIn
                controller.addJavaScriptHandler(
                  handlerName: 'solana_signIn',
                  callback: (args) async {
                    debugPrint('solana_signIn args: $args');
                    // TODO: 实现 SIW 流程
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

                if (_currentPubkey != null) {
                  await controller.evaluateJavascript(
                    source:
                        """
                        if (window.solana && !window.solana.isConnected) {
                          window.solana.publicKey = { toString: function() { return '${_currentPubkey}'; } };
                          window.solana.isConnected = true;
                          try { window.dispatchEvent(new CustomEvent('solana:connect', {detail: ['${_currentPubkey}']})); } catch(e) {}
                        }
                      """,
                  );
                }
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
          if (_isLoading) _isLoadingWidget(),
        ],
      ),
    );
  }

  Widget _isLoadingWidget() {
    return Positioned.fill(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 40),
              const Icon(Icons.flutter_dash, size: 64),
              const SizedBox(height: 20),
              Text("正在加载 DApp...", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onBackground)),
            ],
          ),
        ),
      ),
    );
  }

  Future _solanaConnectShowModalBottomSheetWidget(Wallet wallet, Map<dynamic, dynamic> network, String message) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 👈 必须加这个，允许内容超出默认高度
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Material(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
                        child: Stack(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text("签名信息", style: AppTextStyles.headline3.copyWith(color: Theme.of(context).colorScheme.onBackground))],
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () {
                                  if (Navigator.of(context).canPop()) Navigator.of(context).pop(false);
                                },
                                child: Icon(Icons.close, size: 28, color: Theme.of(context).colorScheme.onBackground),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: const Color(0xFFE7E7E7), height: .5.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('请求签名', style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                            SizedBox(height: 8.w),

                            Text.rich(
                              TextSpan(
                                text: "来自 ",
                                style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                                children: [
                                  TextSpan(
                                    text: "wpos.pro",
                                    style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onBackground),
                                  ),
                                  TextSpan(
                                    text: " 的请求",
                                    style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.w),
                            Container(
                              width: double.infinity,
                              height: 200,
                              padding: EdgeInsetsDirectional.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(message, style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                            ),
                            SizedBox(height: 16.w),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Wallet", style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                                Row(
                                  children: [
                                    Image.asset('assets/images/ic_clip_photo.png', width: 20, height: 20),
                                    SizedBox(width: 8.w),
                                    Text(_wallet!.name, style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 16.w),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Network", style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                                Row(
                                  children: [
                                    Image.asset(network["image"], width: 20, height: 20),
                                    SizedBox(width: 8.w),
                                    Text(network["id"], style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20.w),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context).pop({"code": 4001, "message": "User rejected the request."}),
                                    child: Container(
                                      width: double.infinity,
                                      height: 60,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 1, color: Theme.of(context).colorScheme.onBackground),
                                        borderRadius: BorderRadius.circular(50.r),
                                      ),
                                      child: Text("取消", style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 30.w),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 60,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        // border: Border.all(width: 1, color: Theme.of(context).colorScheme.onBackground),
                                        borderRadius: BorderRadius.circular(50.r),
                                      ),
                                      child: Text("签名", style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
