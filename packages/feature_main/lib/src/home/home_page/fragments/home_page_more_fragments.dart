import 'package:feature_main/src/more_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:feature_main/i18n/strings.g.dart';
import 'package:feature_wallet/src/select_transfer_coin_type_page.dart';
import 'package:feature_wallet/src/selected_payee_page.dart';
import 'package:shared_ui/theme/app_textStyle.dart';

class HomePageMoreFragments extends StatelessWidget {
  const HomePageMoreFragments({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> _navIcons = [
      Image.asset('assets/images/ic_home_grid_profitable.png', width: 46.w, height: 46.w),
      Image.asset('assets/images/ic_home_grid_contract.png', width: 46.w, height: 46.w),
      Image.asset('assets/images/ic_home_grid_collection.png', width: 46.w, height: 46.w),
      Image.asset('assets/images/ic_home_grid_radar.png', width: 46.w, height: 46.w),
      Image.asset('assets/images/ic_home_grid_more.png', width: 46.w, height: 46.w),
    ];
    final List<String> titles = [t.home.transfer, t.home.contract, t.home.receive, t.home.golden_dog_radar, t.home.more];

    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.8, // 调整宽高比例
      children: List.generate(titles.length, (index) {
        return GestureDetector(
          onTap: () {
            if (index == 0) {
              Get.to(SelectTransferCoinTypePage(), transition: Transition.rightToLeft, duration: const Duration(milliseconds: 300));
            } else if (index == 2) {
              Get.to(
                SelectedPayeePage(), // 要跳转的页面
                transition: Transition.rightToLeft, // 设置从右到左的动画
                duration: const Duration(milliseconds: 300), // 可选：设置动画持续时间
              );
            } else if (index == 4) {
              Get.to(
                MoreServices(), // 要跳转的页面
                transition: Transition.rightToLeft, // 设置从右到左的动画
                duration: const Duration(milliseconds: 300), // 可选：设置动画持续时间
              );
            }
          },
          child: SizedBox(
            // 添加固定高度约束
            height: 80, // 根据需求调整
            child: Column(
              mainAxisSize: MainAxisSize.min, // 重要：使Column只占用最小空间
              children: [
                _navIcons[index],
                SizedBox(height: 5),
                Text(
                  titles[index],
                  style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onBackground),
                  maxLines: 1, // 限制文本行数
                  overflow: TextOverflow.ellipsis, // 超出显示省略号
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
