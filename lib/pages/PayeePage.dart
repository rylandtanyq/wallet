import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/constants/hive_boxes.dart';
import 'package:untitled1/hive/Wallet.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/util/HiveStorage.dart';
import 'package:untitled1/widget/CustomAppBar.dart';
import 'package:untitled1/widget/CustomTextField.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';

import '../../base/base_page.dart';

/*
 * 收款
 */
class PayeePage extends StatefulWidget {
  const PayeePage({super.key});

  @override
  State<StatefulWidget> createState() => _PayeePageState();
}

class _PayeePageState extends State<PayeePage> with BasePage<PayeePage>, AutomaticKeepAliveClientMixin {
  String? _currentWalletAdderss;

  @override
  void initState() {
    super.initState();
    _getCurrentSelectedWalletInformation();
  }

  // 获取当前钱包地址
  void _getCurrentSelectedWalletInformation() async {
    final wallet = await HiveStorage().getObject<Wallet>('currentSelectWallet', boxName: boxWallet);
    setState(() {
      _currentWalletAdderss = wallet?.address;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          icon: Icon(Icons.close, size: 20.h),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: '',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 可滚动内容部分
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(), // 更流畅的滚动效果
                padding: EdgeInsets.only(bottom: 20.h, right: 16.w, left: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40.h),
                    Image.asset('assets/images/ic_clip_photo.png', width: 55.h, height: 55.h),
                    SizedBox(height: 15.h),
                    Text(
                      'USDT${t.home.receive}',
                      style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onBackground),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      '${t.transfer_receive_payment.receiveNetwork} Solana',
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onBackground),
                    ),
                    SizedBox(height: 36.h),
                    SizedBox(
                      width: 182,
                      height: 182,
                      child: QrImageView(
                        data: _currentWalletAdderss ?? "",
                        version: QrVersions.auto,
                        backgroundColor: Theme.of(context).colorScheme.background,
                        foregroundColor: Theme.of(context).colorScheme.onBackground,
                        size: 320,
                        gapless: false,
                        embeddedImage: AssetImage('assets/images/solana_logo.png'),
                        embeddedImageStyle: QrEmbeddedImageStyle(size: Size(30, 30)),
                      ),
                    ),
                    // Image.asset('assets/images/ic_home_visa.png', width: 182.w, height: 182.w, fit: BoxFit.fill),
                    SizedBox(height: 22.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        minimumSize: Size(double.infinity, 45.h),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(.3), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _currentWalletAdderss ?? ""));
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _currentWalletAdderss ?? "",
                              style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 30.w),
                          Icon(Icons.copy_outlined, size: 18.w, color: Theme.of(context).colorScheme.onSurface),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.surface, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 12.5.w, vertical: 20.h),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                              ),
                              child: Row(
                                children: [
                                  Image.asset('assets/images/ic_wallet_create.png', width: 50.w, height: 50.w, fit: BoxFit.cover),
                                  SizedBox(width: 8.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.transfer_receive_payment.receiveFromExchange,
                                        style: TextStyle(
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onBackground,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      InkWell(
                                        onTap: () {},
                                        child: Text(
                                          t.transfer_receive_payment.directDeposit,
                                          style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurface),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Icon(Icons.arrow_forward_ios, size: 12.w, color: Theme.of(context).colorScheme.onBackground),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(.2),
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                              ),
                              child: Row(
                                children: [
                                  ColorFiltered(
                                    colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
                                    child: Image.asset('assets/images/ic_wallet_reminder.png', width: 14.w, height: 14.w),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    t.transfer_receive_payment.usdtOnlyNotice,
                                    style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.onBackground),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  minimumSize: Size(double.infinity, 42.h),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  textStyle: TextStyle(fontSize: 18.sp),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27.5.r)),
                ),
                onPressed: () {},
                child: Text(t.transfer_receive_payment.share),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
