final String kSolanaProviderJs = r'''
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

            
      // 新版 publicKey 工具：优先用 anchor.web3.PublicKey, 失败再自己实现
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

        // 尝试直接用 DApp 里已经加载的 anchor.web3.PublicKey
        try {
          if (window.anchor && window.anchor.web3 && typeof window.anchor.web3.PublicKey === 'function') {
            const realPk = new window.anchor.web3.PublicKey(pubkeyBase58);
            console.log('[FlutterWallet] use real anchor.web3.PublicKey', realPk.toBase58());
            return realPk;  // 直接返回真实 PublicKey 实例（跟 Phantom 一样）
          }
        } catch (e) {
          console.warn('[FlutterWallet] create anchor.web3.PublicKey failed, fallback to custom object', e);
        }

        // fallback：自己实现一个带 toBuffer 的"类 PublicKey"
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
          // 关键: Anchor 在 associatedAddress 里会调用 owner.toBuffer()
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

      async function _buildTxPreview(tx) {
        try {
          const anchorGlobal = window.anchor;
          const provider = anchorGlobal?.getProvider?.();
          const conn = provider?.connection || null;

          if (!tx || !conn) {
            console.log('[FlutterWallet] _buildTxPreview: no tx or no connection');
            return {};
          }

          let programId = null;
          let feePayer = null;
          let recentBlockhash = null;
          let instructionCount = 0;
          let accounts = [];
          let feeLamports = null;
          let walletBalanceLamports = null;

          // legacy Transaction
          if (typeof tx.serializeMessage === 'function') {
            const ix0 = tx.instructions && tx.instructions[0];

            programId = ix0?.programId?.toBase58?.() || null;
            feePayer = tx.feePayer?.toBase58?.() || null;
            recentBlockhash = tx.recentBlockhash || null;
            instructionCount = (tx.instructions || []).length;

            if (ix0 && Array.isArray(ix0.keys)) {
              accounts = ix0.keys.map((k) => ({
                pubkey: k.pubkey?.toBase58?.() || String(k.pubkey),
                isSigner: !!k.isSigner,
                isWritable: !!k.isWritable,
              }));
            }

            // 估算 fee
            try {
              if (conn.getFeeForMessage && typeof tx.compileMessage === 'function') {
                const message = tx.compileMessage();
                const feeRes = await conn.getFeeForMessage(message);
                feeLamports = feeRes?.value ?? null;
              }
            } catch (e) {
              console.warn('[FlutterWallet] getFeeForMessage (legacy) failed', e);
            }
          }

          // v0 VersionedTransaction
          else if (tx.message && typeof tx.message.serialize === 'function') {
            instructionCount = (tx.message.compiledInstructions || []).length;

            try {
              if (conn.getFeeForMessage) {
                const feeRes = await conn.getFeeForMessage(tx.message);
                feeLamports = feeRes?.value ?? null;
              }
            } catch (e) {
              console.warn('[FlutterWallet] getFeeForMessage (v0) failed', e);
            }

            // 解析 feePayer(通常是 accountKeys[0])
            try {
              const anchorWeb3 = anchorGlobal?.web3;
              if (anchorWeb3 && tx.message.accountKeys && tx.message.accountKeys[0]) {
                const pk0 = new anchorWeb3.PublicKey(tx.message.accountKeys[0]);
                feePayer = pk0.toBase58();
              }
            } catch (e) {
              console.warn('[FlutterWallet] parse v0 feePayer failed', e);
            }
          }

          // 查 feePayer 余额(SOL)
          try {
            const anchorWeb3 = anchorGlobal?.web3;
            if (conn && anchorWeb3 && feePayer) {
              const feePayerPk = new anchorWeb3.PublicKey(feePayer);
              const bal = await conn.getBalance(feePayerPk);
              walletBalanceLamports = bal ?? null;
            }
          } catch (e) {
            console.warn('[FlutterWallet] getBalance for feePayer failed', e);
          }

          const preview = {
            programId,
            feePayer,
            recentBlockhash,
            instructionCount,
            accounts,
            feeLamports,
            walletBalanceLamports,
          };

          console.log('[FlutterWallet] tx preview built =', preview);
          return preview;
        } catch (e) {
          console.warn('[FlutterWallet] _buildTxPreview global error', e);
          return {};
        }
      }

      let _lastCancelSignTxMessageBase64 = null;
      let _lastCancelSignTxAt = 0;  // ms 时间戳

      const provider = {
        isPhantom: true,

        get isConnected() { return _isConnected; },

        // 这里是 Anchor 会用到的钱包公钥
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
        // REPLACE: signTransaction
        signTransaction: async function (tx) {
          console.log('[wallet] signTransaction called, tx =', tx);

          let messageBytes, setSignatureBack, txToUse;

          try {
            // 1. clone 交易，避免 Anchor 内部状态坑
            txToUse = tx;

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

            // 构建预览
            let preview = {};
            try {
              preview = await _buildTxPreview(txToUse);
            } catch (e) {
              console.warn('[wallet] _buildTxPreview failed', e);
            }

            // 防止"刚取消就立刻又弹一次"
            const now = Date.now();
            if (
              _lastCancelSignTxMessageBase64 === base64Msg &&
              now - _lastCancelSignTxAt < 3000
            ) {
              console.log('[wallet] signTransaction: suppress repeated popup after user rejection');
              throw { code: 4001, message: 'User rejected the request.' };
            }

            // 把 preview 一起发给 Flutter
            const res = await _callFlutter('solana_signTransaction', {
              messageBase64: base64Msg,
              preview,
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

            // 2. 其它异常(没有 signature)
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


        signAndSendTransaction: async function (tx, opts) {
          // 1 先走我们自己实现的 signTransaction
          const signedTx = await this.signTransaction(tx);  // 会触发 Flutter 的 solana_signTransaction + 弹窗

          // 2 序列化“已签名交易” → base64
          let signedBytes;
          if (signedTx && typeof signedTx.serialize === 'function') {
            signedBytes = signedTx.serialize(); // Uint8Array
          } else if (tx && typeof tx.serialize === 'function') {
            // 保险起见：有些实现 signTransaction 直接改原 tx, 返回的还是旧引用
            signedBytes = tx.serialize();
          } else {
            throw new Error('serialize signed tx failed');
          }

          const signedTxBase64 = btoa(String.fromCharCode(...signedBytes));

          // 3 交给 Flutter 的 solana_sendTransaction 去广播
          const res = await _callFlutter('solana_sendTransaction', {
            signedTxBase64,
            opts: opts || {}
          });

          // 4 为了和 Phantom 行为对齐：返回 { signature }
          if (res && typeof res === 'object' && 'signature' in res) {
            return { signature: res.signature };
          }
          // 兜底: DApp 直接拿字符串也能用
          if (typeof res === 'string') {
            return { signature: res };
          }
          return res;
        },

        signAndSendAllTransactions: function(txs, opts) {
          return _callFlutter('solana_signAndSendAllTransactions', { txs: txs, opts: opts }).then((res) => res);
        },

        sendTransaction: async function(tx, opts) {
          // 1 拿 message
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

          // 2 让 Flutter 只签 message
          const { signature, publicKey } = await _callFlutter('solana_signTransaction', {
            messageBase64: btoa(String.fromCharCode(...messageBytes))
          });
          if (!signature) throw new Error('sign failed');

          // 3 把签名写回 tx
          if (tx && tx.message && typeof tx.message.serialize === 'function') {
            // v0: 首签
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

          // 4 序列化“已签名交易”→ base64
          let signedBytes;
          if (tx.serialize) {
            signedBytes = tx.serialize(); // v0/legacy 都有
          } else {
            throw new Error('serialize signed tx failed');
          }
          const signedTxBase64 = btoa(String.fromCharCode(...signedBytes));

          // 5 让 Flutter 广播(RPC sendTransaction)
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
              // 还没加载到 anchor, 继续等
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

              // 如果是我们这个 Phantom 风格的钱包，只走 signAndSendTransaction 这一条路
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

                  // 关键点：用户取消 / 没有钱包这类错误，直接往上抛，**不要再 fallback **
                  if (e && typeof e === 'object' && 'code' in e && (e.code === 4001 || e.code === 4100)) {
                    throw e;
                  }

                  // 其它错误(比如你想保留老逻辑兜底，可以选择 fallback, 或者也直接抛)
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

        // anchor 还没挂到 window 上，隔 200ms 试一次，最多 50 次(10 秒)
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
