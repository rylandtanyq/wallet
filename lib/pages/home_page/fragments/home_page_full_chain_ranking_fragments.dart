import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/entity/FinancialItem.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/theme/app_textStyle.dart';
import 'package:untitled1/pages/home_page/fragments/home_page_financial_data_view_fragments.dart';

class HomePageFullChainRankingFragments extends StatefulWidget {
  const HomePageFullChainRankingFragments({super.key});

  @override
  State<HomePageFullChainRankingFragments> createState() => _HomePageFullChainRankingFragmentsState();
}

class _HomePageFullChainRankingFragmentsState extends State<HomePageFullChainRankingFragments> {
  final List<FinancialItem> items = [
    FinancialItem(name: 'NOM', amount: '\$982.07万', time: '1天前', price: '\$0.001817', change: '+275.88%', isPositive: true),
    FinancialItem(name: 'MCP', amount: '\$727.17万', time: '1天前', price: '\$0.005556', change: '+73.18%', isPositive: true),
    FinancialItem(name: 'TRENCHER', amount: '\$702.66万', time: '2天前', price: '\$0.004427', change: '+16.08%', isPositive: true),
    FinancialItem(name: 'TAI', amount: '\$558.74万', time: '', price: '\$0.1246', change: '+71.18%', isPositive: true),
    FinancialItem(name: 'CFX', amount: '\$1,140.69万', time: '23小时前', price: '\$0.002972', change: '+55780.77%', isPositive: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 5),
          child: Row(
            children: [
              Text(
                t.home.cross_chain_rank,
                style: AppTextStyles.size19.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        // HorizontalSelectList(
        //   items: List.generate(10, (index) => '榜单 ${index + 1}'),
        //   onSelected: (index) {},
        // ),
        HomePageFinancialDataViewFragments(items: items),
        SizedBox(height: 13.h),
      ],
    );
  }
}
