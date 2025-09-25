import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:solana_wallet/solana_package.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/dao/HiveStorage.dart';
import 'package:untitled1/entity/Wallet.dart';
import 'package:untitled1/pages/AddressbookAndMywallet.dart';
import 'package:untitled1/pages/CameraScan.dart';
import 'package:untitled1/pages/view/CustomAppBar.dart';
import 'package:untitled1/pages/view/CustomTextField.dart';
import 'package:untitled1/servise/solana_servise.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:untitled1/theme/app_textStyle.dart';

import '../../base/base_page.dart';

/*
 * 转账
 */
class TransferPage extends StatefulWidget {
  final String currency;
  final String tokenAddress;
  final String network;
  const TransferPage({super.key, required this.currency, required this.tokenAddress, required this.network});

  @override
  State<StatefulWidget> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> with BasePage<TransferPage>, AutomaticKeepAliveClientMixin {
  String? _diyWalletName;
  String? _transferAmount;
  String? _gasFees;
  final TextEditingController _textControllerDiyWalletName = TextEditingController();
  final TextEditingController _textControllertransferAmount = TextEditingController();
  final TextEditingController _textControllerGasFees = TextEditingController();
  var solana = Solana();
  String? _currentWalletMnemonic;
  String? _currentWalletAdderss;
  double? balance;

  @override
  void initState() {
    super.initState();
    _getCurrentSelectedWalletInformation();
    _getBalance();
  }

  // 获取当前选中的钱包信息
  void _getCurrentSelectedWalletInformation() {
    final wallet = HiveStorage().getObject<Wallet>('currentSelectWallet');
    _currentWalletMnemonic = wallet?.mnemonic?.join(" ");
    _currentWalletAdderss = wallet?.address;
    debugPrint(wallet?.address);
  }

  // 获取余额
  void _getBalance() async {
    if (widget.currency == "SOL") {
      getSolBalance(rpcUrl: "https://api.devnet.solana.com", ownerAddress: _currentWalletAdderss!)
          .then((e) {
            setState(() {
              balance = e;
            });
          })
          .catchError((e) {
            debugPrint("获取余额失败");
          });
    } else {
      getSplTokenBalanceRpc(rpcUrl: "https://api.devnet.solana.com", ownerAddress: _currentWalletAdderss!, mintAddress: widget.tokenAddress)
          .then((e) {
            setState(() {
              balance = e;
            });
          })
          .catchError((e) {
            debugPrint("获取余额失败$e");
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
                          '转账',
                          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 10.h),
                        Text('选择币种和网络', style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
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
                              Image.asset('assets/images/ic_home_bit_coin.png', width: 20.5.w, height: 20.5.w),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  widget.currency,
                                  style: TextStyle(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                '转账网络 ${widget.network}',
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
                            Expanded(child: Text('收款地址')),
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
                          hintText: "请输入收款地址",
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
                            Expanded(child: Text('转账数量')),
                            Text(
                              '可用: ${balance ?? 0.0} ${widget.currency}',
                              style: TextStyle(fontSize: 13.sp, color: AppColors.color_757F7F),
                            ),
                            SizedBox(width: 5.w),
                            Image.asset('assets/images/ic_home_bit_coin.png', width: 20.5.w, height: 20.5.w),
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
                        Text('Gas费'),
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
                  onPressed: () => _onTransferPressed(widget.currency),
                  child: Text('确认'),
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
      backgroundColor: Theme.of(context).colorScheme.background,
      textColor: Theme.of(context).colorScheme.onBackground,
      fontSize: 16.0,
    );
  }

  // 执行转账逻辑
  void _onTransferPressed(String currency) async {
    // 取输入框里的值
    _transferAmount = _textControllertransferAmount.text.trim();
    _diyWalletName = _textControllerDiyWalletName.text.trim();

    if (_diyWalletName == null || _diyWalletName!.isEmpty) {
      _showSnack("请输入钱包地址");
      return;
    }

    if (!isValidSolanaAddress("$_diyWalletName")) {
      _showSnack("钱包地址格式错误");
      return;
    }

    // 输入是否为空
    if (_transferAmount == null || _transferAmount!.isEmpty) {
      _showSnack('请输入数量');
      return;
    }

    // 转成 double
    final amount = double.tryParse(_transferAmount!);
    if (amount == null) {
      _showSnack('请输入有效的数字');
      return;
    }

    // balance 是否获取到
    if (balance == null) {
      _showSnack('余额获取失败，请稍后重试');
      return;
    }

    // 校验余额是否足够
    if (amount > balance!) {
      _showSnack('余额不够');
      return;
    }

    // 执行转账
    if (currency == 'SOL') {
      sendSol(receiverAddress: "6bPZLzFBnYNdZbAkCgkB47j5XyZmgfQaVkNECNZNCRL2", mnemonic: '$_currentWalletMnemonic', amount: 1)
          .then((e) {
            debugPrint('转账SOL结果: $e');
          })
          .catchError((e) {
            debugPrint("转账SOL错误: $e");
          });
    } else {
      debugPrint('tokenAddress: ${widget.tokenAddress}');
      sendSPLToken(
            mnemonic: "$_currentWalletMnemonic",
            receiverAddress: "6bPZLzFBnYNdZbAkCgkB47j5XyZmgfQaVkNECNZNCRL2",
            tokenMintAddress: widget.tokenAddress,
            amount: 1.23,
          )
          .then((e) {
            debugPrint('派生币转账返回结果: $e');
          })
          .catchError((e) {
            debugPrint('派生币转账捕获的错误: $e');
          });
    }
  }

  @override
  bool get wantKeepAlive => true;
}
