import 'package:flutter/material.dart';
import 'package:untitled1/pages/view/CustomAppBar.dart';

import '../../../base/base_page.dart';

/*
 * 钱包demo
 */
class WalletDemoPage extends StatefulWidget {
  const WalletDemoPage({super.key});

  @override
  State<StatefulWidget> createState() => _WalletDemoPageState();
}

class _WalletDemoPageState extends State<WalletDemoPage>
    with BasePage<WalletDemoPage>, AutomaticKeepAliveClientMixin ,TickerProviderStateMixin {


  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: '',
      ),
      body: Column(
        children: [
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

}