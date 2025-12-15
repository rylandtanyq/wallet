import 'dart:async';
import 'dart:math';
import 'package:feature_main/i18n/strings.g.dart';
import 'package:feature_main/src/trade/model/trade_swap_quote_model.dart';
import 'package:feature_main/src/trade/service/trade_provider.dart';
import 'package:feature_main/src/trade/utils/decimal_text_input_formatter.dart';
import 'package:feature_main/src/trade/model/swap_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'package:shared_ui/widget/wallet_icon.dart';

class TradeQuickExchangeFragments extends ConsumerStatefulWidget {
  const TradeQuickExchangeFragments({super.key});

  @override
  ConsumerState<TradeQuickExchangeFragments> createState() => _TradeQuickExchangeFragmentsState();
}

class _TradeQuickExchangeFragmentsState extends ConsumerState<TradeQuickExchangeFragments> {
  final TextEditingController _textEditingController = TextEditingController();

  SwapToken _sellToken = solToken;
  SwapToken _buyToken = usdtToken;

  Timer? _debounce;

  double? _buyAmount;
  double? _sellAmount = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textEditingController.dispose();
    super.dispose();
  }

  int _decimalsForMint(String mint) {
    // 优先用当前买卖 token 的精度
    if (mint == _sellToken.mint) return _sellToken.decimals;
    if (mint == _buyToken.mint) return _buyToken.decimals;

    // 常见几种，兜底一下
    if (mint == 'So11111111111111111111111111111111111111112') return 9; // wSOL
    if (mint == 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v') return 6; // USDC
    if (mint == 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB') return 6; // USDT

    return 6;
  }

  String _symbolForMint(String mint) {
    if (mint == _sellToken.mint) return _sellToken.symbol;
    if (mint == _buyToken.mint) return _buyToken.symbol;

    if (mint == 'So11111111111111111111111111111111111111112') return 'SOL';
    if (mint == 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v') return 'USDC';
    if (mint == 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB') return 'USDT';

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final tradeSwapQuoteData = ref.watch(tradeQuoteProvider);
    debugPrint('$tradeSwapQuoteData res ');

    return ListView(
      physics: NeverScrollableScrollPhysics(),
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 220,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: Theme.of(context).colorScheme.surface),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            t.trade.sell,
                            style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Icon(WalletIcon.wallet, size: 12.h, color: Theme.of(context).colorScheme.onSurface),
                              SizedBox(width: 4.w),
                              Text("${_sellToken.balance}", style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                              SizedBox(width: 4.w),
                              Icon(Icons.add_box_sharp, size: 16.h, color: Theme.of(context).colorScheme.primary),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              ClipRRect(borderRadius: BorderRadius.circular(50), child: Image.network(_sellToken.logo, width: 40, height: 40)),
                              SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_sellToken.name, style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                                  Text(_sellToken.symbol, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                                ],
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.onBackground),
                            ],
                          ),
                          SizedBox(
                            width: 130.w,
                            child: TextField(
                              controller: _textEditingController,
                              cursorColor: Theme.of(context).colorScheme.primary,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [DecimalTextInputFormatter(decimalRange: 9)],
                              textAlign: TextAlign.right,
                              style: AppTextStyles.headline3.copyWith(color: Theme.of(context).colorScheme.onBackground),
                              decoration: InputDecoration(
                                hintText: "0.00",
                                hintStyle: AppTextStyles.headline3.copyWith(color: Theme.of(context).colorScheme.onSurface),
                                hintTextDirection: TextDirection.rtl,
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                                contentPadding: EdgeInsets.only(right: 0),
                                border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(25.r)),
                              ),
                              onChanged: (e) {
                                if (_debounce?.isActive ?? false) _debounce?.cancel();

                                setState(() {
                                  if (e.isEmpty) {
                                    _sellAmount = 0;
                                  } else {
                                    _sellAmount = double.tryParse(e) ?? 0;
                                  }
                                });

                                _debounce = Timer(const Duration(milliseconds: 1000), () async {
                                  final int amountInt = (_sellAmount! * (pow(10, _sellToken.decimals))).round();
                                  ref.read(tradeQuoteProvider.notifier).fetchTradeQuoteData(_sellToken.mint, _buyToken.mint, amountInt);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            t.trade.buy,
                            style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Icon(WalletIcon.wallet, size: 12.h, color: Theme.of(context).colorScheme.onSurface),
                              SizedBox(width: 4.w),
                              Text("${_sellToken.balance}", style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                              SizedBox(width: 4.w),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              ClipRRect(borderRadius: BorderRadius.circular(50), child: Image.network(_buyToken.logo, width: 40, height: 40)),
                              SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_buyToken.name, style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                                  Text(_buyToken.symbol, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                                ],
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.onBackground),
                            ],
                          ),
                          Text(
                            tradeSwapQuoteData.maybeWhen(
                              data: (quote) {
                                final outInt = int.parse(quote.outAmount);
                                final outUi = outInt / pow(10, _buyToken.decimals);
                                return outUi.toStringAsFixed(6); // 买入数量
                              },
                              orElse: () {
                                return _buyToken.balance.toString();
                              },
                            ),
                            style: AppTextStyles.headline3.copyWith(color: Theme.of(context).colorScheme.onBackground),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                SizedBox(width: 12.w),
                Expanded(child: Divider(height: .5, color: Theme.of(context).colorScheme.onSurface.withOpacity(.2))),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      final oldSell = _sellToken;
                      _sellToken = _buyToken;
                      _buyToken = oldSell;

                      final oldSellAmount = _sellAmount;
                      _sellAmount = _buyAmount;
                      _buyAmount = oldSellAmount;

                      _textEditingController.text = _sellAmount == null ? '' : _sellAmount!.toString();

                      if (_sellAmount != null && _sellAmount! > 0) {
                        final int amountInt = (_sellAmount! * (pow(10, _sellToken.decimals))).round();
                        ref.read(tradeQuoteProvider.notifier).fetchTradeQuoteData(_sellToken.mint, _buyToken.mint, amountInt);
                      }
                    });
                  },

                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: BorderRadius.circular(50.r)),
                    alignment: Alignment.center,
                    child: Icon(WalletIcon.switch_up_and_down, color: Theme.of(context).colorScheme.onBackground),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(child: Divider(height: .5, color: Theme.of(context).colorScheme.onSurface.withOpacity(.2))),
                SizedBox(width: 12.w),
              ],
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 16),
          width: double.infinity,
          height: 40.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(50.r)),
          child: Text(
            t.trade.transaction,
            style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 28.h),

        tradeSwapQuoteData.when(
          data: (data) {
            // 最少获得数量
            final int minOutInt = int.parse(data.otherAmountThreshold);
            final double minOutUi = minOutInt / pow(10, _buyToken.decimals);

            // 汇率
            final inInt = int.parse(data.inAmount);
            final outInt = int.parse(data.outAmount);
            final inUi = inInt / pow(10, _sellToken.decimals);
            final outUi = outInt / pow(10, _buyToken.decimals);
            final rate = outUi / inUi; // 1 inToken = rate outToken

            // 手续费
            TradeSwapQuoteRoutePlanItemModel? swapInfo;
            if (data.routePlan.isNotEmpty) {
              swapInfo = data.routePlan.first.swapInfo;
            }
            double? feeUi;
            String feeSymbol = '';
            if (data.routePlan.isNotEmpty) {
              final swapInfo = data.routePlan.first.swapInfo;

              final feeAmountStr = swapInfo.feeAmount;
              final feeMint = swapInfo.feeMint;

              final feeInt = int.tryParse(feeAmountStr) ?? 0;
              final decimals = _decimalsForMint(feeMint);
              feeUi = feeInt / pow(10, decimals).toDouble();

              feeSymbol = _symbolForMint(feeMint);
            }

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('滑点', style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                    Text(
                      '${data.slippageBps / 100}%',
                      style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('提供方', style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                    Text(
                      data.routePlan[0].swapInfo.label,
                      style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('最少获得数量', style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                    Text(
                      "$minOutUi",
                      style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('收款地址', style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                    Text(
                      "AEz2i...Zqnm",
                      style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('兑换率', style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                    Text(
                      "1 ${_sellToken.symbol} = ${rate.toStringAsFixed(4)} ${_buyToken.symbol}",
                      style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('手续费', style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                    Text(
                      feeUi != null ? '${feeUi!.toStringAsFixed(8)}${feeSymbol.isNotEmpty ? ' $feeSymbol' : ''}' : '-', // 没有路由就显示 "-"
                      style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            );
          },
          error: (e, StackTrace) {
            return SizedBox();
          },
          loading: () {
            return SizedBox();
          },
        ),
      ],
    );
  }
}
