import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/theme/app_textStyle.dart';

class AddingTokens extends StatefulWidget {
  const AddingTokens({super.key});

  @override
  State<AddingTokens> createState() => _AddingTokensState();
}

class _AddingTokensState extends State<AddingTokens> {
  final TextEditingController _textEditingController = TextEditingController();
  String? tokensSearchContent;
  final List<Map<String, String>> _tokenList = [
    {"image": "assets/images/BTC.png", "title": "BTC", "subtitle": "Bitcoin"},
    {"image": "assets/images/ETH.png", "title": "ETH", "subtitle": "Ethereum"},
    {"image": "assets/images/solana_logo.png", "title": "SOl", "subtitle": "Solana"},
    {"image": "assets/images/BNB.png", "title": "BNB", "subtitle": "BNB Chain"},
    {"image": "assets/images/BTC.png", "title": "ETH", "subtitle": "Base"},
    {"image": "assets/images/BTC.png", "title": "Ton", "subtitle": "Ton"},
    {"image": "assets/images/BTC.png", "title": "SUI", "subtitle": "SUI"},
    {"image": "assets/images/BTC.png", "title": "TRX", "subtitle": "Tron"},
  ];

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leadingWidth: 40,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.w, color: Theme.of(context).colorScheme.onBackground),
          onPressed: () {
            Feedback.forTap(context);
            Navigator.of(context).pop();
          },
        ),
        title: Padding(
          padding: EdgeInsets.only(bottom: 3.h),
          child: Text('添加代币', style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: "代币名称或者合约地址",
                hintStyle: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: EdgeInsets.only(right: 14),
                border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(25.r)),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onBackground),
              ),
              onChanged: (e) {
                setState(() {
                  tokensSearchContent = _textEditingController.text;
                });
              },
            ),
            SizedBox(height: 25),
            Expanded(
              child: ListView(
                children: [
                  Text(
                    "已添加代币",
                    style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w600),
                  ),
                  _tokensListWidget(_tokenList),
                  SizedBox(height: 30),
                  Text(
                    "热门代币",
                    style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w600),
                  ),
                  _tokensListWidget(_tokenList),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _tokensListWidget(List<Map<String, String>> _tokenList) {
  return ListView.separated(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemBuilder: (BuildContext context, int index) {
      final item = _tokenList[index];
      return Container(
        margin: EdgeInsets.only(top: index == 0 ? 30 : 0),
        width: double.infinity,
        height: 40.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(item['image'] ?? '', width: 40, height: 40),
            SizedBox(width: 10.w),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? '',
                        style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w600),
                      ),
                      Text(item['subtitle'] ?? '', style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '0.00',
                        style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w600),
                      ),
                      Text('¥0.00', style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Icon(Icons.add_circle_outline),
            // Icon(Icons.remove_circle_outline),
          ],
        ),
      );
    },
    separatorBuilder: (BuildContext context, int index) {
      return SizedBox(height: 20);
    },
    itemCount: _tokenList.length,
  );
}
