import 'package:feature_main/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:feature_wallet/hive/tokens.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'package:feature_main/src/home_page/fragments/home_page_financial_data_view_fragments.dart';

class HomePageFullChainRankingFragments extends StatefulWidget {
  final List<Tokens> tokesList;
  const HomePageFullChainRankingFragments({super.key, required this.tokesList});

  @override
  State<HomePageFullChainRankingFragments> createState() => _HomePageFullChainRankingFragmentsState();
}

class _HomePageFullChainRankingFragmentsState extends State<HomePageFullChainRankingFragments> {
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
        HomePageFinancialDataViewFragments(items: widget.tokesList),
        SizedBox(height: 13.h),
      ],
    );
  }
}
