import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/widget/base_page.dart';
import 'package:shared_ui/widget/custom_appbar.dart';

/*
 * 观察钱包
 */
class ObserveWalletPage extends StatefulWidget {
  const ObserveWalletPage({super.key});

  @override
  State<StatefulWidget> createState() => _ObserveWalletPageState();
}

class _ObserveWalletPageState extends State<ObserveWalletPage> with BasePage<ObserveWalletPage>, AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: CustomAppBar(title: ''),
      body: Container(
        padding: EdgeInsets.all(10.w),
        child: Column(
          children: [
            Text(
              '连接硬件钱包',
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
