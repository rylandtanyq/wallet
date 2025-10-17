import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:collection';

import 'package:solana/dto.dart';
import 'package:untitled1/dao/HiveStorage.dart';
import 'package:untitled1/entity/Wallet.dart';
import 'package:untitled1/theme/app_textStyle.dart';

import 'package:cryptography/cryptography.dart';
import 'package:bs58/bs58.dart';
import 'package:convert/convert.dart';

class DAppPage extends StatefulWidget {
  const DAppPage({super.key});

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
  late Wallet _wallet;
  late Map<dynamic, dynamic>? _currentNetwork;

  @override
  void initState() {
    super.initState();
    _currentNetwork = HiveStorage().getObject<Map>('currentNetwork');
    _wallet = HiveStorage().getObject('currentSelectWallet') ?? Wallet.empty();
    debugPrint('1-->$_currentNetwork');
    debugPrint('3-->${_wallet.address}');
  }

  /// 双 Base64 签名函数
  Future<String> signMessageBase64Double(String privateKeyHex, Uint8List messageBytes) async {
    final algorithm = Ed25519();
    final seed = Uint8List.fromList(_hexToBytes(privateKeyHex));
    final keyPair = await algorithm.newKeyPairFromSeed(seed);

    // 签名
    final signature = await algorithm.sign(messageBytes, keyPair: keyPair);

    // 1️⃣ 将签名 bytes 转为 Base64
    final base64Sig = base64.encode(signature.bytes);

    // 2️⃣ JS 的 btoa 相当于 ascii -> Base64
    final asciiBytes = base64Sig.codeUnits;
    final doubleBase64 = base64.encode(asciiBytes);

    return doubleBase64;
  }

  /// Hex 字符串转 Uint8List
  Uint8List _hexToBytes(String hexStr) {
    final cleaned = hexStr.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    final result = Uint8List(cleaned.length ~/ 2);
    for (var i = 0; i < cleaned.length; i += 2) {
      result[i ~/ 2] = int.parse(cleaned.substring(i, i + 2), radix: 16);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(title: const Text("dapp")),
            body: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri("https://wpos.pro/")),
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

                // 注入 JS provider
                // controller.addUserScript(
                //   userScript: UserScript(
                //     source: _solanaProviderJs, // 你合并后的 JS
                //     injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                //   ),
                // );

                // connect
                controller.addJavaScriptHandler(
                  handlerName: 'solana_connect',
                  callback: (args) async {
                    debugPrint('solana_connect args: $args');

                    return {'publicKey': _wallet.address};
                  },
                );

                // signMessage
                controller.addJavaScriptHandler(
                  handlerName: 'solana_signMessage',
                  callback: (args) async {
                    final allow = await _solanaConnectShowModalBottomSheetWidget(_wallet, _currentNetwork!, 'DApp 请求签名消息');
                    if (allow != true) throw 'user_rejected';

                    final payload = args.isNotEmpty ? args[0] : null;
                    final msg = payload is Map && payload['message'] != null ? payload['message'] as List<dynamic> : null;
                    if (msg == null) throw 'invalid_message';

                    final Uint8List messageBytes = Uint8List.fromList(msg.cast<int>());
                    final privateKeyHex = _wallet.privateKey;

                    final algorithm = Ed25519();
                    final seed = Uint8List.fromList(_hexToBytes(privateKeyHex));
                    final keyPair = await algorithm.newKeyPairFromSeed(seed);
                    final signature = await algorithm.sign(messageBytes, keyPair: keyPair);

                    // ✅ 返回原始字节数组（Phantom 返回的也是 Uint8Array）
                    return {"signature": signature.bytes};
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
                                    Text(_wallet.name, style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onBackground)),
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
                                    Image.asset(network["path"], width: 20, height: 20),
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
                                      child: Text("签名", style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
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
