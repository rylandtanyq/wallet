import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/widget/CustomAppBar.dart';

import '../../base/base_page.dart';

/*
 * 代币详情
 */
class CoinDetailPage extends StatefulWidget {
  const CoinDetailPage({super.key});

  @override
  State<StatefulWidget> createState() => _CoinDetailPageState();
}

class _CoinDetailPageState extends State<CoinDetailPage> with BasePage<CoinDetailPage>, AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final List<String> categories = ['按网络', '按币种'];
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: CustomAppBar(title: ''),
      body: Column(
        children: [
          Stack(
            children: [
              // 横线全屏宽度
              Container(
                margin: EdgeInsets.only(top: 32.5.h), // 行高+间距，确保横线和指示器在同一行
                height: 0.5,
                width: double.infinity,
                color: Color(0xFFEEEEEE),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(categories.length, (index) {
                  final selected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      _pageController.animateToPage(index, duration: Duration(milliseconds: 250), curve: Curves.ease);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                color: selected ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          // 指示器
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            height: 2.5.h,
                            width: 60.w,
                            decoration: BoxDecoration(
                              color: selected ? Colors.black : Colors.transparent,
                              borderRadius: BorderRadius.circular(1.5.h),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [
                Center(child: Text('内容区：' + categories[0])),
                Center(child: Text('内容区：' + categories[1])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
