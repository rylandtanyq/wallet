import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/widget/base_page.dart';
import 'package:shared_ui/widget/custom_appbar.dart';

/*
 * 连接硬件钱包
 */
class LinkHardwareWalletPage extends StatefulWidget {
  const LinkHardwareWalletPage({super.key});

  @override
  State<StatefulWidget> createState() => _LinkHardwareWalletPageState();
}

class _LinkHardwareWalletPageState extends State<LinkHardwareWalletPage> with BasePage<LinkHardwareWalletPage>, AutomaticKeepAliveClientMixin {
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
