import 'package:feature_wallet/src/address_book_and_my_wallet.dart';
import 'package:feature_wallet/src/camera_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_setting/state/app_provider.dart';
import 'package:shared_ui/widget/base_page.dart';
import 'package:shared_utils/hive_storage.dart';
import 'package:shared_utils/solana_servise.dart';
import 'package:shared_utils/tokenIcon.dart';
import 'package:shared_utils/constants/app_colors.dart';
import 'package:shared_utils/hive_boxes.dart';
import 'package:feature_wallet/hive/Wallet.dart';
import 'package:feature_wallet/hive/transaction_record.dart';
import 'package:feature_wallet/i18n/strings.g.dart';
import 'package:shared_utils/biometric_service.dart';
import 'package:shared_utils/fetch_token_balances.dart';
import 'package:shared_ui/widget/custom_appbar.dart';
import 'package:shared_ui/widget/custom_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';

/*
 * 转账
 */
class TransferPage extends ConsumerStatefulWidget {
  final String currency;
  final String tokenAddress;
  final String network;
  final String image;
  const TransferPage({super.key, required this.currency, required this.tokenAddress, required this.network, required this.image});

  @override
  ConsumerState<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends ConsumerState<TransferPage> with BasePage<TransferPage>, AutomaticKeepAliveClientMixin {
  String? _diyWalletName;
  String? _transferAmount;
  String? _gasFees;
  final TextEditingController _textControllerDiyWalletName = TextEditingController();
  final TextEditingController _textControllertransferAmount = TextEditingController();
  final TextEditingController _textControllerGasFees = TextEditingController();
  String? _currentWalletMnemonic;
  String? _currentWalletAdderss;
  String? _currentWalletprivateKey;
  double? balance;
  bool _isSubmitting = false;
  String _txListKey(String address) => 'tx_$address';

  @override
  void initState() {
    super.initState();
    _initWalletData();
  }

  Future<void> _initWalletData() async {
    await _getCurrentSelectedWalletInformation();
    final tokenBalance = await fetchTokenBalance(ownerAddress: _currentWalletAdderss!, mintAddress: widget.tokenAddress);
    if (mounted) setState(() => balance = double.parse(tokenBalance));
  }

  // 获取当前选中的钱包信息
  Future<void> _getCurrentSelectedWalletInformation() async {
    final wallet = await HiveStorage().getObject<Wallet>('currentSelectWallet', boxName: boxWallet);
    final mnemonic = await HiveStorage().getValue<String>('currentSelectWallet_mnemonic');

    _currentWalletMnemonic = wallet?.mnemonic?.join(" ") ?? mnemonic;
    _currentWalletAdderss = wallet?.address;
    _currentWalletprivateKey = wallet?.privateKey;

    debugPrint('钱包地址: ${wallet?.address}');
    debugPrint('助记词: ${wallet?.mnemonic?.join(" ")} -- $mnemonic');
    debugPrint('私钥: ${wallet?.privateKey}');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final biometricState = ref.watch(getBioMetricsProvide);

    return Scaffold(
      appBar: CustomAppBar(title: ''),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.transfer_receive_payment.transfer,
                          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 10.h),
                        Text(t.transfer_receive_payment.selectCoinNetwork, style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
                        SizedBox(height: 10.h),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            minimumSize: Size(double.infinity, 45.h),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(.3), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                          ),
                          onPressed: () {},
                          child: Row(
                            children: [
                              ClipRRect(borderRadius: BorderRadius.circular(50), child: TokenIcon(widget.image, size: 20)),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  widget.currency,
                                  style: TextStyle(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                '${t.transfer_receive_payment.transferNetwork} ${widget.network}',
                                style: TextStyle(fontSize: 13.sp, color: AppColors.color_757F7F),
                              ),
                              SizedBox(width: 8.w),
                              Icon(Icons.arrow_forward_ios, size: 12.w, color: Colors.grey[400]),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(child: Text(t.transfer_receive_payment.recipientAddress)),
                            GestureDetector(
                              onTap: () {
                                Get.to(Addressbookandmywallet(), transition: Transition.rightToLeft);
                              },
                              child: Icon(Icons.assignment_rounded, color: Theme.of(context).colorScheme.onBackground),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Divider(height: 8.h, color: AppColors.color_757F7F),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final scanReslut = await Get.to(Camerascan(), transition: Transition.rightToLeft);
                                if (scanReslut != null) {
                                  setState(() {
                                    _diyWalletName = scanReslut;
                                    _textControllerDiyWalletName.text = scanReslut;
                                  });
                                }
                              },
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
                                child: Image.asset('assets/images/ic_home_scan.png', width: 16.w, height: 16.w),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        CustomTextField(
                          hintText: t.transfer_receive_payment.enterRecipientAddress,
                          controller: _textControllerDiyWalletName,
                          onChanged: (text) {
                            setState(() {
                              _diyWalletName = text;
                            });
                          },
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(child: Text(t.transfer_receive_payment.transferAmount)),
                            Text(
                              '${t.transfer_receive_payment.available}: ${balance ?? 0.0} ${widget.currency}',
                              style: TextStyle(fontSize: 13.sp, color: AppColors.color_757F7F),
                            ),
                            SizedBox(width: 5.w),
                            ClipRRect(borderRadius: BorderRadius.circular(50), child: TokenIcon(widget.image, size: 20)),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        CustomTextField(
                          hintText: "0.00",
                          controller: _textControllertransferAmount,
                          onChanged: (text) {
                            setState(() {
                              _transferAmount = text;
                            });
                          },
                        ),

                        SizedBox(height: 16.h),
                        Text(t.transfer_receive_payment.gasFee),
                        SizedBox(height: 6.h),
                        CustomTextField(
                          hintText: "<¥0.01",
                          controller: _textControllerGasFees,
                          onChanged: (text) {
                            setState(() {
                              _gasFees = text;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(15.w),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.color_286713,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 42.h),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    textStyle: TextStyle(fontSize: 18.sp),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27.5.r)),
                  ),
                  onPressed: () => _onTransferPressed(widget.currency, biometricState),
                  child: Text(t.transfer_receive_payment.confirm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // toast
  void _showSnack(String msg) {
    if (!mounted) return;
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Theme.of(context).colorScheme.onPrimary,
      fontSize: 16.0,
    );
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoading() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop(); // 关闭加载弹窗
    }
  }

  // 执行转账逻辑
  Future<void> _onTransferPressed(String currency, bool biometricState) async {
    if (_isSubmitting) return; // 防连点

    // 取输入框里的值
    _transferAmount = _textControllertransferAmount.text.trim();
    _diyWalletName = _textControllerDiyWalletName.text.trim();

    if (_diyWalletName == null || _diyWalletName!.isEmpty) {
      _showSnack(t.transfer_receive_payment.enterWalletAddress);
      return;
    }
    if (!isValidSolanaAddress("$_diyWalletName")) {
      _showSnack(t.transfer_receive_payment.invalidWalletAddress);
      return;
    }
    if (_transferAmount == null || _transferAmount!.isEmpty) {
      _showSnack(t.transfer_receive_payment.enterAmount);
      return;
    }
    final amount = double.tryParse(_transferAmount!);
    if (amount == null) {
      _showSnack(t.transfer_receive_payment.invalidNumber);
      return;
    }
    if (balance == null) {
      _showSnack(t.transfer_receive_payment.balanceFetchFailed);
      return;
    }
    if (amount > balance!) {
      _showSnack(t.transfer_receive_payment.insufficientBalance);
      return;
    }

    _isSubmitting = true;
    _showLoading();

    try {
      String tx;

      if (biometricState) {
        final result = await BiometricService.instance.authenticate(reason: t.wallet.verifyIdentity);

        if (result != true) {
          Fluttertoast.showToast(
            msg: t.wallet.identityVerifyFailed,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Theme.of(context).colorScheme.primary,
            textColor: Theme.of(context).colorScheme.onPrimary,
            fontSize: 16.0,
          );
          return;
        }
      }

      if (currency == 'SOL') {
        tx = await sendSol(receiverAddress: "$_diyWalletName", mnemonic: '$_currentWalletMnemonic', amount: double.parse("$_transferAmount"));
        await saveTransaction(tx, _transferAmount!);
        debugPrint('转账SOL结果: $tx');
      } else {
        tx = await sendSPLToken(
          mnemonic: "$_currentWalletMnemonic",
          receiverAddress: "$_diyWalletName",
          tokenMintAddress: widget.tokenAddress,
          amount: double.parse("$_transferAmount"),
        );
        await saveTransaction(tx, _transferAmount!);
        debugPrint('派生币转账返回结果: $tx');
      }

      if (!mounted) return;
      setState(() {
        _diyWalletName = "";
        _transferAmount = "";
        _textControllerDiyWalletName.text = "";
        _textControllertransferAmount.text = "";
      });
      _showSnack(t.transfer_receive_payment.transferSubmitted);
    } catch (e) {
      debugPrint('转账错误: $e');
      if (mounted) {
        _showSnack(t.transfer_receive_payment.unknown_error_please_try_again_later);
      }
    } finally {
      _hideLoading();
      _isSubmitting = false;
    }
  }

  Future<void> saveTransaction(String txHash, String amount) async {
    final fromAddr = _currentWalletAdderss ?? '';
    final toAddr = _diyWalletName ?? '';

    final record = TransactionRecord(
      txHash: txHash,
      from: fromAddr,
      to: toAddr,
      amount: amount,
      tokenSymbol: widget.currency,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      status: 'success',
    );

    final recordMap = record.toJson(); //  存 Map，不是对象

    for (final addr in [fromAddr, toAddr]) {
      if (addr.isEmpty) continue;

      final key = _txListKey(addr);
      // 强类型getList<TransactionRecord>报错，先使用弱类型getList<Map>存储， 后续迁移只需要改为强类型即可
      final list = await HiveStorage().getList<Map>(key, boxName: boxTx) ?? <Map>[];

      final exists = list.any((m) => m['txHash'] == record.txHash);
      if (!exists) list.insert(0, recordMap);

      await HiveStorage().putList<Map>(key, list, boxName: boxTx);

      final probe = await HiveStorage().getList<Map>(key, boxName: boxTx);
      debugPrint('after put: col_$key -> len=${probe?.length}');
    }
  }

  @override
  bool get wantKeepAlive => true;
}
