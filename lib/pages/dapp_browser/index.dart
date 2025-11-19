import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
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
  Map<String, dynamic> _err(int code, String msg, [dynamic details]) => {'code': code, 'message': msg, if (details != null) 'details': details};

  final String _solanaProviderJs = r'''
    (function() {
      if (window._flutter_solana_provider_injected) return;
        window._flutter_solana_provider_injected = true;

        // 包装 console，展开对象，方便在 Flutter 日志里看
        (function() {
          const rawLog = console.log.bind(console);
          const rawError = console.error.bind(console);

          function _formatArg(arg) {
            try {
              // Error 对象：优先 stack / message
              if (arg instanceof Error) {
                return arg.stack || arg.message || String(arg);
              }
              // 普通对象：尝试转成 JSON
              if (typeof arg === 'object') {
                return JSON.stringify(arg);
              }
              // 其他类型：转成字符串
              return String(arg);
            } catch (e) {
              try {
                return JSON.stringify(arg);
              } catch (_) {
                return String(arg);
              }
            }
          }

          console.log = function(...args) {
            const formatted = args.map(_formatArg);
            rawLog.apply(console, formatted);
          };

          console.error = function(...args) {
            const formatted = args.map(_formatArg);
            rawError.apply(console, formatted);
          };
        })();

        const _events = {};
        // 专门给 AnchorProvider 用的钱包地址（base58 字符串）
        let _publicKeyBase58 = null;
        // Phantom 风格的公钥对象（有 toBase58 / toString），只给 DApp 用
        let _phantomPublicKey = null;
        let _isConnected = false;
        const _injectionStartMs = performance.now();

        function _callFlutter(handlerName, arg) {
          if (!window.flutter_inappwebview || !window.flutter_inappwebview.callHandler) {
            console.error("flutter_inappwebview not available for handler:", handlerName);
            return Promise.reject('flutter_inappwebview not available');
          }
          try {
            const res = window.flutter_inappwebview.callHandler(handlerName, arg);
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

            // ===== 新版：带 toBuffer 的公钥对象（兼容 Anchor / PublicKey） =====
            // ===== 新版 publicKey 工具：优先用 anchor.web3.PublicKey，失败再自己实现 =====
      const _B58_ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
      const _B58_MAP = {};
      for (let i = 0; i < _B58_ALPHABET.length; i++) {
        _B58_MAP[_B58_ALPHABET[i]] = i;
      }

      function _base58ToBytes(str) {
        if (!str || typeof str !== 'string') return new Uint8Array([]);
        const bytes = [0]; // base256 big integer, little-endian
        for (let i = 0; i < str.length; i++) {
          const ch = str[i];
          const val = _B58_MAP[ch];
          if (val === undefined) throw new Error("Invalid base58 character");
          let carry = val;
          for (let j = 0; j < bytes.length; j++) {
            const x = bytes[j] * 58 + carry;
            bytes[j] = x & 0xff;
            carry = x >> 8;
          }
          while (carry > 0) {
            bytes.push(carry & 0xff);
            carry >>= 8;
          }
        }
        // 处理前导 '1' -> 前导 0
        for (let k = 0; k < str.length && str[k] === '1'; k++) {
          bytes.push(0);
        }
        return new Uint8Array(bytes.reverse());
      }

      function _makePubkeyObj(pubkeyBase58) {
        if (!pubkeyBase58) return null;

        // 1) 尝试直接用 DApp 里已经加载的 anchor.web3.PublicKey
        try {
          if (window.anchor && window.anchor.web3 && typeof window.anchor.web3.PublicKey === 'function') {
            const realPk = new window.anchor.web3.PublicKey(pubkeyBase58);
            console.log('[FlutterWallet] use real anchor.web3.PublicKey', realPk.toBase58());
            return realPk;  // 直接返回真实 PublicKey 实例（跟 Phantom 一样）
          }
        } catch (e) {
          console.warn('[FlutterWallet] create anchor.web3.PublicKey failed, fallback to custom object', e);
        }

        // 2) fallback：自己实现一个带 toBuffer 的“类 PublicKey”
        let bytes = null;
        try {
          bytes = _base58ToBytes(pubkeyBase58);
        } catch (e) {
          console.error("[FlutterWallet] base58 decode failed for pubkey", e);
        }

        return {
          _b58: pubkeyBase58,
          _bytes: bytes,
          toString: function() { return this._b58; },
          toBase58: function() { return this._b58; },
          toBytes: function() {
            return this._bytes ? this._bytes.slice() : null;
          },
          // 关键：Anchor 在 associatedAddress 里会调用 owner.toBuffer()
          toBuffer: function() {
            if (this._bytes == null) return null;
            if (typeof Buffer !== 'undefined') {
              return Buffer.from(this._bytes);
            }
            return Uint8Array.from(this._bytes);
          },
          equals: function(other) {
            try {
              let otherBytes;
              if (other && typeof other.toBytes === 'function') {
                otherBytes = other.toBytes();
              } else {
                otherBytes = _base58ToBytes(String(other));
              }
              const a = this._bytes;
              const b = otherBytes;
              if (!a || !b || a.length !== b.length) return false;
              for (let i = 0; i < a.length; i++) {
                if (a[i] !== b[i]) return false;
              }
              return true;
            } catch (_) {
              return false;
            }
          }
        };
      }

      let _lastCancelSignTxMessageBase64 = null;
      let _lastCancelSignTxAt = 0;  // ms 时间戳

      const provider = {
        isPhantom: true,

        get isConnected() { return _isConnected; },

        // ⚠ 这里是 Anchor 会用到的钱包公钥
        get publicKey() {
          return _phantomPublicKey;
        },

        _events: _events,
        _injectionStartMs: _injectionStartMs,
        _injectionEndMs: performance.now(),

        // connect: keep your current behavior (Flutter returns a base58 string)
        connect: function(opts) {
          return _callFlutter('solana_connect', opts).then((pubkeyBase58) => {
            if (pubkeyBase58) {
              _publicKeyBase58 = pubkeyBase58;          // 记录字符串
              _phantomPublicKey = _makePubkeyObj(pubkeyBase58);  // 创建“类 PublicKey 对象”
              _isConnected = true;

              // 事件里发对象，跟 Phantom 行为一致
              _emit('connect', _phantomPublicKey);

              // connect 返回 { publicKey: <PublicKey对象> }
              return { publicKey: _phantomPublicKey };
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
        // === REPLACE: signTransaction ===
        signTransaction: async function (tx) {
          console.log('[wallet] signTransaction called, tx =', tx);

          let messageBytes, setSignatureBack;

          try {
            // 1. clone 交易，避免 Anchor 内部状态坑
            let txToUse = tx;

            try {
              const AnchorWeb3 = (window.anchor && window.anchor.web3) ? window.anchor.web3 : null;
              if (AnchorWeb3 && typeof tx.serialize === 'function' && typeof AnchorWeb3.Transaction?.from === 'function') {
                console.log('[wallet] signTransaction clone tx via Transaction.from');
                const raw = tx.serialize({ requireAllSignatures: false });
                txToUse = AnchorWeb3.Transaction.from(raw);
              } else {
                console.log('[wallet] signTransaction: cannot clone, use original tx');
              }
            } catch (cloneErr) {
              console.warn('[wallet] signTransaction clone failed, use original tx', cloneErr);
              txToUse = tx;
            }

            // 2. legacy Transaction
            if (txToUse && typeof txToUse.serializeMessage === 'function') {
              console.log('[wallet] signTransaction treat as legacy Transaction (cloned)');

              messageBytes = txToUse.serializeMessage();

              setSignatureBack = (sigBytes, _pubkeyBase58) => {
                if (txToUse.signatures && txToUse.signatures.length > 0 && txToUse.signatures[0]) {
                  txToUse.signatures[0].signature = Uint8Array.from(sigBytes);
                } else if (typeof txToUse.addSignature === 'function') {
                  const feePayer = txToUse.feePayer || (txToUse.signatures && txToUse.signatures[0] && txToUse.signatures[0].publicKey);
                  if (!feePayer) throw new Error('cannot find feePayer to set signature');
                  const toBuf = (arr) => (typeof Buffer !== 'undefined' ? Buffer.from(arr) : new Uint8Array(arr));
                  txToUse.addSignature(feePayer, toBuf(sigBytes));
                } else {
                  throw new Error('cannot set legacy signature back');
                }

                try {
                  if (tx && tx !== txToUse) {
                    tx.signatures = txToUse.signatures;
                  }
                } catch (e) {
                  console.warn('[wallet] sync signatures back to original tx failed', e);
                }
              };
            }

            // 3. v0 VersionedTransaction
            else if (txToUse && txToUse.message && typeof txToUse.message.serialize === 'function' && typeof txToUse.serialize === 'function') {
              console.log('[wallet] signTransaction treat as v0 VersionedTransaction (cloned)');
              messageBytes = txToUse.message.serialize();

              setSignatureBack = (sigBytes, _pubkeyBase58) => {
                txToUse.signatures = txToUse.signatures || [];
                txToUse.signatures[0] = Uint8Array.from(sigBytes);

                try {
                  if (tx && tx !== txToUse) {
                    tx.signatures = txToUse.signatures;
                  }
                } catch (e) {
                  console.warn('[wallet] sync v0 signatures back to original tx failed', e);
                }
              };
            }

            // 4. 都不是，直接抛错
            else {
              console.error('[wallet] signTransaction unsupported tx object, keys =', Object.keys(txToUse || {}));
              throw { code: 4000, message: 'Unsupported transaction object in signTransaction' };
            }

          } catch (e) {
            console.error('[wallet] signTransaction serialize_failed detail =', e, e?.stack);
            throw { code: 4000, message: 'serialize_failed' };
          }

          try {
            const base64Msg = btoa(String.fromCharCode(...messageBytes));
            console.log('[wallet] signTransaction messageBase64 length =', base64Msg.length);

            // ⭐ 关键：防止“刚取消就立刻又弹一次”的情况
            const now = Date.now();
            if (
              _lastCancelSignTxMessageBase64 === base64Msg &&
              now - _lastCancelSignTxAt < 3000  // 3 秒内重复同一条 message
            ) {
              console.log('[wallet] signTransaction: suppress repeated popup after user rejection');
              throw { code: 4001, message: 'User rejected the request.' };
            }

            const res = await _callFlutter('solana_signTransaction', {
              messageBase64: base64Msg,
            });

            console.log('[wallet] signTransaction got res from Flutter =', res);

            // 1. Flutter 返回 { code: xxx }（包括用户取消）
            if (res && typeof res === 'object' && 'code' in res && !('signature' in res)) {
              if (res.code === 4001) {
                _lastCancelSignTxMessageBase64 = base64Msg;
                _lastCancelSignTxAt = Date.now();
              }
              throw res;
            }

            // 2. 其它异常（没有 signature）
            if (!res || !res.signature || !res.publicKey) {
              console.error('[wallet] signTransaction_failed, res =', res);
              throw { code: 4000, message: 'signTransaction_failed' };
            }

            // 3. 正常签名
            setSignatureBack(res.signature, res.publicKey);

            // 成功了就清掉取消记录
            _lastCancelSignTxMessageBase64 = null;
            _lastCancelSignTxAt = 0;

            console.log('[wallet] signTransaction done, tx (original) =', tx);
            return tx;
          } catch (e) {
            console.error('[wallet] signTransaction error when calling Flutter =', e);
            throw e;
          }
        },



        // === REPLACE: signAllTransactions ===
        signAllTransactions: async function (txs) {
          const out = [];
          for (const tx of txs || []) {
            out.push(await this.signTransaction(tx));
          }
          return out;
        },


        signAndSendTransaction: async function (tx, opts) {
          // 1) 先走我们自己实现的 signTransaction
          const signedTx = await this.signTransaction(tx);  // 会触发 Flutter 的 solana_signTransaction + 弹窗

          // 2) 序列化“已签名交易” → base64
          let signedBytes;
          if (signedTx && typeof signedTx.serialize === 'function') {
            signedBytes = signedTx.serialize(); // Uint8Array
          } else if (tx && typeof tx.serialize === 'function') {
            // 保险起见：有些实现 signTransaction 直接改原 tx，返回的还是旧引用
            signedBytes = tx.serialize();
          } else {
            throw new Error('serialize signed tx failed');
          }

          const signedTxBase64 = btoa(String.fromCharCode(...signedBytes));

          // 3) 交给 Flutter 的 solana_sendTransaction 去广播
          const res = await _callFlutter('solana_sendTransaction', {
            signedTxBase64,
            opts: opts || {}
          });

          // 4) 为了和 Phantom 行为对齐：返回 { signature }
          if (res && typeof res === 'object' && 'signature' in res) {
            return { signature: res.signature };
          }
          // 兜底：DApp 直接拿字符串也能用
          if (typeof res === 'string') {
            return { signature: res };
          }
          return res;
        },

        signAndSendAllTransactions: function(txs, opts) {
          return _callFlutter('solana_signAndSendAllTransactions', { txs: txs, opts: opts }).then((res) => res);
        },

        sendTransaction: async function(tx, opts) {
          // 1) 拿 message
          let messageBytes;
          if (tx && tx.message && typeof tx.message.serialize === 'function') {
            // v0
            messageBytes = tx.message.serialize();
          } else if (tx && typeof tx.serializeMessage === 'function') {
            // legacy
            messageBytes = tx.serializeMessage();
          } else {
            throw new Error('Unsupported tx object');
          }

          // 2) 让 Flutter 只签 message
          const { signature, publicKey } = await _callFlutter('solana_signTransaction', {
            messageBase64: btoa(String.fromCharCode(...messageBytes))
          });
          if (!signature) throw new Error('sign failed');

          // 3) 把签名写回 tx
          if (tx && tx.message && typeof tx.message.serialize === 'function') {
            // v0：首签
            tx.signatures = tx.signatures || [];
            tx.signatures[0] = Uint8Array.from(signature);
          } else if (typeof tx.serializeMessage === 'function') {
            if (tx.signatures && tx.signatures[0]) {
              tx.signatures[0].signature = Uint8Array.from(signature);
            } else if (typeof tx.addSignature === 'function') {
              const toBuf = (arr)=> (typeof Buffer!=='undefined'? Buffer.from(arr) : new Uint8Array(arr));
              tx.addSignature(tx.feePayer, toBuf(signature));
            }
          }

          // 4) 序列化“已签名交易”→ base64
          let signedBytes;
          if (tx.serialize) {
            signedBytes = tx.serialize(); // v0/legacy 都有
          } else {
            throw new Error('serialize signed tx failed');
          }
          const signedTxBase64 = btoa(String.fromCharCode(...signedBytes));

          // 5) 让 Flutter 广播（RPC sendTransaction）
          const res = await _callFlutter('solana_sendTransaction', {
            signedTxBase64,
            opts: opts || {}
          });
          return res; // 期望 { signature: '<txid base58>' }
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


      (function waitAndPatchAnchorForFlutterWallet() {
        function tryPatch() {
          try {
            const anchorGlobal = window.anchor;
            if (!anchorGlobal || !anchorGlobal.AnchorProvider) {
              // 还没加载到 anchor，继续等
              // console.log('[FlutterWallet] wait patch: no window.anchor.AnchorProvider yet');
              return false;
            }

            const AP = anchorGlobal.AnchorProvider;
            if (AP.__flutterPatched) {
              return true; // 已经打过补丁了
            }

            const oldSendAndConfirm = AP.prototype.sendAndConfirm;

            AP.prototype.sendAndConfirm = async function (tx, signers, opts) {
              const wallet = this.wallet || window.solana;

              // 如果是我们这个 Phantom 风格的钱包，**只走 signAndSendTransaction 这一条路**
              if (wallet && wallet.isPhantom && typeof wallet.signAndSendTransaction === 'function') {
                try {
                  // （可选）补 feePayer / recentBlockhash，跟你原来的一样
                  try {
                    if (tx && typeof tx.serialize === 'function' && !tx.recentBlockhash) {
                      const latest = await this.connection.getLatestBlockhash(
                        (opts && opts.preflightCommitment) ||
                        (this.opts && this.opts.preflightCommitment) ||
                        'confirmed'
                      );
                      tx.recentBlockhash = latest.blockhash;
                    }
                    if (tx && typeof tx.serialize === 'function' && !tx.feePayer && wallet.publicKey) {
                      tx.feePayer = wallet.publicKey;
                    }
                  } catch (e) {
                    console.warn('[FlutterWallet] prepare tx in patched sendAndConfirm failed', e);
                  }

                  const res = await wallet.signAndSendTransaction(tx, opts || this.opts || {});
                  return typeof res === 'string' ? res : res.signature;
                } catch (e) {
                  console.error('[FlutterWallet] patched sendAndConfirm error from wallet.signAndSendTransaction', e);

                  // ⭐⭐ 关键点：用户取消 / 没有钱包这类错误，直接往上抛，**不要再 fallback **
                  if (e && typeof e === 'object' && 'code' in e && (e.code === 4001 || e.code === 4100)) {
                    throw e;
                  }

                  // 其它错误（比如你想保留老逻辑兜底，可以选择 fallback，或者也直接抛）
                  // 建议一开始先直接抛，方便调试：
                  throw e;

                  // 如果你以后想对网络问题兜底，可以在这里再按情况调用 oldSendAndConfirm
                  // return await oldSendAndConfirm.call(this, tx, signers, opts);
                }
              }

              // 只有在不是我们这种 Phantom 风格钱包时，才走 Anchor 原来的 sendAndConfirm
              return await oldSendAndConfirm.call(this, tx, signers, opts);
            };

            AP.__flutterPatched = true;
            console.log('[FlutterWallet] AnchorProvider.sendAndConfirm patched for Flutter wallet');
            return true;
          } catch (e) {
            console.error('[FlutterWallet] waitAndPatchAnchorForFlutterWallet failed', e);
            return true; // 发生异常就别重复试了
          }
        }

        // 先尝试一次
        if (tryPatch()) return;

        // anchor 可能还没挂到 window 上，隔 200ms 试一次，最多 50 次（10 秒）
        let count = 0;
        const timer = setInterval(() => {
          if (tryPatch() || ++count > 50) {
            clearInterval(timer);
          }
        }, 200);
      })();


      // allow Flutter to inject events into the page (connect/disconnect/other)
      window._flutter_injectEvent = function(event, data) {
        if (event === 'connect') {
          // data 是 base58 字符串
          _publicKeyBase58 = data;
          _phantomPublicKey = _makePubkeyObj(data);
          _isConnected = true;
          _emit('connect', _phantomPublicKey);
        } else if (event === 'disconnect') {
          _publicKeyBase58 = null;
          _phantomPublicKey = null;
          _isConnected = false;
          _emit('disconnect');
        } else {
          _emit(event, data);
        }
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
                        } catch (e) {
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

                // signAndSendTransaction
                controller.addJavaScriptHandler(
                  handlerName: 'solana_signAndSendTransaction',
                  callback: (args) async {
                    debugPrint('solana_signAndSendTransaction prints');
                    try {
                      // 1) 会话/钱包就绪
                      if (_wallet == null || _currentPubkey == null || _hdKeypair == null) {
                        await _ensureWalletReady();
                      }
                      if (_hdKeypair == null || _currentPubkey == null) {
                        return _err(4100, 'no_wallet_connected');
                      }

                      // 2) 解析 payload
                      final body = (args.isNotEmpty ? args[0] : {}) as Map;
                      final messageBase64 = body['messageBase64'] as String?;
                      if (messageBase64 == null || messageBase64.isEmpty) {
                        return _err(4000, 'missing_message_base64');
                      }
                      final msg = base64Decode(messageBase64);

                      // 3) 交易预览（这里先最小化；后续可解析更多信息展示）
                      final approved = await _solanaConnectShowModalBottomSheetWidget(
                        _wallet!,
                        _currentNetwork ?? {'id': 'Solana', 'path': 'assets/images/solana.png'},
                        'DApp 请求发送交易',
                      );
                      if (approved != true) return _err(4001, 'User rejected the request.');

                      // 4) 签名 message（Ed25519）
                      final sigBytes = await _hdKeypair!.sign(msg); // Uint8List(64)

                      // 5) 返回给 DApp：它来把签名塞回交易并广播
                      return {
                        'publicKey': _currentPubkey, // base58
                        'signature': sigBytes, // List<int>
                      };
                    } catch (e, st) {
                      debugPrint('signAndSendTransaction error: $e\n$st');
                      return _err(4000, 'internal_error');
                    }
                  },
                );

                // signTransaction
                controller.addJavaScriptHandler(
                  handlerName: 'solana_signTransaction',
                  callback: (args) async {
                    debugPrint('===> solana_signTransaction called, args: $args');

                    try {
                      // 1) 确保钱包 & keypair 准备好（支持助记词 / 私钥导入）
                      if (_wallet == null || _currentPubkey == null || _hdKeypair == null) {
                        await _ensureWalletReady();
                      }
                      debugPrint('after _ensureWalletReady: pubkey=$_currentPubkey, hdKeypair null? ${_hdKeypair == null}');

                      if (_hdKeypair == null || _currentPubkey == null) {
                        return {'code': 4100, 'message': 'no_wallet_connected_or_no_keypair'};
                      }

                      // 2) 解析 message
                      final body = (args.isNotEmpty ? args[0] : {}) as Map;
                      final messageBase64 = body['messageBase64'] as String?;
                      if (messageBase64 == null || messageBase64.isEmpty) {
                        return {'code': 4000, 'message': 'missing_message_base64'};
                      }
                      final msg = base64Decode(messageBase64);

                      // 3) 拉起「确认转账」弹窗
                      if (!mounted) {
                        return {'code': 4000, 'message': 'page_not_mounted'};
                      }

                      final ok = await _solanaConnectShowModalBottomSheetWidget(
                        _wallet!,
                        _currentNetwork ?? {'id': 'Solana', 'path': 'assets/images/solana.png'},
                        'DApp 请求发送交易', // 这里后面可以改成解析好的 ProgramId/金额文案
                      );
                      if (ok != true) {
                        return {'code': 4001, 'message': 'User rejected the request.'};
                      }

                      // 4) 校验当前 address 和派生地址一致（可选安全检查）
                      if (_hdKeypair!.address != _currentPubkey) {
                        return {'code': 4000, 'message': 'public_key_mismatch'};
                      }

                      // 5) 真正签名
                      final sig = await _hdKeypair!.sign(msg); // Uint8List(64)

                      // 6) 把签名返回给 JS（签名必须是 List<int>）
                      return {
                        'publicKey': _currentPubkey,
                        'signature': sig, // Uint8List 在桥上会按 List<int> 传过去
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
